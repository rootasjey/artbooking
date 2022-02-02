import { Storage } from '@google-cloud/storage';
import * as functions from 'firebase-functions';
// @ts-ignore
import * as fs  from 'fs-extra';
import sizeOf = require('image-size');
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import * as sharp from 'sharp';

import { adminApp } from './adminApp';
import { allowedLicenseTypes, cloudRegions } from './utils';

import https = require('https');
import { ISizeCalculationResult } from 'image-size/dist/types/interface';

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
 * Check an illustration document in Firestore from its id [illustrationId].
 * If the document has missing properties, try to populate them from storage file.
 * If there's no corresponding storage file, delete the firestore document.
 */
export const checkProperties = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: CheckPropertiesParams, context) => {
    const userAuth = context.auth;
    const { illustrationId } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof illustrationId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [illustrationId] argument (string)
         which is the illustration's id to delete.`,
      );
    }

    const illustrationSnap = await firestore
      .collection('illustrations')
      .doc(illustrationId)
      .get();

    const illustrationData = illustrationSnap.data();

    if (!illustrationSnap.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${illustrationId}] doesn't exist.`,
      );
    }

    const urls = illustrationData.urls;
    const illusDataWidth = illustrationData.dimensions.width;
    const illusDataHeight = illustrationData.dimensions.height;

    const dimensionsAreNumbers = typeof illusDataWidth === 'number' && typeof illusDataHeight === 'number';
    const dimensionsAreStrictlyPositive = illusDataWidth > 0 && illusDataHeight > 0;
    const dimensionsAreOK = dimensionsAreNumbers && dimensionsAreStrictlyPositive;

    if (urls.original && urls.storage && dimensionsAreOK) {
      return {
        success: false,
        message: `Nothing to change. Everything is up-to-date.`,
        illustration: {
          id: illustrationId,
        },
      };
    }

    const dir = await adminApp.storage()
      .bucket()
      .getFiles({
        directory: `users/${userAuth.uid}/illustrations/${illustrationId}`
      });

    let storagePath: string = '';
    const files = dir[0];

    if (!files || files.length === 0) {
      await illustrationSnap.ref.delete();

      return {
        success: false,
        illustration: {
          id: illustrationId,
        },
      };
    }

    const firstFile = files[0];
    const [metadata] = await firstFile.getMetadata();

    const thumbnails: ThumbnailUrls = {
      t1080: '',
      t1920: '',
      t2400: '',
      t360: '',
      t480: '',
      t720: '',
    };

    /** Image's original url from Firebase Storage. */
    let originalUrl = '';

    for await (const file of files) {
      const atIndex = file.name.lastIndexOf('@');
      const dotIndex = file.name.lastIndexOf('.');
      const sizeStr = file.name.substring(atIndex + 1, dotIndex);

      if (atIndex > -1) { // thumbnails
        thumbnails[`t${sizeStr}`] = file.publicUrl();
      } else { // original image
        originalUrl = file.publicUrl();
        storagePath = file.name || '';
      }
    }

    const { height, width, type: extension } = await getDimensionsFromUrl(originalUrl);

    await illustrationSnap.ref.update({
      dimensions: {
        height: height,
        width: width,
      },
      extension: extension,
      size: parseFloat(metadata.size),
      urls: {
        original: originalUrl,
        storage: storagePath,
        thumbnails,
      },
    });

    return {
      success: true,
      illustration: {
        id: illustrationId,
      },
    };
  });

/**
 * Create a new document with predefined values.
 */
export const createOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: CreateIllustrationParams, context) => {
    const userAuth = context.auth;
    const { name, visibility, isUserAuthor } = params;

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

    if (isUserAuthor) {
      author.id = userAuth.token.uid;
    }

    checkVisibilityValue(visibility);

    const illustrationSnap = await firestore
      .collection('illustrations')
      .add({
        author,
        createdAt: adminApp.firestore.Timestamp.now(),
        description: '',
        dimensions: {
          height: 0,
          width: 0,
        },
        extension: '',
        hasPendingCreates: true,
        license: {
          type: '',
          id: '',
        },
        name: name,
        size: 0, // File's ize in bytes
        stats: {
          downloads: 0,
          fav: 0,
          shares: 0,
          views: 0,
        },
        story: '',
        styles: {},
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
        visibility: visibility,
      });

    return {
      illustration: {
        id: illustrationSnap.id,
      },
      success: true,
    };
  });

/**
 * Delete an image document from Firestore and from Cloud Storage.
 */
export const deleteOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: DeleteIllustrationParams, context) => {
    const userAuth = context.auth;
    const { illustrationId } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof illustrationId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [illustrationId] argument (string)
         which is the illustration's id to delete.`,
        );
    }

    const illustrationSnap = await firestore
      .collection('illustrations')
      .doc(illustrationId)
      .get();

    const illustrationData = illustrationSnap.data();

    if (!illustrationSnap.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${illustrationId}] doesn't exist.`,
      );
    }

    if (illustrationData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    // Delete files from Cloud Storage
    const dir = await adminApp.storage()
      .bucket()
      .getFiles({
        directory: `users/${userAuth.uid}/illustrations/${illustrationId}`
      });

    const files = dir[0];

    for await (const file of files) {
      await file.delete();
    }

    await illustrationSnap.ref.delete();

    return {
      illustration: {
        id: illustrationId,
      },
      success: true,
    };
  });

/**
 * Delete multiple illustrations documents 
 * from Firestore and from Cloud Storage.
 */
export const deleteMany = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: DeleteMultipleIllustrationsParams, context) => {
    const userAuth = context.auth;
    const { illustrationIds } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (!Array.isArray(illustrationIds) || illustrationIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [illustrationIds]
         which is an array of illustrations string id to delete.`,
      );
    }

    /** How many operations succeeded. */
    let successCount = 0;
    const itemsProcessed = [];
    
    for await (const illustrationId of illustrationIds) {
      try {
        const illustrationSnap = await firestore
          .collection('illustrations')
          .doc(illustrationId)
          .get();

        const illustrationData = illustrationSnap.data();
        let errorMessage = `The illustration [${illustrationIds}] doesn't exist.`;

        if (!illustrationSnap.exists || !illustrationData) {
          itemsProcessed.push({
            illustration: {
              id: illustrationId,
            },
            success: false,
            errorMessage,
          });

          throw new functions.https.HttpsError(
            'not-found',
            errorMessage,
          )
        }

        if (illustrationData.user.id !== userAuth.uid) {
          errorMessage = `You don't have the permission 
            to delete the illustration [${illustrationId}].`;

          itemsProcessed.push({
            illustration: {
              id: illustrationId,
            },
            success: false,
            errorMessage,
          });

          throw new functions.https.HttpsError(
            'permission-denied',
            errorMessage,
          );
        }

        // Delete files from Cloud Storage
        const dir = await adminApp.storage()
          .bucket()
          .getFiles({
            directory: `users/${userAuth.uid}/illustrations/${illustrationId}`
          });

        const files = dir[0];

        for await (const file of files) {
          await file.delete();
        }

        await illustrationSnap.ref.delete();

        successCount++;

        itemsProcessed.push({
          illustration: {
            id: illustrationId,
          },
          success: true,
        });

      } catch (error) {
        console.error(`Error while deleting illustration [${illustrationId}]`);
        console.error(error);
      }
    }

    return {
      items: itemsProcessed,
      successCount,
      hasErrors: successCount === illustrationIds.length,
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
  .region(cloudRegions.eu)
  .storage
  .object()
  .onFinalize(async (objectMeta) => {
    const customMetadata = objectMeta.metadata;
    if (!customMetadata) { return; }

    const { firestoreId, visibility, target } = customMetadata;
    
    if (target === 'profilePicture') {
      return await setUserProfilePicture(objectMeta);
    }
    
    const filepath = objectMeta.name || '';
    const filename = filepath.split('/').pop() || '';
    const storageUrl = filepath;
    
    const endIndex: number = filepath.indexOf('/illustrations')
    const userId = filepath.substring(6, endIndex)
    if (!firestoreId || !userId) { return; }

    // Exit if thumbnail or not an image file.
    const contentType = objectMeta.contentType || '';

    if (filename.includes('thumb@') || !contentType.includes('image')) {
      console.info(`Exiting function => existing image or non-file image: ${filepath}`);
      return false;
    }

    // Check if same user as firestore illustration
    const illustrationDoc = await firestore
      .collection('illustrations')
      .doc(firestoreId)
      .get();

    const illustrationData = illustrationDoc.data()
    if (!illustrationData || illustrationData.user.id !== userId) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `It seems that the user ${userId} is trying to access a forbidden document.`,
      )
    }

    const imageFile = adminApp.storage()
      .bucket()
      .file(storageUrl);

    if (!await imageFile.exists()) {
      console.error('file does not exist')
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
    await illustrationDoc.ref
      .update({
        dimensions: {
          height,
          width,
        },
        extension,
        hasPendingCreates: false,
        size: parseFloat(objectMeta.size),
        urls: {
          original: imageFile.publicUrl(),
          storage: storageUrl,
          thumbnails,
        },
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

    return await userDoc
      .ref
      .update({
        'stats.storage.illustrations.used': storageIllustrationsUsed,
        updatedAt: adminApp.firestore.Timestamp.now(),
      });
  });

/**
 * Set the illustration's author id same as user's id.
 */
export const setUserAuthor = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: SetUserAuthorParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    const { illustrationId } = data;

    if (!illustrationId || typeof illustrationId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `You must provid a valid argument for [illustrationId]
         which is illustration to update.`,
      )
    }

    const illustrationSnap = await firestore
      .collection('illustrations')
      .doc(illustrationId)
      .get();

    const illustrationData = illustrationSnap.data();

    if (!illustrationSnap.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found', 
        `The document doesn't exists anymore.
         Please try again later or contact us.`,
      );
    }

    if (illustrationData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied', 
        `You don't have the permission to update this illustration.`,
      );
    }

    await illustrationSnap.ref.update({
      author: {
        id: userAuth.uid,
      }});

    return {
      illustration: {
        id: illustrationId,
      },
      success: true,
    }
  });

/**
 * Unset illustration's license.
 */
export const unsetLicense = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: UpdateIllusLicenseParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const { illustrationId } = data;

    const illusSnap = await firestore
      .collection('illustrations')
      .doc(illustrationId)
      .get();

    const illustrationData = illusSnap.data();

    if (!illusSnap.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `Sorry we didn't find the illustration you're trying to update. It may have been deleted.`
      )
    }

    if (illustrationData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await illusSnap.ref.update({
      license: {
        type: '',
        id: '',
      },
    });

    return {
      illustration: {
        id: illustrationId,
      },
      success: true,
    };
  });

/**
 * Unset the image's author id same as user's id.
 */
export const unsetUserAuthor = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: SetUserAuthorParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    const { illustrationId } = data;

    if (!illustrationId || typeof illustrationId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `You must provid a valid argument for [illustrationId]
         which is illustration to update.`,
      )
    }

    const illustrationSnap = await firestore
      .collection('illustrations')
      .doc(illustrationId)
      .get();

    const illustrationData = illustrationSnap.data();

    if (!illustrationSnap.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The document doesn't exists anymore.
         Please try again later or contact us.`,
      );
    }

    if (illustrationData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to update this illustration.`,
      );
    }

    await illustrationSnap.ref.update({
      author: { id: '' }
    });

    return {
      illustration: {
        id: illustrationId,
      },
      success: true,
    }
  });

/**
 * Update illustration's license.
 */
export const updateLicense = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: UpdateIllusLicenseParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const { illustrationId, license } = data;
    checkIllustrationLicenseFormat(license);

    const illusSnap = await firestore
      .collection('illustrations')
      .doc(illustrationId)
      .get();

    const illustrationData = illusSnap.data();

    if (!illusSnap.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `Sorry we didn't find the illustration you're trying to update. It may have been deleted.`
      )
    }

    if (illustrationData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await illusSnap.ref.update({
      license: {
        type: license.type ?? '',
        id: license.id ?? '',
      },
    });

    return {
      illustration: {
        id: illustrationId,
      },
      success: true,
    };
  });

/**
 * Update name, description, story.
 */
export const updatePresentation = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: UpdateIllusPresentationParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    checkUpdatePresentationParams(data);

    const { 
      description,
      illustrationId,
      name,
      story,
    } = data;

    const illustrationSnap = await firestore
      .collection('illustrations')
      .doc(illustrationId)
      .get();

    const illustrationData = illustrationSnap.data();

    if (!illustrationSnap.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration [${illustrationId}] doesn't exist.`,
      );
    }

    if (illustrationData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await illustrationSnap.ref.update({
      description,
      name,
      story,
    });

    return {
      illustration: {
        id: illustrationId,
      },
      success: true,
    }
  });

/**
 * Update illustration's styles.
 * Styles are pre-defined (by the app) and are limited to 5.
 */
export const updateStyles = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: UpdateIllusStylesParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }
    
    const { styles, illustrationId } = data;
    
    if (typeof illustrationId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called  with a valid [illustrationId]
         argument which is the illustration's id.`,
      );
    }
    
    if (!Array.isArray(styles)) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called  with a valid [styles]
         argument which is an array of string.`,
      );
    }
    
    if (styles.length > 5) {
      throw new functions.https.HttpsError(
        'out-of-range',
        `Please use no more than 5 styles. You provided ${styles.length} styles.`
      )
    }


    const illustrationSnap = await firestore
      .collection('illustrations')
      .doc(illustrationId)
      .get();

    const docData = illustrationSnap.data();

    if (!illustrationSnap.exists || !docData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration [${illustrationId}] doesn't exist.`,
      );
    }

    if (docData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to update this illustration.`,
      );
    }

    const stylesMap: Record<string, boolean> = {};

    for (const style of styles) {
      stylesMap[style] = true;
    }

    await illustrationSnap.ref.update({ styles: stylesMap });;

    return { 
      illustration: {
        id: illustrationId,
      }, 
      success: true, 
    };
  });

/**
 * Update illustration's topics.
 * Topics are user generated and limited to 5.
 */
export const updateTopics = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: UpdateIllusTopicsParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const { topics, illustrationId } = data;


    if (typeof illustrationId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [illustrationId]
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

    if (topics.length > 5) {
      throw new functions.https.HttpsError(
        'out-of-range',
        `Please use no more than 5 topics. You provided ${topics.length} topics.`
      )
    }
    
    const illustrationSnap = await firestore
      .collection('illustrations')
      .doc(illustrationId)
      .get();

    const illustrationData = illustrationSnap.data();

    if (!illustrationSnap.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${illustrationId}] doesn't exist.`,
      );
    }

    if (illustrationData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    const topicsMap: Record<string, boolean> = {};
    
    for (const topic of topics) {
      topicsMap[topic] = true;
    }

    await illustrationSnap.ref.update({ topics: topicsMap });

    return {
      illustration: {
        id: illustrationId,
      },
      success: true,
    }
  });

/**
 * Update illustration's visibility.
 * Define who can view, edit or share this illustration.
 */
export const updateVisibility = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: UpdateIllusVisibilityParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const { illustrationId, visibility } = data;

    if (typeof illustrationId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [illustrationId]
         argument which is the illustration's id.`,
      );
    }

    if (typeof visibility !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [visibility]
         argument which is a string.`,
      );
    }

    checkVisibilityValue(visibility);

    const illustrationSnap = await firestore
      .collection('illustrations')
      .doc(illustrationId)
      .get();

    const illustrationData = illustrationSnap.data();

    if (!illustrationSnap.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${illustrationId}] doesn't exist.`,
      );
    }

    if (illustrationData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await illustrationSnap.ref.update({ visibility });

    return {
      illustration: {
        id: illustrationId,
      },
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
function checkUpdatePresentationParams(data: UpdateIllusPresentationParams) {
  if (!data) {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with valid
       [description], [illustrationId], [name], [story] parameters.`,
    );
  }

  const { 
    description,
    illustrationId,
    name,
    story,
  } = data;

  if (typeof description !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid
       [description] parameter which is the image's description.`,
      );
  }

  if (typeof illustrationId !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid [iillustrationIdd]
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

  if (typeof story !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid [license]
       parameter which is the image's license.`,
      );
  }
}

function checkIllustrationLicenseFormat(data: any) {
  if (typeof data !== 'object') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The license data you provided is not an object. You provided a ${typeof data}. ` +
      `You must specify an object, and it should have a [type] property which is a string, ` + 
      `and an [id] property referencing an existing license in database.`,
    )
  }
  
  if (typeof data.id !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The license data you provided has the property [license.id] = ${data.id} - ` +
      `which is not an string. ` +
      `The property [id] must be a string ` + 
      `and references an existing license in database.`,
    )
  }

  if (typeof data.type !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The license data you provided has the property [license.type] = ${data.type} - ` +
      `which is not an string. ` +
      `The property [type] must be a string ` + 
      `among these values: ${allowedLicenseTypes.join(", ")}`,
    )
  }

  if (allowedLicenseTypes.includes(data.type)) {
    return;
  }

  throw new functions.https.HttpsError(
    'invalid-argument',
    `The value provided for [type] parameter is not valid. ` +
    `Allowed values are: ${allowedLicenseTypes.join(", ")}`,
  );
}

/**
 * Throw an exception if the visibility's value is not
 * among allowed values.
 */
function checkVisibilityValue(visibility: string) {
  let isAllowed = false;

  switch (visibility) {
    case "acl":
    case "private":
    case "public":
    case "unlisted":
      isAllowed = true;
      break;
    default:
      isAllowed = false;
      break;
  }

  if (!isAllowed) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Invalide [visibility] value. Allowed values are: [acl], [private], [public], [unlisted].`,
    );
  }
}

/**
 * Create several thumbnails from an original file.
 * @param params Object conaining file's metadata.
 */
async function generateImageThumbs(
  params: GenerateImageThumbsParams
): Promise<GenerateImageThumbsResult> {
  const { 
    objectMeta, 
    extension, 
    filename, 
    filepath, 
    visibility, 
  } = params;

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

  // 2.1. Try calculate dimensions.
  let dimensions: ISizeCalculationResult = { height: 0, width: 0 };

  try {
    dimensions = sizeOf.imageSize(tmpFilePath);
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
  await fs.emptyDir(workingDir)
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

/**
 * Return a image's dimensions & extension.
 * @param url Image's string to fetch.
 * @returns An object containing the image's dimensions & extension.
 */
async function getDimensionsFromUrl(url: string): Promise<ISizeCalculationResult> {
  return new Promise((resolve) => {
    const options = new URL(url);

    https.get(options, function (response) {
      const chunks: any[] = [];
      let chunksLength = 0;

      response.on('data', function (chunk) {
        chunks.push(chunk)
        chunksLength += chunk.length;

        if (chunksLength > 1000) {
          response.destroy();
        }
      }).on('end', function () {
        const buffer = Buffer.concat(chunks);

        try {
          resolve(sizeOf.imageSize(buffer));
        } catch (error) {
          console.error(error);
          resolve({ height: 0, width: 0 });
        }
      });
    });
  });
}

/**
 * Generate a long lived persistant Firebase Storage download URL.
 * @param bucket Bucket name.
 * @param pathToFile File's path.
 * @param downloadToken File's download token.
 * @returns Firebase Storage download url.
 */
const createPersistentDownloadUrl = (bucket: string, pathToFile: string, downloadToken: string) => {
  return `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${encodeURIComponent(
    pathToFile
  )}?alt=media&token=${downloadToken}`;
};

/**
 * Update user's `profilePicture` field with newly upload image.
 * @param objectMeta Firebase Storage object metadta.
 * @returns Promise
 */
async function setUserProfilePicture(objectMeta: functions.storage.ObjectMetadata) {
  const filepath = objectMeta.name || '';
  const filename = filepath.split('/').pop() || '';
  const storageUrl = filepath;

  const endIndex: number = filepath.indexOf('/profile')
  const userId = filepath.substring(6, endIndex)
  
  if (!userId) { 
    throw new functions.https.HttpsError(
      'not-found',
      `We didn't find the target user: ${userId}.`
    );
  }

  // Exit if not an image file.
  const contentType = objectMeta.contentType || '';

  if (!contentType.includes('image')) {
    console.info(`Exiting function => existing image or non-file image: ${filepath}`);
    return false;
  }

  const imageFile = adminApp.storage()
  .bucket()
  .file(storageUrl);

  if (!await imageFile.exists()) {
    throw new functions.https.HttpsError(
      'not-found',
      `This file doesn't not exist. filename: ${filename} | filepath: ${filepath}.`
    );
  }

  await imageFile.makePublic()

  const extension = objectMeta.metadata?.extension ||
  filename.substring(filename.lastIndexOf('.')).replace('.', '');

  const downloadToken = objectMeta.metadata?.firebaseStorageDownloadTokens ?? '';

  const firebaseDownloadUrl = createPersistentDownloadUrl(
    objectMeta.bucket, 
    filepath, downloadToken,
  );

  const dimensions: ISizeCalculationResult = await getDimensionsFromStorage(
    objectMeta, 
    filename, 
    filepath,
  );

  const directoryPath: string = `users/${userId}/profile/picture/`
  await cleanProfilePictureDir(directoryPath, filepath)

  return await adminApp.firestore()
    .collection('users')
    .doc(userId)
    .update({
      profilePicture: {
        dimensions: {
          height: dimensions.height ?? 0,
          width: dimensions.width ?? 0,
        },
        extension,
        path: {
          edited: '',
          original: filepath,
        },
        size: parseFloat(objectMeta.size),
        type: dimensions.type ?? '',
        updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
        url: {
          edited: '',
          original: firebaseDownloadUrl,
          storage: storageUrl,
        },
      },
    });
}

/**
 * Clean profile picture directory (from Cloud Storage).
 * @param directoryPath Directory to clean.
 * @param filePathToKeep File's path to NOT delete.
 */
async function cleanProfilePictureDir(directoryPath: string, filePathToKeep: string) {
  const dir = await adminApp.storage()
  .bucket()
  .getFiles({
    directory: directoryPath,
  });

  const files = dir[0];

  for await (const file of files) {
    if (file.name !== filePathToKeep) {
      await file.delete();
    }
  }
}

/**
 * Calculate image dimensions.
 * @param objectMeta Storage object uploaded.
 * @param filename File's name.
 * @param filepath File's path.
 * @returns Return image dimensions.
 */
async function getDimensionsFromStorage(
  objectMeta: functions.storage.ObjectMetadata,
  filename: string,
  filepath: string,
) {
  const bucket = gcs.bucket(objectMeta.bucket);

  const workingDir = join(tmpdir(), 'thumbs');
  const tmpFilePath = join(workingDir, filename);

  // 1. Ensure directory exists.
  await fs.ensureDir(workingDir);

  // 2. Download source file.
  await bucket.file(filepath).download({
    destination: tmpFilePath,
  });

  // 2.1. Try calculate dimensions.
  let dimensions: ISizeCalculationResult = { height: 0, width: 0 };

  try {
    dimensions = sizeOf.imageSize(tmpFilePath);
  } catch (error) {
    console.error(error);
  }

  // 5. Clean up the tmp/thumbs from file system.
  await fs.emptyDir(workingDir)
  await fs.remove(workingDir);

  return dimensions;
}
