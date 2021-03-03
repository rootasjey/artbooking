import { Storage } from '@google-cloud/storage';
import * as functions from 'firebase-functions';
// @ts-ignore
import * as fs  from 'fs-extra';
const sizeOf = require('image-size');
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import * as sharp from 'sharp';

import { adminApp } from './adminApp';
import { checkOrGetDefaultVisibility } from './utils';

const firestore = adminApp.firestore();
const gcs = new Storage();

interface GenerateImageThumbsParams {
  extension: string;
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
  .onCall(async (params: CreateIllustrationParams, context) => {
    const userAuth = context.auth;
    const { name } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }
      
    if (typeof name !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [name] parameter 
        which is the illustration's name to create.`,
      );
    }

    const author: any = {};

    if (params.isUserAuthor) {
      author.id = userAuth.token.uid;
    }

    try {
      const addedDoc = await firestore
        .collection('illustrations')
        .add({
          author,
          categories: {},
          createdAt: adminApp.firestore.Timestamp.now(),
          description: '',
          dimensions: {
            height: 0,
            width: 0,
          },
          extension: '',
          license: {
            custom: false,
            description: '',
            name: '',
            existingLicenseId: '',
            usage: {
              edit: false,
              print: false,
              sell: false,
              share: false,
              showAttribution: true,
              useInOtherFree: false,
              useInOtherOss: false,
              useInOtherPaid: false,
              view: false,
            },
          },
          name: params.name,
          size: 0, // File's ize in bytes
          stats: {
            downloads: 0,
            fav: 0,
            shares: 0,
            views: 0,
          },
          summary: '',
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
              t1920: '',
              t2400: '',
            },
          },
          user: {
            id: userAuth.token.uid,
          },
          visibility: checkOrGetDefaultVisibility(params.visibility),
        });

      // Update user's stats
      const userDoc = await firestore
        .collection('users')
        .doc(userAuth.uid)
        .get();

      const userData = userDoc.data();
      
      if (userData) {
        let added: number = userData.stats?.illustrations?.added;
        let own: number = userData.stats?.illustrations?.own;
        
        if (typeof added !== 'number') {
          added = 0;
        }
        
        if (typeof own !== 'number') {
          own = 0;
        }

        added++;
        own++;

        await userDoc
          .ref
          .update({
            'stats.illustrations.added': added,
            'stats.illustrations.own': own,
            updatedAt: adminApp.firestore.Timestamp.now(),
          });
      }

      return {
        id: addedDoc.id,
        success: true,
      };

    } catch (error) {
      console.error(error);
      throw new functions.https.HttpsError(
        'internal', 
        `There was an internal error. Please try again later or contact us.`,
      );
    }
  });

/**
 * Delete an image document from Firestore and from Cloud Storage.
 */
export const deleteDocument = functions
  .region('europe-west3')
  .https
  .onCall(async (params: DeleteIllustrationParams, context) => {
    const userAuth = context.auth;
    const { id } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [id] argument (string)
         which is the illustration's id to delete.`,
        );
    }

    const docSnap = await firestore
      .collection('illustrations')
      .doc(id)
      .get();

    const docData = docSnap.data();

    if (!docSnap.exists || !docData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${id}] doesn't exist.`,
      );
    }

    if (docData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    // Delete files from Cloud Storage
    const dir = await adminApp.storage()
      .bucket()
      .getFiles({
        directory: `users/${userAuth.uid}/illustrations/${id}`
      });

    const files = dir[0];

    for await (const file of files) {
      await file.delete();
    }

    let imageBytesToRemove = 0;

    if (docData) {
      imageBytesToRemove = docData.size ?? 0;
    }

    await docSnap.ref.delete();

    // Update user's stats
    const userDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userDoc.data();

    if (userData) {
      let deleted: number = userData.stats?.illustrations?.deleted;
      let own: number = userData.stats?.illustrations?.own;

      if (typeof deleted !== 'number') {
        deleted = 0;
      }

      if (typeof own !== 'number') {
        own = 0;
      }

      own = own > 0 ? own - 1 : 0;
      deleted++

      // Update used storage.
      let storageIllustrationsUsed: number = userData.stats.storage.illustrations.used;
      storageIllustrationsUsed -= imageBytesToRemove;

      await userDoc.ref
        .update({
          'stats.illustrations.own': own,
          'stats.illustrations.deleted': deleted,
          'stats.storage.illustrations.used': storageIllustrationsUsed,
          updatedAt: adminApp.firestore.Timestamp.now(),
        });
    }

    return {
      id,
      success: true,
    };
  });

/**
 * Delete multiple illustrations documents from Firestore and from Cloud Storage.
 */
export const deleteDocuments = functions
  .region('europe-west3')
  .https
  .onCall(async (params: DeleteMultipleIllustrationsParams, context) => {
    const userAuth = context.auth;
    const { ids } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (!Array.isArray(ids) || ids.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [ids]
         which is an array of illustrations string id to delete.`,
      );
    }

    let illustrationsBytesToRemove: number = 0;
    
    for await (const id of ids) {
      try {
        const illusSnap = await firestore
          .collection('illustrations')
          .doc(id)
          .get();

        const illusData = illusSnap.data();

        if (!illusSnap.exists || !illusData) {
          throw new functions.https.HttpsError(
            'not-found',
            `The illustration to delete doesn't exist.`,
          )
        }

        if (illusData.user.id !== userAuth.uid) {
          throw new functions.https.HttpsError(
            'permission-denied',
            `You don't the permission to delete this illustration [${id}].`,
          )
        }

        // Delete files from Cloud Storage
        const dir = await adminApp.storage()
          .bucket()
          .getFiles({
            directory: `users/${userAuth.uid}/illustrations/${id}`
          });

        const files = dir[0];

        for await (const file of files) {
          await file.delete();
        }

        if (illusData) {
          illustrationsBytesToRemove += illusData.size as number;
        }

        await illusSnap.ref.delete();

      } catch (error) {
        throw new functions.https.HttpsError('internal', "There was an internal error. " +
          "Please try again later or contact us.");
      }
    }

    // Update user's stats
    const userDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userDoc.data();

    if (userData) {
      let own: number = userData.stats?.illustrations?.own;
      let deleted: number = userData.stats?.illustrations?.deleted;

      if (typeof own !== 'number') {
        own = 0;
      }

      if (typeof deleted !== 'number') {
        deleted = 0;
      }

      own = own - ids.length;
      own = own >= 0 ? own : 0;

      deleted += ids.length;

      // Update used storage.
      let storageIllustrationsUsed: number = userData.stats.storage.illustrations.used;
      storageIllustrationsUsed -= illustrationsBytesToRemove;


      await userDoc.ref
        .update({
          'stats.illustrations.own': own,
          'stats.illustrations.deleted': deleted,
          'stats.storage.illustrations.used': storageIllustrationsUsed,
          updatedAt: adminApp.firestore.Timestamp.now(),
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

    const extension = objectMeta.metadata?.extension ||
      filename.substring(filename.lastIndexOf('.'));

    // Generate thumbnails
    // -------------------
    const { dimensions, thumbnails } = await generateImageThumbs({
      extension,
      filename,
      filepath,
      objectMeta,
      visibility,
    });

    const { height, width } = dimensions;

    // Save new properties to Firestore.
    await firestore
      .collection('illustrations')
      .doc(firestoreId)
      .set({
        dimensions: {
          height,
          width,
        },
        extension,
        size: parseFloat(objectMeta.size),
        urls: {
          original: imageFile.publicUrl(),
          storage: storageUrl,
          thumbnails,
        },
      }, { 
        merge: true,
      });

    // Update used storage.
    const userDoc = await firestore
      .collection('users')
      .doc(userId)
      .get();

    const userData = userDoc.data();
    if (!userData) { return false; }

    let storageIllustrationsUsed: number = userData.stats.storage.illustrations.used;
    storageIllustrationsUsed += parseFloat(objectMeta.size);

    return userDoc
      .ref
      .update({
        'stats.storage.illustrations.used': storageIllustrationsUsed,
        updatedAt: adminApp.firestore.Timestamp.now(),
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
      const doc = await firestore
        .collection('illustrations')
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
      const doc = await firestore
        .collection('illustrations')
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
 * Update description, name, license, summary, & visibility if specified.
 */
export const updateDocumentProperties = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateImagePropsParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    checkUpdateParams(data);

    const { 
      description, 
      id, 
      name, 
      license, 
      summary, 
    } = data;

    const visibility = checkLicenseFormat(data.visibility);

    const docSnap = await firestore
      .collection('illustrations')
      .doc(id)
      .get();

    const docData = docSnap.data();

    if (!docSnap.exists || !docData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${id}] doesn't exist.`,
      );
    }

    if (docData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await docSnap.ref
      .update({
        description,
        name,
        license,
        summary,
        visibility,
      });

    return {
      id,
      success: true,
    }
  });

export const updateDocumentCategories = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateImageCategoriesParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }
    
    const { categories, id } = data;
    
    if (typeof id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called  with a valid [id] 
        argument which is the illustration's id.`,
      );
    }
    
    if (!Array.isArray(categories)) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called  with a valid [categories] 
        argument which is an array of string.`,
      );
    }

    const docSnap = await firestore
      .collection('illustrations')
      .doc(id)
      .get();

    const docData = docSnap.data();

    if (!docSnap.exists || !docData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${id}] doesn't exist.`,
      );
    }

    if (docData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await docSnap.ref.update({categories});

    return { 
      id, 
      success: true, 
    };
  });

export const updateDocumentTopics = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateImageTopicsParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const { topics, id } = data;


    if (typeof id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [id] 
        argument which is the illustration's id.`,
      );
    }

    if (!Array.isArray(topics)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [topics] 
        argument which is an array of string.`,
      );
    }
    
    const docSnap = await firestore
      .collection('illustrations')
      .doc(id)
      .get();

    const docData = docSnap.data();

    if (!docSnap.exists || !docData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${id}] doesn't exist.`,
      );
    }

    if (docData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await docSnap.ref.update({ topics });

    return {
      id,
      success: true,
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

  const { description, id, name, license, summary, visibility } = data;

  if (typeof description === 'undefined') {
    throw new functions.https.HttpsError('invalid-argument', "The function must be called with " +
      "a valid [description] parameter which is the image's description.");
  }

  if (typeof id !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid [id] 
      parameter which is the image's id.`,
    );
  }

  if (typeof name !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid [name] 
      parameter which is the image's name.`,
    );
  }

  if (typeof license !== 'object') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid [license] 
      parameter which is the image's license.`,
    );
  }

  if (typeof summary !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid [license] 
      parameter which is the image's license.`,
      );
  }

  if (typeof visibility !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid [visibility] 
      parameter which is the image's visibility.`,
    );
  }
}

function checkLicenseFormat(data: any) {
  const defaultLicense = {
    custom: false,
    description: '',
    name: '',
    existingLicenseId: '',
    usage: {
      edit: false,
      print: false,
      sell: false,
      share: false,
      showAttribution: true,
      useInOtherFree: false,
      useInOtherOss: false,
      useInOtherPaid: false,
      view: false,
    },
  };

  if (!data) {
    return defaultLicense;
  }

  if (typeof data.custom === 'boolean') {
    defaultLicense.custom = data.custom;
  }

  if (typeof data.description === 'string') {
    defaultLicense.description = data.description;
  }

  if (typeof data.name === 'string') {
    defaultLicense.name = data.name;
  }

  if (typeof data.existingLicenseId === 'string') {
    defaultLicense.existingLicenseId = data.existingLicenseId;
  }

  if (!data.usage) {
    return data;
  }

  if (typeof data.usage.edit === 'boolean') {
    defaultLicense.usage.edit = data.usage.edit;
  }

  if (typeof data.usage.print === 'boolean') {
    defaultLicense.usage.print = data.usage.print;
  }

  if (typeof data.usage.sell === 'boolean') {
    defaultLicense.usage.sell = data.usage.sell;
  }

  if (typeof data.usage.share === 'boolean') {
    defaultLicense.usage.share = data.usage.share;
  }

  if (typeof data.usage.showAttribution === 'boolean') {
    defaultLicense.usage.showAttribution = data.usage.showAttribution;
  }

  if (typeof data.usage.useInOtherFree === 'boolean') {
    defaultLicense.usage.useInOtherFree = data.usage.useInOtherFree;
  }


  if (typeof data.usage.useInOtherOss === 'boolean') {
    defaultLicense.usage.useInOtherOss = data.usage.useInOtherOss;
  }
    
  if (typeof data.usage.useInOtherPaid === 'boolean') {
    defaultLicense.usage.useInOtherPaid = data.usage.useInOtherPaid;
  }

  if (typeof data.usage.view === 'boolean') {
    defaultLicense.usage.view = data.usage.view;
  }

  return data;
}

/**
 * Create several thumbnails from an original file.
 * @param params Object conaining file's metadata.
 */
async function generateImageThumbs(
  params: GenerateImageThumbsParams
): Promise<GenerateImageThumbsResult> {
  const { objectMeta, extension, filename, filepath, visibility } = params;

  const thumbnails: ThumbnailUrls = {
    t1080: '',
    t1920: '',
    t2400: '',
    t360: '',
    t480: '',
    t720: '',
  };

  const allowedExt = ['jpg', 'jpeg', 'png', 'webp', 'tiff'];

  if (!allowedExt.includes(extension)) {
    return {
      dimensions: {
        height: 0,
        width: 0,
      },
      thumbnails,
    };
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

  // 2.1. Trye calculate dimensions.
  let dimensions = { height: 0, width: 0 };

  try {
    dimensions = sizeOf(tmpFilePath);
  } catch (error) {
    console.error(error);
  }

  // 3. Resize the images and define an array of upload promises.
  const sizes = Object
    .keys(thumbnails)
    .map((key) => parseInt(key.replace('t', '')));

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

  return { dimensions, thumbnails };
}
