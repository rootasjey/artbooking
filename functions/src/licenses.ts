import * as functions from 'firebase-functions';
// @ts-ignore
import * as fs from 'fs-extra';

import { adminApp } from './adminApp';
import { allowedLicenseFromValues as allowedLicenseTypes, cloudRegions } from './utils';

const firestore = adminApp.firestore();

/**
 * Create one license (to apply to an illustration/artwork).
 * The created license must either be global (available to all users)
 * or to a specific user (only avaliable to them).
 * NOTE: Only staff members can create global licenses.
 */
export const createOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: CreateOneLicenseParams, context) => {
    const userAuth = context.auth;
    const { license } = params;
    const type: string = license?.type

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof license !== 'object') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [license] argument. ` +
        `You provided ${license}.`
      )
    }

    if (typeof type !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [license.type] parameter ` +
        `which tells if the license is created by a staff member (and is available for all users) ` +
        `or if it's created by an author (and is user specific).` +
        `The property [type] must be a string ` +
        `among these values: ${allowedLicenseTypes.join(", ")}. ` +
        `You provided ${type} which is not valid.`,
      );
    }

    if (!allowedLicenseTypes.includes(type)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The value provided for [type] parameter is not valid. ` +
        `Allowed values are: ${allowedLicenseTypes.join(", ")}`,
      );
    }

    if (type === 'staff') {
      await canManageLicense(userAuth.uid);
    }

    const formatedLicense = formatLicense(license);
    formatedLicense.createdBy.id = userAuth.uid;

    const createdLicense = type === 'staff' 
      ? await createStaffLicense(formatedLicense)
      : await createUserLicense(formatedLicense, userAuth.uid);

    return {
      license: {
        id: createdLicense.id
      },
      success: true,
    };
  });

/**
 * Delete one existing license.
 * The target license can be global or user specific.
 * NOTE: Only admin can delete global license.
 */
export const deleteOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: DeleteOneLicenseParams, context) => {
    const userAuth = context.auth;
    const { type, licenseId } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof type !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [type] parameter ` +
        `which tells if the license is created by a staff member (and is available for all users) ` +
        `or if it's created by an author (and is user specific).` +
        `The property [type] must be a string ` +
        `among these values: ${allowedLicenseTypes.join(", ")}. `, +
        `You provided ${type} which is not valid.`,
      );
    }

    if (!allowedLicenseTypes.includes(type)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The value provided for [type] parameter is not valid. ` +
        `Allowed values are: ${allowedLicenseTypes.join(", ")}`,
      );
    }
    
    type === 'staff'
     ? await deleteStaffLicense(licenseId, userAuth.uid)
     : await deleteUserLicense(licenseId, userAuth.uid);

    return {
      license: {
        id: licenseId,
      },
      success: true,
    };
  });

/**
 * Update one existing license.
 * The target license can be global or user specific.
 * NOTE: Only admin can update global license.
 */
export const updateOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: CreateOneLicenseParams, context) => {
    const userAuth = context.auth;
    const { license } = params;
    const type: string = license?.type

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof type !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [type] parameter ` +
        `which tells if the license is created by a staff member (and is available for all users) ` +
        `or if it's created by an author (and is user specific).` +
        `The property [type] must be a string ` +
        `among these values: ${allowedLicenseTypes.join(", ")}. ` +
        `You provided ${type} which is not valid.`,
      );
    }

    if (!allowedLicenseTypes.includes(type)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The value provided for [type] parameter is not valid. ` +
        `Allowed values are: ${allowedLicenseTypes.join(", ")}`,
      );
    }

    if (type === 'staff') {
      await canManageLicense(userAuth.uid);
    }

    const formatedLicense = formatLicense(license);
    const licenseId = formatedLicense.id;
    
    formatedLicense.updatedBy.id = userAuth.uid;
    formatedLicense.updatedAt = adminApp.firestore.FieldValue.serverTimestamp()

    if (!licenseId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The updateOne(...) function must be called with a [license] parameter ` +
        `which have to exist. The license you provided doesn't have a valid [id] value. ` +
        `Its id value is: [${licenseId}]`,
      )
    }

    type === 'staff' 
      ? await updateStaffLicense(formatedLicense)
      : await updateUserLicense(formatedLicense, userAuth.uid);

    return {
      license: {
        id: formatedLicense.id,
      },
      success: true,
    };
  })

// ----------------
// Helper functions
// ----------------

/**
 * Create a global (app) license.
 * This new license will be available to all users.
 * @param formatedLicense License's data to create.
 * @returns Created license.
 */
async function createStaffLicense(formatedLicense: License) {
  return await firestore
    .collection('licenses')
    .add(formatedLicense);
}

/**
 * Create a license for a specific user.
 * @param formatedLicense License's data to create.
 * @param userId User performing the creation.
 * @returns Created license.
 */
async function createUserLicense(formatedLicense: License, userId: string) {
  return await firestore
    .collection('users')
    .doc(userId)
    .collection('licenses')
    .add(formatedLicense);
}

/**
 * Update a global license.
 * This action must be performed by an admin.
 * @param formatedLicense License's data to update.
 * @returns Updated license.
 */
async function updateStaffLicense(formatedLicense: License) {
  const doc = firestore
  .collection('licenses')
  .doc(formatedLicense.id);

  const snapshot = await doc.get();
  const data = snapshot.data();
  if( !data) {
    throw new functions.https.HttpsError(
      'not-found', 
      `Sorry, we didn't find the target document to update. ` +
      `It may have been deleted.`,
    )
  }

  formatedLicense.createdAt = data.createdAt;
  return await doc.update(formatedLicense);
}

/**
 * Update a license for a specific user.
 * @param formatedLicense License's data to update.
 * @param userId User performing the update.
 * @returns Updated license.
 */
async function updateUserLicense(formatedLicense: License, userId: string) {
  const doc = firestore
  .collection('users')
    .doc(userId)
    .collection('licenses')
    .doc(formatedLicense.id)

  const snapshot = await doc.get();
  const data = snapshot.data();
  if( !data) {
    throw new functions.https.HttpsError(
      'not-found', 
      `Sorry, we didn't find the target document to update. ` +
      `It may have been deleted.`,
    )
  }

  formatedLicense.createdAt = data.createdAt;
  return await doc.update(formatedLicense);
}

/**
 * Return true if the target user can manage staff licenses.
 */
async function canManageLicense(userId: string) {
  const userSnap = await firestore
    .collection('users')
    .doc(userId)
    .get();

  const userData = userSnap.data();

  if (!userSnap.exists || !userData) {
    throw new functions.https.HttpsError(
      'not-found',
      `User's data for the id [${userId}] not found. ` + 
      `This user's data may have been deleted.`,
    );
  }

  const rights = userData['rights'];
  const manageLicenseRight: boolean = rights['user:managelicense'];

  if (!manageLicenseRight) {
    throw new functions.https.HttpsError(
      'permission-denied',
      `You don't have the permission to perform this action with the user [${userId}].`,
    );
  }
}

/**
 * Delete a global (app) license.
 * This must be performed by an admin.
 * @param licenseId License to delete from app.
 * @param userId User performing the deletion.
 */
async function deleteStaffLicense(licenseId: string, userId: string) {
  await canManageLicense(userId);
  await firestore
    .collection('licenses')
    .doc(licenseId)
    .delete();
}

/**
 * Delete a local (user) license.
 * @param licenseId License to delete from the user's context.
 * @param userId User performing the deletion.
 */
async function deleteUserLicense(licenseId: string, userId: string) {
  await firestore
    .collection('users')
    .doc(userId)
    .collection('licenses')
    .doc(licenseId)
    .delete();
}

/**
 * Check and format license's data.
 * @param data License's data to check.
 * @returns Return a well formated license.
 */
function formatLicense(data: License): License {
  const wellFormatedLicense: License = {
    abbreviation: '',
    createdAt: adminApp.firestore.FieldValue.serverTimestamp(),
    createdBy: {
      id: '',
    },
    description: '',
    type: "user" as EnumLicenseType.user,
    id: '',
    licenseUpdatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
    name: '',
    notice: '',
    terms: {
      attribution: false,
      noAdditionalRestriction: false,
    },
    updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
    updatedBy: {
      id: '',
    },
    usage: {
      adapt: false,
      commercial: false,
      foss: false,
      free: false,
      oss: false,
      personal: false,
      print: false,
      sell: false,
      share: false,
      shareALike: false,
      view: true,
    },
    urls: {
      image: '',
      legalCode: '',
      terms: '',
      privacy: '',
      wikipedia: '',
      website: '',
    },
    version: '1.0',
  };

  if (!data) {
    return wellFormatedLicense;
  }

  if (typeof data.abbreviation === 'string') {
    wellFormatedLicense.abbreviation = data.abbreviation;
  }

  if (data.createdAt) {
    wellFormatedLicense.createdAt = data.createdAt;
  }

  if (typeof data.createdBy !== 'object') {
    data.createdBy = { id: '' };
  } else if (typeof data.createdBy?.id === 'string') {
    wellFormatedLicense.createdBy.id = data.createdBy.id;
  }

  if (typeof data.licenseUpdatedAt === 'number') {
    wellFormatedLicense.licenseUpdatedAt = adminApp
      .firestore.Timestamp.fromMillis(data.licenseUpdatedAt);
  }

  if (typeof data.description === 'string') {
    wellFormatedLicense.description = data.description;
  }

  if (typeof data.type === 'string') {
    wellFormatedLicense.type = data.type;
  }

  if (typeof data.id === 'string') {
    wellFormatedLicense.id = data.id;
  }

  if (typeof data.name === 'string') {
    wellFormatedLicense.name = data.name;
  }

  if (typeof data.notice === 'string') {
    wellFormatedLicense.notice = data.notice;
  }

  // TERMS
  // -----
  if (!data.terms) {
    data.terms = {
      attribution: false,
      noAdditionalRestriction: false,
    };
  }
   
  if (typeof data.terms.attribution === 'boolean') {
      wellFormatedLicense.terms.attribution = data.terms.attribution;
    }

    if (typeof data.terms.noAdditionalRestriction === 'boolean') {
      wellFormatedLicense.terms.noAdditionalRestriction = data.terms.noAdditionalRestriction;
    }

  // USAGE
  // -----
  if (!data.usage || typeof data.usage !== 'object') {
    return wellFormatedLicense;
  }

  if (typeof data.usage.adapt === 'boolean') {
    wellFormatedLicense.usage.adapt = data.usage.adapt;
  }

  if (typeof data.usage.commercial === 'boolean') {
    wellFormatedLicense.usage.commercial = data.usage.commercial;
  }

  if (typeof data.usage.foss === 'boolean') {
    wellFormatedLicense.usage.foss = data.usage.foss;
  }

  if (typeof data.usage.free === 'boolean') {
    wellFormatedLicense.usage.free = data.usage.free;
  }

  if (typeof data.usage.oss === 'boolean') {
    wellFormatedLicense.usage.oss = data.usage.oss;
  }

  if (typeof data.usage.personal === 'boolean') {
    wellFormatedLicense.usage.personal = data.usage.personal;
  }

  if (typeof data.usage.print === 'boolean') {
    wellFormatedLicense.usage.print = data.usage.print;
  }

  if (typeof data.usage.sell === 'boolean') {
    wellFormatedLicense.usage.sell = data.usage.sell;
  }

  if (typeof data.usage.share === 'boolean') {
    wellFormatedLicense.usage.share = data.usage.share;
  }

  if (typeof data.usage.shareALike === 'boolean') {
    wellFormatedLicense.usage.shareALike = data.usage.shareALike;
  }

  if (typeof data.usage.view === 'boolean') {
    wellFormatedLicense.usage.view = data.usage.view;
  }

  // UPDATED BY
  // ----------
  if (typeof data.updatedBy !== 'object') {
    data.updatedBy = { id: '' };
  } else {
    if (typeof data.updatedBy.id === 'string') {
      wellFormatedLicense.updatedBy.id = data.updatedBy.id;
    }
  
    if (typeof data.version === 'string') {
      wellFormatedLicense.version = data.version;
    }
  }

  // URLS
  // ----
  if (data.urls) {
    if (typeof data.urls.wikipedia === 'string') {
      wellFormatedLicense.urls.wikipedia = data.urls.wikipedia;
    }

    if (typeof data.urls.website === 'string') {
      wellFormatedLicense.urls.website = data.urls.website;
    }

    if (typeof data.urls.image === 'string') {
      wellFormatedLicense.urls.image = data.urls.image;
    }

    if (typeof data.urls.legalCode === 'string') {
      wellFormatedLicense.urls.legalCode = data.urls.legalCode;
    }

    if (typeof data.urls.privacy === 'string') {
      wellFormatedLicense.urls.privacy = data.urls.privacy;
    }

    if (typeof data.urls.terms === 'string') {
      wellFormatedLicense.urls.terms = data.urls.terms;
    }
  }

  if (typeof data.version === 'string') {
    wellFormatedLicense.version = data.version;
  }

  return wellFormatedLicense;
}
