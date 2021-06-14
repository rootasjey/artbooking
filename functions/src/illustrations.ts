import { Storage } from '@google-cloud/storage';
import * as functions from 'firebase-functions';
// @ts-ignore
import * as fs  from 'fs-extra';
const sizeOf = require('image-size');
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import * as sharp from 'sharp';

import { adminApp } from './adminApp';
import { allowedLicenseFromValues, checkOrGetDefaultVisibility, cloudRegions } from './utils';

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
export const createOne = functions
  .region(cloudRegions.eu)
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
        visibility: checkOrGetDefaultVisibility(params.visibility),
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
 * Delete multiple illustrations documents from Firestore and from Cloud Storage.
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
            illustrationId,
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
            illustrationId,
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
          illustrationId,
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

    if (!illusSnap || !illusSnap.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        `Sorry we didn't find the illustration you're trying to update. It may have been deleted.`
      )
    }

    await illusSnap.ref.update({
      license: {
        from: license.from ?? '',
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
      `You must specify an object, and it should have a [from] property which is a string, ` + 
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

  if (typeof data.from !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The license data you provided has the property [license.from] = ${data.from} - ` +
      `which is not an string. ` +
      `The property [from] must be a string ` + 
      `among these values: ${allowedLicenseFromValues.join(", ")}`,
    )
  }

  if (allowedLicenseFromValues.includes(data.from)) {
    return;
  }

  throw new functions.https.HttpsError(
    'invalid-argument',
    `The value provided for [from] parameter is not valid. ` +
    `Allowed values are: ${allowedLicenseFromValues.join(", ")}`,
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
    case "unulisted":
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
