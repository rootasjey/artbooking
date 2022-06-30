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
  BookCoverMode,
  BOOKS_COLLECTION_NAME,
  checkVisibilityValue,
  cloudRegions,
  ILLUSTRATIONS_COLLECTION_NAME,
  ILLUSTRATION_STATISTICS_COLLECTION_NAME,
  STORAGES_DOCUMENT_NAME,
  TASKS_COLLECTION_NAME,
  USERS_COLLECTION_NAME,
  USER_STATISTICS_COLLECTION_NAME
} from './utils';

import https = require('https');
import { ISizeCalculationResult } from 'image-size/dist/types/interface';

const firestore = adminApp.firestore();
const gcs = new Storage();

const ILLUSTRATION_DOC_PATH = "illustrations/{illustration_id}"

interface GenerateImageThumbsParams {
  extension: string;
  filename: string;
  filepath: string;
  objectMeta: functions.storage.ObjectMetadata;
  visibility: string;
}

/**
 * Update illustration's `staff_review.approved` field.
 * This field allow a illustration to be displayed in public space according to EULA (CGU).
 */
 export const approve = functions
 .region(cloudRegions.eu)
 .https
 .onCall(async (params: ApproveIllustrationParams, context) => {
   const userAuth = context.auth
   const { illustration_id, approved } = params

   if (!userAuth) {
     throw new functions.https.HttpsError(
       'unauthenticated',
       `The function must be called from an authenticated user.`,
     );
   }

   if (typeof illustration_id !== 'string') {
     throw new functions.https.HttpsError(
       'invalid-argument', 
       `The function must be called with a valid [illustration_id] parameter ` +
       `(string) which is the illustration's id.`,
     );
   }

   if (typeof approved !== 'boolean') {
     throw new functions.https.HttpsError(
       'invalid-argument', 
       `The function must be called with a valid [approved] parameter ` +
       `(boolean) indicating if this illustration must be approved or not.`,
     );
   }

   const userSnapshot = await firestore
     .collection("users")
     .doc(userAuth.uid)
     .get()

   const userData = userSnapshot.data()
   if (!userSnapshot.exists || !userData) {
     throw new functions.https.HttpsError(
       'permission-denied',
       `You have no permission to perform this action.`
     )
   }

   const manageReview: boolean = userData.rights['user:manage_reviews']
   if (!manageReview) {
     throw new functions.https.HttpsError(
       'permission-denied',
       `You have no permission to perform this action.`
     )
   }

   const illustrationSnapshot = await firestore
     .collection("illustrations")
     .doc(illustration_id)
     .get()

   const illustrationData = illustrationSnapshot.data()
   if (!illustrationSnapshot.exists || !illustrationData) {
     throw new functions.https.HttpsError(
       'not-found',
       `The target illustration [${illustration_id}] does not exist. ` +
       `It may have beend deleted.`,
     )
   }

   await illustrationSnapshot.ref.update({ 
      staff_review: {
        approved: approved,
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
        user_id: userAuth.uid,
      },
    })

   return {
     illustration: { id: illustration_id },
     success: true,
     user: { id: userAuth.uid },
     error: {},
   }
 })

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

    const thumbnails: ThumbnailLinks = {
      xs: '',
      s: '',
      m: '',
      l: '',
      xl: '',
      xxl: '',
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
        thumbnails[`${sizeStr}`] = link;
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
            xs: '',
            s: '',
            m: '',
            l: '',
            xl: '',
            xxl: '',
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
        "unauthenticated", 
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof illustration_id !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument", 
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
        "not-found",
        `The illustration id [${illustration_id}] doesn't exist.`,
      );
    }

    if (illustrationData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        "permission-denied",
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
 * Return a signed URL to download an illustration. 
 * It expires after 5 min. 
 **/
export const getSignedUrl = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: DeleteIllustrationParams, context) => {
    const { illustration_id } = params;
    const userAuth = context.auth;
    
    if (typeof illustration_id !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument", 
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
        "not-found",
        `The illustration id [${illustration_id}] doesn't exist.`,
        );
      }
    
    if (illustrationData.visibility !== "public") {
      console.log("illustration not public");
      if (!userAuth) {
        throw new functions.https.HttpsError(
          "unauthenticated", 
          `The function must be called from an authenticated user.`,
          );
        }
      
      if (illustrationData.user_id !== userAuth.uid) {
        throw new functions.https.HttpsError(
          "permission-denied",
          `You don't have the permission to edit this illustration.`,
          );
        }
    }
  
    const storagePath: string = illustrationData.links.storage
    const bucket = adminApp.storage().bucket();
    
    const [url] = await bucket
    .file(storagePath)
    .getSignedUrl({
      version: "v4",
      action: "read",
      expires: Date.now() + 1000 * 60 * 5, // 5 minutes
    });
  
    return {
      success: true,
      url,
    }
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

    const { file_type, firestore_id, visibility, target } = customMetadata;

    if (file_type === "profile_picture" && target === "profile_picture") {
      return await setUserProfilePicture(objectMeta);
    }

    if (file_type === "book_cover" && target === "book") {
      return setBookCover(objectMeta);
    }
    
    if (file_type !== "illustration") {
      return;
    }

    const filepath = objectMeta.name || '';
    const filename = filepath.split('/').pop() || '';
    const storageUrl = filepath;
    
    const endIndex: number = filepath.indexOf("/illustrations")
    const userId = filepath.substring(6, endIndex)
    if (!firestore_id || !userId) { return; }

    // Exit if thumbnail or not an image file.
    const contentType = objectMeta.contentType || '';

    if (filename.includes("thumb@") || !contentType.includes("image")) {
      return false;
    }

    // Check if same user as firestore illustration
    const illustrationSnapshot = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(firestore_id)
      .get();

    const illustrationData = illustrationSnapshot.data()
    if (!illustrationSnapshot.exists || !illustrationData || illustrationData.user_id !== userId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        `It seems that the user ${userId} is trying to access a forbidden document.`,
      )
    }

    const imageFile = adminApp.storage()
      .bucket()
      .file(storageUrl);

    if (!await imageFile.exists()) {
      console.error("file does not exist")
      return;
    }

    // -> Start to process the image file.
    if (visibility === "public") {
      await imageFile.makePublic();
    }

    const extension = objectMeta.metadata?.extension ||
      filename.substring(filename.lastIndexOf("."));

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
    if (typeof version !== "number") { version = 0 }
    version += 1;

    let previousSize: number = 0;
    if (version > 1) {
      previousSize = parseFloat(illustrationData.size);
    }

    await illustrationSnapshot.ref
      .update({
        dimensions: {
          height,
          width,
        },
        extension,
        links: {
          illustration_id: illustrationSnapshot.id,
          original: firebaseDownloadUrl,
          storage: storageUrl,
          thumbnails,
        },
        size: parseFloat(objectMeta.size),
        updated_at: adminApp.firestore.Timestamp.now(),
        version,
      });

    await checkBookCoverTasks(illustrationSnapshot.id);
    
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
    if (typeof used !== "number") { used = 0 }
    used += parseFloat(objectMeta.size)

    if (version > 1) {
      used -= previousSize;
    }

    return await statsSnapshot.ref.update({
      illustrations: {
        used,
        updated_at: adminApp.firestore.Timestamp.now(),
      },
    })
  });

/** 
 * Event handler on illustration doc updates.
 * Check if visibility has been updated to a more restricted value 
 * (e.g. from another value than `public`).
 * If so, force `firebaseStorageDownloadTokens` regeneration for security issue.
 * 
 * (cf.: https://www.sentinelstand.com/article/guide-to-firebase-storage-download-urls-tokens)
 * 
 * (cf.: https://github.com/googleapis/nodejs-storage/issues/697#issuecomment-610603232)
 **/
export const onVisibilityUpdate = functions
.region(cloudRegions.eu)
.firestore
.document(ILLUSTRATION_DOC_PATH)
.onUpdate(async (snapshot) => {
  const beforeData = snapshot.before.data();
  const afterData = snapshot.after.data();

  if (beforeData.visibility === afterData.visibility) {
    return;
  }

  if (afterData.visibility === "public") {
    return;
  }

  // Force Firebase/GCP to regenerate download token.
  const storagePath: string = afterData.links.storage
  const bucket = adminApp.storage().bucket();
  
  await bucket
  .file(storagePath)
  .setMetadata({
    metadata: {
      // Delete the download token. 
      // A new one will be generated when attempting to download the illustration.
      firebaseStorageDownloadTokens: null,
    },
  });
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

/** Check if the thumbnail generation has an associated book cover task. */
async function checkBookCoverTasks(illustrationId: string) {
  const taskSnapshot = await firestore
    .collection(TASKS_COLLECTION_NAME)
    .where("name", "==", "illustration_thumbnail_generation_book_cover")
    .where("target.illustration_id", "==", illustrationId)
    .get();

  for await (const taskDoc of taskSnapshot.docs) {
    const taskData = taskDoc.data();
    const bookSnapshot = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .doc(taskData.target.book_id)
      .get();

    const bookData = bookSnapshot.data();
    if (!taskDoc.exists || !taskData || !bookSnapshot.exists || !bookData) {
      console.log(
        `⚠️ Warning: Found a task with an unexisting book'id ` + 
        `(${taskData.target.book_id}). Deleting this task`
      );
      
      await taskDoc.ref.delete();
      continue;
    }

    const illustrationSnapshot = await firestore
    .collection(ILLUSTRATIONS_COLLECTION_NAME)
    .doc(illustrationId)
    .get();

    const illustrationData = illustrationSnapshot.data();
    if (!illustrationSnapshot.exists || !illustrationData) {
      console.log(
        `⚠️ Warning: Found a task with an unexisting illustration'id ` + 
        `(${taskData.target.illustration_id}). Deleting this task`
      );
      
      await taskDoc.ref.delete();
      return;
    }

    await bookSnapshot.ref.update({
      cover: {
        links: illustrationData.links,
        mode: bookData.cover?.mode,
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      },
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    await taskDoc.ref.delete();
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

  const thumbnails: ThumbnailLinks = {
    xs: '',
    s: '',
    m: '',
    l: '',
    xl: '',
    xxl: '',
  };

  const thumbnailSizes = {
    xs: 360,
    s: 480,
    m: 720,
    l: 1024,
    xl: 1920,
    xxl: 2400,
  }

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
  const uploadPromises = Object.entries(thumbnailSizes)
    .map(async ([sizeName, size]) => {
      const thumbName = `thumb@${sizeName}.${extension}`;
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
    key = key.substring(0, key.lastIndexOf('.')).replace('thumb@', '');

    const metadataResponse = await upFile.getMetadata();
    const metadata = metadataResponse[0];
    
    const downloadToken = metadata.metadata?.firebaseStorageDownloadTokens ?? '';
    const firebaseDownloadUrl = createPersistentDownloadUrl(
      objectMeta.bucket,  
      upFile.name,
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

async function setBookCover(objectMeta: functions.storage.ObjectMetadata) {
  const customMetadata = objectMeta.metadata;
  if (!customMetadata) { return; }

  const { book_id, visibility } = customMetadata;

  const filepath = objectMeta.name || "";
  const filename = filepath.split("/").pop() || "";
  const storageUrl = filepath;
  
  const endIndex: number = filepath.indexOf("/books")
  const userId = filepath.substring(6, endIndex)
  
  if (!userId || !book_id) { return; }

  // Exit if thumbnail or not an image file.
  const contentType = objectMeta.contentType || "";
  if (filename.includes("thumb@") || !contentType.includes("image")) {
    return;
  }
  
  const bookSnap = await firestore
    .collection("books")
    .doc(book_id)
    .get();

  if (!bookSnap.exists) {
    return;
  }

  const imageFile = adminApp.storage()
    .bucket()
    .file(storageUrl);

  if (!await imageFile.exists()) {
    console.error("file does not exist")
    return;
  }

  // -> Start to process the image file.
  if (visibility === "public") {
    await imageFile.makePublic();
  }

  const extension = objectMeta.metadata?.extension ||
    filename.substring(filename.lastIndexOf("."));

  // Generate thumbnails
  // -------------------
  const { thumbnails } = await generateImageThumbs({
    extension,
    filename,
    filepath,
    objectMeta,
    visibility,
  });

  const downloadToken = objectMeta.metadata?.firebaseStorageDownloadTokens ?? "";
  const firebaseDownloadUrl = createPersistentDownloadUrl(
    objectMeta.bucket,
    filepath, 
    downloadToken,
  );

  await bookSnap.ref
    .update({
      cover: {
        mode: BookCoverMode.uploadedCover,
        links: {
          illustration_id: "",
          original: firebaseDownloadUrl,
          share: { read: "", write: "" },
          storage: storageUrl,
          thumbnails,
        },
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      },
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    })
}
