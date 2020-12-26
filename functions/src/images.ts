import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';

/**
 * Create a new document with predefined values.
 */
export const createDocument = functions
  .region('europe-west3')
  .https
  .onCall(async (data: CreateImageParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user.');
    }
      
    if (!data || !data.name) {
      throw new functions.https.HttpsError('invalid-argument', "The function must be called with " +
        "a valid [name] parameter which is the image's name.");
    }

    const author: any = {};

    if (data.isUserAuthor) {
      author.id = userAuth.token.uid;
    }

    try {
      const addedDoc = await adminApp.firestore()
        .collection('images')
        .add({
          author,
          categories: {},
          createdAt: adminApp.firestore.Timestamp.now(),
          description: '',
          license: '',
          name: data.name,
          timelapse: {
            createdAt: null,
            description: '',
            name: '',
            updatedAt: null,
            urls: {
              original: '', // video or gif format
            },
          },
          topics: {},
          updatedAt: adminApp.firestore.Timestamp.now(),
          urls: {
            original: '',
            share: {
              read: '',
              write: '',
            },
            storage: '',
            thumbnail: {
              t360: '',
              t480: '',
              t720: '',
              t1080: '',
            },
          },
          user: {
            id: userAuth.token.uid,
          },
          visibility: data.visibility ?? 'private',
        });

        return {
          id: addedDoc.id,
          success: true,
        };

    } catch (error) {
      throw new functions.https.HttpsError('internal', "There was an internal error. " +
        "Please try again later or contact us.");
    }
  });

/**
 * Delete an image document from Firestore and from Cloud Storage.
 */
export const deleteDocument = functions
  .region('europe-west3')
  .https
  .onCall(async (data: DeleteImageParams, context) => {
    const userAuth = context.auth;
    const { id } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user.');
    }

    if (!data || !id) {
      throw new functions.https.HttpsError('invalid-argument', "The function must be called with " +
        "a valid [id] argument which is the image's id to delete.");
    }

    try {
      // Delete files from Cloud Storage
      const dir = await adminApp.storage()
        .bucket()
        .getFiles({
          directory: `users/${userAuth.uid}/images/${id}`
        });
        
      const files = dir[0];

      for await (const file of files) {
        await file.delete();
      }

      // Delete Firestore document
      await adminApp.firestore()
        .collection('images')
        .doc(id)
        .delete();

      return {
        id,
        success: true,
      };
    } catch (error) {
      throw new functions.https.HttpsError('internal', "There was an internal error. " +
        "Please try again later or contact us.");
    }
  });

/**
 * Delete multiple images documents from Firestore and from Cloud Storage.
 */
export const deleteDocuments = functions
  .region('europe-west3')
  .https
  .onCall(async (data: DeleteMultipleImagesParams, context) => {
    const userAuth = context.auth;
    const { ids } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user.');
    }

    if (!data || !ids || ids.length === 0) {
      throw new functions.https.HttpsError('invalid-argument', "The function must be called with " +
        "a valid [ids] argument which is an array of images ids to delete.");
    }

    for await (const id of ids) {
      try {
        // Delete files from Cloud Storage
        const dir = await adminApp.storage()
          .bucket()
          .getFiles({
            directory: `users/${userAuth.uid}/images/${id}`
          });

        const files = dir[0];

        for await (const file of files) {
          await file.delete();
        }

        // Delete Firestore document
        await adminApp.firestore()
          .collection('images')
          .doc(id)
          .delete();

      } catch (error) {
        throw new functions.https.HttpsError('internal', "There was an internal error. " +
          "Please try again later or contact us.");
      }
    }

    return {
      ids,
      success: true,
    };
  });

/**
 * On storage file creation, get download link
 * and set it to the Firestore matching document.
 */
export const onStorageUpload = functions
  .region('europe-west3')
  .storage
  .object()
  .onFinalize(async (metadata) => {
    const customMetadata = metadata.metadata;

    if (!customMetadata) {
      return;
    }

    const { firestoreId, userId, visibility } = customMetadata;

    if (!firestoreId || !userId) {
      return;
    }

    const storageUrl = `${metadata.name}`;

    const imageFile = adminApp.storage()
      .bucket()
      .file(storageUrl);

    if (!await imageFile.exists()) {
      console.log('file does not exist')
      return;
    }

    if (visibility) {
      await imageFile.makePublic();
    }

    await adminApp.firestore()
      .collection('images')
      .doc(firestoreId)
      .set({
        urls: {
          original: imageFile.publicUrl(),
          storage: storageUrl,
        },
      }, { 
        merge: true, 
      });
  });

/**
 * Set the image's author id same as user's id.
 */
export const setUserAuthor = functions
  .region('europe-west3')
  .https
  .onCall(async (data: SetUserAuthorParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user.');
    }

    const { imageId } = data;

    try {
      const doc = await adminApp.firestore()
        .collection('images')
        .doc(imageId)
        .get();

      const docData = doc.data();

      if (!docData) {
        throw new functions.https.HttpsError('not-found', "The document doesn't exists anymore. " +
          "Please try again later or contact us.");
      }

      if (docData.user.id !== userAuth.uid) {
        throw new functions.https.HttpsError('permission-denied', "You don't have access to this document.");
      }

      await doc.ref
        .set({
          author: {
            id: userAuth.uid,
          },
        },
          {
            merge: true,
          }
        );

      return {
        imageId,
        success: true,
      }
    } catch (error) {
      throw new functions.https.HttpsError('internal', "There was an internal error. " +
        "Please try again later or contact us.");
    }
  });

/**
 * Unset the image's author id same as user's id.
 */
export const unsetUserAuthor = functions
  .region('europe-west3')
  .https
  .onCall(async (data: SetUserAuthorParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user.');
    }

    const { imageId } = data;

    try {
      const doc = await adminApp.firestore()
        .collection('images')
        .doc(imageId)
        .get();

      const docData = doc.data();

      if (!docData) {
        throw new functions.https.HttpsError('not-found', "The document doesn't exists anymore. " +
          "Please try again later or contact us.");
      }

      if (docData.user.id !== userAuth.uid) {
        throw new functions.https.HttpsError('permission-denied', "You don't have access to this document.");
      }

      await doc.ref
        .set({
          author: {
            id: '',
          },
        },
          {
            merge: true,
          }
        );

      return {
        imageId,
        success: true,
      }
    } catch (error) {
      throw new functions.https.HttpsError('internal', "There was an internal error. " +
        "Please try again later or contact us.");
    }
  });

/**
 * Update description, name, license, visibility if specified.
 */
export const updateDocumentProperties = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateImagePropsParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user.');
    }

    checkUpdateParams(data);
    const { description, id, name, license, visibility } = data;

    try {
      await adminApp.firestore()
        .collection('images')
        .doc(id)
        .set({
          description,
          name,
          license,
          visibility,
        },
          {
            merge: true,
          }
        );

      return {
        id,
        success: true,
      }
    } catch (error) {
      throw new functions.https.HttpsError('internal', "There was an internal error. " +
        "Please try again later or contact us.");
    }
  });

export const updateDocumentCategories = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateImageCategoriesParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user.');
    }
    
    const { categories, id } = data;
    
    if (!categories) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called  ' +
        "with [categories] argument which is the image's categories.");
    }

    try {
      await adminApp.firestore()
        .collection('images')
        .doc(id)
        .set({categories}, {merge: true});

      return { 
        id, 
        success: true, 
      };
    } catch (error) {
      throw new functions.https.HttpsError('internal', "There was an internal error. " +
        "Please try again later or contact us.");
    }
  });

export const updateDocumentTopics = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateImageTopicsParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user.');
    }

    const { topics, id } = data;

    if (!topics) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called  ' +
        "with [topics] argument which is the image's topics.");
    }

    try {
      await adminApp.firestore()
        .collection('images')
        .doc(id)
        .set({ topics }, { merge: true });

      return {
        id,
        success: true,
      }
    } catch (error) {
      throw new functions.https.HttpsError('internal', "There was an internal error. " +
        "Please try again later or contact us.");
    }
  });

function checkUpdateParams(data: UpdateImagePropsParams) {
  if (!data) {
    throw new functions.https.HttpsError('invalid-argument', "The function must be called with " +
      "a valid [description], [id], [name], [license] and [visibility] parameters..");
  }

  const { description, id, name, license, visibility } = data;

  if (typeof description === 'undefined') {
    throw new functions.https.HttpsError('invalid-argument', "The function must be called with " +
      "a valid [description] parameter which is the image's description.");
  }

  if (typeof id === 'undefined') {
    throw new functions.https.HttpsError('invalid-argument', "The function must be called with " +
      "a valid [id] parameter which is the image's id.");
  }

  if (typeof name === 'undefined') {
    throw new functions.https.HttpsError('invalid-argument', "The function must be called with " +
      "a valid [name] parameter which is the image's name.");
  }

  if (typeof license === 'undefined') {
    throw new functions.https.HttpsError('invalid-argument', "The function must be called with " +
      "a valid [license] parameter which is the image's license.");
  }

  if (typeof visibility === 'undefined') {
    throw new functions.https.HttpsError('invalid-argument', "The function must be called with " +
      "a valid [visibility] parameter which is the image's visibility.");
  }
}
