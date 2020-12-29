import { Storage } from '@google-cloud/storage';
import * as functions from 'firebase-functions';
// @ts-ignore
import * as fs  from 'fs-extra';
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import * as sharp from 'sharp';

import { adminApp } from './adminApp';

const gcs = new Storage();

interface GenerateImageThumbsParams {
  filename: string;
  filepath: string;
  objectMeta: functions.storage.ObjectMetadata;
  visibility: string;
}

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
          size: 0, // File's ize in bytes
          stats: {
            downloads: 0,
            fav: 0,
            shares: 0,
            views: 0,
          },
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
            thumbnails: {
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

      // Update user's stats
      const userDoc = await adminApp.firestore()
        .collection('users')
        .doc(userAuth.uid)
        .get();

      const userData = userDoc.data();

      if (userData) {
        let added: number = userData.stats?.image?.added;
        if (typeof added !== 'number') {
          added = 0;
        }

        await userDoc
          .ref
          .update({
            'stats.images.added': added++,
          });
      }

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

      // Update user's stats
      const userDoc = await adminApp.firestore()
        .collection('users')
        .doc(userAuth.uid)
        .get();

      const userData = userDoc.data();

      if (userData) {
        let added: number = userData.stats?.image?.added;
        if (typeof added !== 'number') {
          added = 0;
        }

        await userDoc
          .ref
          .update({
            'stats.images.added': added--,
          });
      }

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

    // Update user's stats
    const userDoc = await adminApp.firestore()
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userDoc.data();

    if (userData) {
      let added: number = userData.stats?.image?.added;
      if (typeof added !== 'number') {
        added = 0;
      }

      added = added - ids.length;
      added = added >= 0 ? added : 0;

      await userDoc
        .ref
        .update({
          'stats.images.added': added,
        });
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
  .runWith({
    memory: '2GB',
    timeoutSeconds: 180,
  })
  .region('europe-west3')
  .storage
  .object()
  .onFinalize(async (objectMeta) => {
    const customMetadata = objectMeta.metadata;
    if (!customMetadata) { return; }

    const { firestoreId, userId, visibility } = customMetadata;
    if (!firestoreId || !userId) { return; }

    const filepath = objectMeta.name || '';
    const filename = filepath.split('/').pop() || '';
    const storageUrl = filepath;

    // Exit if thumbnail or not an image file.
    const contentType = objectMeta.contentType || '';

    if (filename.includes('thumb@') || !contentType.includes('image')) {
      console.info(`Exiting function => existing image or non-file image: ${filepath}`);
      return false;
    }

    const imageFile = adminApp.storage()
      .bucket()
      .file(storageUrl);

    if (!await imageFile.exists()) {
      console.log('file does not exist')
      return;
    }

    // -> Start to process the image file.
    if (visibility === 'public') {
      await imageFile.makePublic();
    }

    // Generate thumbnails
    // -------------------
    const thumbnails = await generateImageThumbs({
      filename,
      filepath,
      objectMeta,
      visibility,
    });

    // Save new properties to Firestore.
    await adminApp.firestore()
      .collection('images')
      .doc(firestoreId)
      .set({
        size: parseFloat(objectMeta.size),
        urls: {
          original: imageFile.publicUrl(),
          storage: storageUrl,
          thumbnails,
        },
      }, { 
        merge: true,
      });

    const userDoc = await adminApp.firestore()
      .collection('users')
      .doc(userId)
      .get();

    const userData = userDoc.data();
    if (!userData) { return false; }

    let storageImagesUsed: number = userData.stats.storage.images.used;
    storageImagesUsed += parseFloat(objectMeta.size);

    return userDoc
      .ref
      .update('stats.storage.images.used', storageImagesUsed);
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

// ----------------
// Helper functions
// ----------------

/**
 * Check properties presence.
 * @param data Object containing updated properties.
 */
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

/**
 * Create several thumbnails from an original file.
 * @param params Object conaining file's metadata.
 */
async function generateImageThumbs(
  params: GenerateImageThumbsParams
): Promise<ThumbnailUrls> {
  const { objectMeta, filename, filepath, visibility } = params;

  const thumbnails: ThumbnailUrls = {
    t1080: '',
    t360: '',
    t480: '',
    t720: '',
  };

  const allowedExt = ['jpg', 'jpeg', 'png', 'webp', 'tiff'];
  const extension = objectMeta.metadata?.extension ||
    filename.substring(filename.lastIndexOf('.'));

  if (!allowedExt.includes(extension)) {
    return thumbnails;
  }

  const bucket = gcs.bucket(objectMeta.bucket);
  const bucketDir = dirname(filepath);

  const workingDir = join(tmpdir(), 'thumbs');
  const tmpFilePath = join(workingDir, filename);

  // 1. Ensure thumbnail directory exists.
  await fs.ensureDir(workingDir);

  // 2. Download source file.
  await bucket.file(filepath).download({
    destination: tmpFilePath,
  });

  // 3. Resize the images and define an array of upload promises.
  const sizes = [360, 480, 720, 1080];

  const uploadPromises = sizes.map(async (size) => {
    const thumbName = `thumb@${size}.${extension}`;
    const thumbPath = join(workingDir, thumbName);

    // Resize source image.
    await sharp(tmpFilePath)
      .resize(size, size, { withoutEnlargement: true })
      .toFile(thumbPath);

    return bucket.upload(thumbPath, {
      destination: join(bucketDir, thumbName),
      metadata: {
        metadata: objectMeta.metadata,
      },
      public: visibility === 'public',
    });
  });

  // 4. Run the upload operations.
  const uploadResponses = await Promise.all(uploadPromises);

  // 5. Clean up the tmp/thumbs from file system.
  await fs.remove(workingDir);

  // 6. Retrieve thumbnail urls.
  for (const upResp of uploadResponses) {
    const upFile = upResp[0];
    let key = upFile.name.split('/').pop() || '';
    key = key.substring(0, key.lastIndexOf('.')).replace('thumb@', 't');

    thumbnails[key] = upFile.publicUrl();
  }

  return thumbnails;
}
