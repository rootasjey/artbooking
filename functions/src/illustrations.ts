import { Storage } from '@google-cloud/storage';
import * as functions from 'firebase-functions';
// @ts-ignore
import * as fs  from 'fs-extra';
import sizeOf = require('image-size');
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import * as sharp from 'sharp';

import { adminApp } from './adminApp';
import {
  allowedLicenseTypes,
  ART_MOVEMENTS_COLLECTION_NAME,
  BASE_DOCUMENT_NAME,
  checkVisibilityValue,
  cloudRegions,
  ILLUSTRATIONS_COLLECTION_NAME,
  ILLUSTRATION_STATISTICS_COLLECTION_NAME,
  STORAGES_DOCUMENT_NAME,
  USERS_COLLECTION_NAME,
  USER_STATISTICS_COLLECTION_NAME
} from './utils';

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
    const { illustration_id } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof illustration_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [illustration_id] argument (string)
         which is the illustration's id to delete.`,
      );
    }

    const illustrationSnapshot = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(illustration_id)
      .get();

    const illustrationData = illustrationSnapshot.data();
    if (!illustrationSnapshot.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${illustration_id}] doesn't exist.`,
      );
    }

    const links = illustrationData.links;
    const illustrationWidth = illustrationData.dimensions.width;
    const illustrationHeight = illustrationData.dimensions.height;

    const dimensionsAreNumbers = typeof illustrationWidth === 'number' && typeof illustrationHeight === 'number';
    const dimensionsAreStrictlyPositive = illustrationWidth > 0 && illustrationHeight > 0;
    const dimensionsAreOK = dimensionsAreNumbers && dimensionsAreStrictlyPositive;

    if (links.original && links.storage && dimensionsAreOK) {
      return {
        success: false,
        message: `Nothing to change. Everything is up-to-date.`,
        illustration: {
          id: illustration_id,
        },
      };
    }

    const dir = await adminApp.storage()
      .bucket()
      .getFiles({
        directory: `users/${userAuth.uid}/illustrations/${illustration_id}`
      });

    let storagePath: string = '';
    const files = dir[0];

    if (!files || files.length === 0) {
      await illustrationSnapshot.ref.delete();

      return {
        success: false,
        illustration: {
          id: illustration_id,
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
    let originalLink = '';
    const downloadToken = metadata.metadata?.firebaseStorageDownloadTokens ?? '';

    for await (const file of files) {
      const atIndex = file.name.lastIndexOf('@');
      const dotIndex = file.name.lastIndexOf('.');
      const sizeStr = file.name.substring(atIndex + 1, dotIndex);

      const bucketName = file.bucket.name
      const link = createPersistentDownloadUrl(bucketName, file.name, downloadToken)

      if (atIndex > -1) { // thumbnails
        thumbnails[`t${sizeStr}`] = link;
      } else { // original image
        originalLink = link
        storagePath = file.name || '';
      }
    }

    const { height, width, type: extension } = await getDimensionsFromUrl(originalLink);

    await illustrationSnapshot.ref.update({
      dimensions: {
        height,
        width,
      },
      extension,
      links: {
        original: originalLink,
        storage: storagePath,
        thumbnails,
      },
      size: parseFloat(metadata.size),
    });

    return {
      success: true,
      illustration: {
        id: illustration_id,
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
    const { name, visibility } = params;

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

    checkVisibilityValue(visibility);
    const user_custom_index = await getNextIllustrationIndex(userAuth.uid)

    const illustrationSnap = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .add({
        art_movements: {},
        created_at: adminApp.firestore.Timestamp.now(),
        description: '',
        dimensions: {
          height: 0,
          width: 0,
        },
        extension: '',
        license: {
          id: '',
          type: '',
        },
        links: {
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
        lore: '',
        name: name,
        pegi: {
          content_descriptors: {
            bad_language: false,
            discrimination: false,
            drug: false,
            fear: false,
            sex: false,
            violence: false,
          },
          rating: -1,
          updated_at: adminApp.firestore.Timestamp.now(),
          user_id: '',
        },
        size: 0, // File's ize in bytes
        staff_review: {
          approved: false,
          updated_at: adminApp.firestore.Timestamp.now(),
          user_id: '',
        },
        timelapse: {
          created_at: null,
          description: '',
          links: {
            original: '', // video or gif format
          },
          name: '',
          updated_at: null,
        },
        topics: {},
        updated_at: adminApp.firestore.Timestamp.now(),
        user_custom_index,
        user_id: userAuth.uid,
        version: 0,
        visibility: visibility,
      });

    await createStatsCollection(illustrationSnap.id, userAuth.uid);
    
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
    const { illustration_id } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof illustration_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [illustration_id] argument (string) ` +
         ` which is the illustration's id to delete.`,
        );
    }

    const illustrationSnap = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(illustration_id)
      .get();

    const illustrationData = illustrationSnap.data();
    if (!illustrationSnap.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${illustration_id}] doesn't exist.`,
      );
    }

    if (illustrationData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    // Delete files from Cloud Storage
    const dir = await adminApp.storage()
      .bucket()
      .getFiles({
        directory: `users/${userAuth.uid}/illustrations/${illustration_id}`
      });

    const files = dir[0];
    for await (const file of files) {
      await file.delete();
    }

    await illustrationSnap.ref.delete();

    return {
      illustration: {
        id: illustration_id,
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
    const { illustration_ids } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (!Array.isArray(illustration_ids) || illustration_ids.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [illustration_ids] ` +
         `which is an array of illustrations string id to delete.`,
      );
    }

    /** How many operations succeeded. */
    let successCount = 0;
    const itemsProcessed = [];
    
    for await (const illustration_id of illustration_ids) {
      try {
        const illustrationSnapshot = await firestore
          .collection(ILLUSTRATIONS_COLLECTION_NAME)
          .doc(illustration_id)
          .get();

        const illustrationData = illustrationSnapshot.data();
        let errorMessage = '';

        if (!illustrationSnapshot.exists || !illustrationData) {
          errorMessage = `The illustration [${illustration_ids}] doesn't exist.`

          itemsProcessed.push({
            illustration: {
              id: illustration_id,
            },
            success: false,
            errorMessage,
          });

          throw new functions.https.HttpsError(
            'not-found',
            errorMessage,
          )
        }

        if (illustrationData.user_id !== userAuth.uid) {
          errorMessage = `You don't have the permission ` +
            `to delete the illustration ${illustration_id}.`;

          itemsProcessed.push({
            illustration: {
              id: illustration_id,
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
            directory: `users/${userAuth.uid}/illustrations/${illustration_id}`
          });

        const files = dir[0];
        for await (const file of files) {
          await file.delete();
        }

        await illustrationSnapshot.ref.delete();
        successCount++;

        itemsProcessed.push({
          illustration: {
            id: illustration_id,
          },
          success: true,
        });

      } catch (error) {
        console.error(`Error while deleting illustration [${illustration_id}]`);
        console.error(error);
      }
    }

    return {
      items: itemsProcessed,
      successCount,
      hasErrors: successCount === illustration_ids.length,
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
    if (target === 'profile_picture') {
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
    const illustrationSnapshot = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(firestoreId)
      .get();

    const illustrationData = illustrationSnapshot.data()
    if (!illustrationSnapshot.exists || !illustrationData || illustrationData.user_id !== userId) {
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

    const downloadToken = objectMeta.metadata?.firebaseStorageDownloadTokens ?? '';
    const firebaseDownloadUrl = createPersistentDownloadUrl(
      objectMeta.bucket,
      filepath, 
      downloadToken,
    );

    let version: number = illustrationData.version ?? 0;
    if (typeof version !== 'number') { version = 0 }
    version += 1;

    // Save new properties to Firestore.
    await illustrationSnapshot.ref
      .update({
        dimensions: {
          height,
          width,
        },
        extension,
        links: {
          original: firebaseDownloadUrl,
          storage: storageUrl,
          thumbnails,
        },
        size: parseFloat(objectMeta.size),
        updated_at: adminApp.firestore.Timestamp.now(),
        version,
      });

    // Skip update used storage if we're updating the image file
    // (crop, rotate, flip).
    if (version > 1) {
      return true;
    }
    
    // Update user's storage.
    // ----------------------
    const statsSnapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(userId)
      .collection(USER_STATISTICS_COLLECTION_NAME)
      .doc(STORAGES_DOCUMENT_NAME)
      .get()

    const statisticsData = statsSnapshot.data()
    if (!statsSnapshot.exists || !statisticsData) { 
      return 
    }

    let used: number = statisticsData.illustrations.used ?? 0
    if (typeof used !== 'number') { used = 0 }
    used += parseFloat(objectMeta.size)

    return await statsSnapshot.ref.update({
      illustrations: {
        used,
        updated_at: adminApp.firestore.Timestamp.now(),
      },
    })
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

    const { illustration_id } = data;

    const illusSnapshot = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(illustration_id)
      .get();

    const illustrationData = illusSnapshot.data();
    if (!illusSnapshot.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `Sorry we didn't find the illustration ${illustration_id}. ` +
        `It may have been deleted.`,
      )
    }

    if (illustrationData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await illusSnapshot.ref.update({
      license: {
        id: '',
        type: '',
      },
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    return {
      illustration: {
        id: illustration_id,
      },
      success: true,
    };
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

    const { illustration_id, license } = data;
    checkIllustrationLicenseFormat(license);

    const illustrationSnapshot = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(illustration_id)
      .get();

    const illustrationData = illustrationSnapshot.data();
    if (!illustrationSnapshot.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `Sorry we didn't find the illustration `+
        `you're trying to update. It may have been deleted.`,
      )
    }

    if (illustrationData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await illustrationSnapshot.ref.update({
      license: {
        id: license.id ?? '',
        type: license.type ?? '',
      },
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    return {
      illustration: {
        id: illustration_id,
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
      illustration_id,
      name,
      lore,
    } = data;

    const illustrationSnapshot = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(illustration_id)
      .get();

    const illustrationData = illustrationSnapshot.data();
    if (!illustrationSnapshot.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration [${illustration_id}] doesn't exist.`,
      );
    }

    if (illustrationData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await illustrationSnapshot.ref.update({
      description,
      name,
      lore,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    return {
      illustration: {
        id: illustration_id,
      },
      success: true,
    }
  });

/**
 * Update illustration's art movements.
 * Art movements are pre-defined (by staff) and are limited to 5.
 */
export const updateArtMovements = functions
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
    
    const { art_movements: art_movements_data, illustration_id } = data;
    
    if (typeof illustration_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called  with a valid [illustration_id]
         argument which is the illustration's id.`,
      );
    }
    
    if (!Array.isArray(art_movements_data)) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called  with a valid [art_movements]
         argument which is an array of string.`,
      );
    }
    
    if (art_movements_data.length > 5) {
      throw new functions.https.HttpsError(
        'out-of-range',
        `Please use no more than 5 art_movements. ` +
        `You provided ${art_movements_data.length} art_movements.`,
      )
    }

    const illustrationSnapshot = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(illustration_id)
      .get();

    const illustrationData = illustrationSnapshot.data();
    if (!illustrationSnapshot.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration [${illustration_id}] doesn't exist.`,
      );
    }

    if (illustrationData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to update this illustration.`,
      );
    }

    const art_movements: Record<string, boolean> = {};
    for await (const art_movement of art_movements_data) {
      const artMovementSnapshot = await firestore
        .collection(ART_MOVEMENTS_COLLECTION_NAME)
        .doc(art_movement)
        .get()

      if (artMovementSnapshot.exists) {
        art_movements[art_movement] = true;
      }
    }

    await illustrationSnapshot.ref.update({ 
      art_movements,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    return { 
      illustration: {
        id: illustration_id,
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

    const { topics, illustration_id } = data;

    if (typeof illustration_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [illustration_id] ` +
         `argument which is the illustration's id.`,
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
    
    const illustrationSnapshot = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(illustration_id)
      .get();

    const illustrationData = illustrationSnapshot.data();
    if (!illustrationSnapshot.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${illustration_id}] doesn't exist.`,
      );
    }

    if (illustrationData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    const topicsMap: Record<string, boolean> = {};
    for (const topic of topics) {
      topicsMap[topic] = true;
    }

    await illustrationSnapshot.ref.update({ 
      topics: topicsMap,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    return {
      illustration: {
        id: illustration_id,
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

    const { illustration_id, visibility } = data;

    if (typeof illustration_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [illustration_id] `+
         `argument which is the illustration's id.`,
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

    const illustrationSnapshot = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(illustration_id)
      .get();

    const illustrationData = illustrationSnapshot.data();

    if (!illustrationSnapshot.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration id [${illustration_id}] doesn't exist.`,
      );
    }

    if (illustrationData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to edit this illustration.`,
      );
    }

    await illustrationSnapshot.ref.update({ 
      visibility, 
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    return {
      illustration: {
        id: illustration_id,
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
       [description], [illustration_id], [name], [lore] parameters.`,
    );
  }

  const { 
    description,
    illustration_id,
    name,
    lore,
  } = data;

  if (typeof description !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid
       [description] parameter which is the illustration's description.`,
      );
  }

  if (typeof illustration_id !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid [illustration_id] ` +
       `parameter which is the illustration's id.`,
    );
  }

  if (typeof name !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid [name] ` +
       `parameter which is the illustration's name.`,
    );
  }

  if (typeof lore !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      `The function must be called with a valid [lore] ` +
       `parameter which is the illustration's lore.`,
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
 * Create illustration's stats sub-collection
 * @param illustrationId Illustration's id.
 * @returns void.
 */
 async function createStatsCollection(illustrationId: string, user_id: string) {
  const snapshot = await firestore
    .collection(ILLUSTRATIONS_COLLECTION_NAME)
    .doc(illustrationId)
    .get();

  if (!snapshot.exists) {
    return;
  }

  await snapshot.ref
    .collection(ILLUSTRATION_STATISTICS_COLLECTION_NAME)
    .doc(BASE_DOCUMENT_NAME)
    .create({
      downloads: 0,
      illustration_id: illustrationId,
      likes: 0,
      shares: 0,
      views: 0,
      user_id: '',
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });
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
  for await (const upResp of uploadResponses) {
    const upFile = upResp[0];
    let key = upFile.name.split('/').pop() || '';
    key = key.substring(0, key.lastIndexOf('.')).replace('thumb@', 't');

    const metadataResponse = await upFile.getMetadata();
    const metadata = metadataResponse[0];
    
    const downloadToken = metadata.metadata?.firebaseStorageDownloadTokens ?? '';
    const firebaseDownloadUrl = createPersistentDownloadUrl(
      objectMeta.bucket, 
      filepath, 
      downloadToken,
    );
      
    thumbnails[key] = firebaseDownloadUrl;
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

async function getNextIllustrationIndex(userId: string) {
  const userIllustrationStatsSnapshot = await firestore
    .collection(USERS_COLLECTION_NAME)
    .doc(userId)
    .collection(USER_STATISTICS_COLLECTION_NAME)
    .doc(ILLUSTRATIONS_COLLECTION_NAME)
    .get()

  const userIllustrationStatsData = userIllustrationStatsSnapshot.data()
  if (!userIllustrationStatsSnapshot.exists || !userIllustrationStatsData) {
    return 0
  }

  let userIllustrationCreated: number = userIllustrationStatsData.created ?? 0
  userIllustrationCreated = typeof userIllustrationCreated === 'number' ? userIllustrationCreated + 1 : 1
  return userIllustrationCreated
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
    filepath, 
    downloadToken,
  );

  const dimensions: ISizeCalculationResult = await getDimensionsFromStorage(
    objectMeta, 
    filename, 
    filepath,
  );

  const directoryPath: string = `users/${userId}/profile/picture/`
  await cleanProfilePictureDir(directoryPath, filepath)

  return await adminApp.firestore()
    .collection(USERS_COLLECTION_NAME)
    .doc(userId)
    .update({
      profile_icture: {
        dimensions: {
          height: dimensions.height ?? 0,
          width: dimensions.width ?? 0,
        },
        extension,
        links: {
          edited: '',
          original: firebaseDownloadUrl,
          storage: storageUrl,
        },
        size: parseFloat(objectMeta.size),
        type: dimensions.type ?? '',
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
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
