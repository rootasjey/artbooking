import * as functions from 'firebase-functions';
// @ts-ignore
import * as fs from 'fs-extra';

import { adminApp } from './adminApp';
import { allowedLicenseTypes as allowedLicenseTypes, cloudRegions, LICENSES_COLLECTION_NAME, USERS_COLLECTION_NAME, USER_LICENSES_COLLECTION_NAME } from './utils';

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
    formatedLicense.created_by = userAuth.uid;

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
    const { type, license_id } = params;

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
     ? await deleteStaffLicense(license_id, userAuth.uid)
     : await deleteUserLicense(license_id, userAuth.uid);

    return {
      license: {
        id: license_id,
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
    
    formatedLicense.updated_by = userAuth.uid;
    formatedLicense.updated_at = adminApp.firestore.FieldValue.serverTimestamp()

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
    .collection(LICENSES_COLLECTION_NAME)
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
    .collection(USERS_COLLECTION_NAME)
    .doc(userId)
    .collection(USER_LICENSES_COLLECTION_NAME)
    .add(formatedLicense);
}

/**
 * Update a global license.
 * This action must be performed by an admin.
 * @param formatedLicense License's data to update.
 * @returns Updated license.
 */
async function updateStaffLicense(formatedLicense: License) {
  const licenseSnapshot = await firestore
  .collection(LICENSES_COLLECTION_NAME)
  .doc(formatedLicense.id)
  .get()

  const licenseData = licenseSnapshot.data()
  if (!licenseSnapshot.exists || !licenseData) {
    throw new functions.https.HttpsError(
      'not-found', 
      `Sorry, we didn't find the target document to update. ` +
      `It may have been deleted.`,
    )
  }

  formatedLicense.updated_at = adminApp.firestore.FieldValue.serverTimestamp();
  return await licenseSnapshot.ref.update(formatedLicense);
}

/**
 * Update a license for a specific user.
 * @param formatedLicense License's data to update.
 * @param userId User performing the update.
 * @returns Updated license.
 */
async function updateUserLicense(formatedLicense: License, userId: string) {
  const licenseSnapshot = await firestore
  .collection(USERS_COLLECTION_NAME)
    .doc(userId)
    .collection(USER_LICENSES_COLLECTION_NAME)
    .doc(formatedLicense.id)
    .get()

  const licenseData = licenseSnapshot.data();
  if( !licenseData) {
    throw new functions.https.HttpsError(
      'not-found', 
      `Sorry, we didn't find the target document to update. ` +
      `It may have been deleted.`,
    )
  }

  formatedLicense.updated_at = adminApp.firestore.FieldValue.serverTimestamp();
  return await licenseSnapshot.ref.update(formatedLicense);
}

/**
 * Return true if the target user can manage staff licenses.
 */
async function canManageLicense(userId: string) {
  const userSnap = await firestore
    .collection(USERS_COLLECTION_NAME)
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
  const manageLicenseRight: boolean = rights['user:manage_licenses'];

  if (!manageLicenseRight) {
    throw new functions.https.HttpsError(
      'permission-denied',
      `You don't have the permission to perform this action ` +
      `with the user [${userId}].`,
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
    .collection(LICENSES_COLLECTION_NAME)
    .doc(licenseId)
    .delete();
}

/**
 * Delete a local (user) license.
 * @param licenseId License to delete from the user's context.
 * @param userId User performing the deletion.
 */
async function deleteUserLicense(licenseId: string, userId: string) {
  const licenseSnapshot = await firestore
    .collection(USERS_COLLECTION_NAME)
    .doc(userId)
    .collection(USER_LICENSES_COLLECTION_NAME)
    .doc(licenseId)
    .get();

  const licenseData = licenseSnapshot.data()
  if (!licenseSnapshot.exists || !licenseData) {
    throw new functions.https.HttpsError(
      'not-found',
      `This license [${licenseId}] does not exist.`,
    )
  }

  if (licenseData.created_by !== userId) {
    throw new functions.https.HttpsError(
      'permission-denied',
      `You don't have the right to delete this licenses`,
    )
  }

  return await licenseSnapshot.ref.delete()
}

/**
 * Check and format license's data.
 * @param data License's data to check.
 * @returns Return a well formated license.
 */
function formatLicense(data: License): License {
  const wellFormatedLicense: License = {
    abbreviation: '',
    created_at: adminApp.firestore.FieldValue.serverTimestamp(),
    created_by: '',
    description: '',
    id: '',
    license_updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    links: {
      image: '',
      legal_code: '',
      terms: '',
      privacy: '',
      wikipedia: '',
      website: '',
    },
    name: '',
    notice: '',
    terms: {
      attribution: false,
      no_additional_restriction: false,
    },
    type: "user" as EnumLicenseType.user,
    updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    updated_by: '',
    usage: {
      commercial: false,
      foss: false,
      free: false,
      oss: false,
      personal: false,
      print: false,
      remix: false,
      sell: false,
      share: false,
      share_a_like: false,
      view: true,
    },
    version: '1.0',
  };

  if (!data) {
    return wellFormatedLicense;
  }

  if (typeof data.abbreviation === 'string') {
    wellFormatedLicense.abbreviation = data.abbreviation;
  }

  if (data.created_at) {
    wellFormatedLicense.created_at = data.created_at;
  }
  
  if (typeof data.created_by === 'string') {
    wellFormatedLicense.created_by = data.created_by;
  }

  if (data.license_updated_at) {
    wellFormatedLicense.license_updated_at = data.license_updated_at;
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
      no_additional_restriction: false,
    };
  }
   
  if (typeof data.terms.attribution === 'boolean') {
    wellFormatedLicense.terms.attribution = data.terms.attribution;
  }

  if (typeof data.terms.no_additional_restriction === 'boolean') {
    wellFormatedLicense.terms.no_additional_restriction = data.terms.no_additional_restriction;
  }

  // USAGE
  // -----
  if (!data.usage || typeof data.usage !== 'object') {
    return wellFormatedLicense;
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

  if (typeof data.usage.remix === 'boolean') {
    wellFormatedLicense.usage.remix = data.usage.remix;
  }

  if (typeof data.usage.sell === 'boolean') {
    wellFormatedLicense.usage.sell = data.usage.sell;
  }

  if (typeof data.usage.share === 'boolean') {
    wellFormatedLicense.usage.share = data.usage.share;
  }

  if (typeof data.usage.share_a_like === 'boolean') {
    wellFormatedLicense.usage.share_a_like = data.usage.share_a_like;
  }

  if (typeof data.usage.view === 'boolean') {
    wellFormatedLicense.usage.view = data.usage.view;
  }

  // UPDATED BY
  // ----------
  if (typeof data.updated_by === 'string') {
    wellFormatedLicense.updated_by = data.updated_by;
  }

  if (typeof data.version === 'string') {
    wellFormatedLicense.version = data.version;
  }

  // Links
  // -----
  const licenseLinks = data.links;
  if (!licenseLinks) {
    return wellFormatedLicense
  }

  if (typeof licenseLinks.wikipedia === 'string') {
    wellFormatedLicense.links.wikipedia = licenseLinks.wikipedia;
  }

  if (typeof licenseLinks.website === 'string') {
    wellFormatedLicense.links.website = licenseLinks.website;
  }

  if (typeof licenseLinks.image === 'string') {
    wellFormatedLicense.links.image = licenseLinks.image;
  }

  if (typeof licenseLinks.legal_code === 'string') {
    wellFormatedLicense.links.legal_code = licenseLinks.legal_code;
  }

  if (typeof licenseLinks.privacy === 'string') {
    wellFormatedLicense.links.privacy = licenseLinks.privacy;
  }

  if (typeof licenseLinks.terms === 'string') {
    wellFormatedLicense.links.terms = licenseLinks.terms;
  }

  return wellFormatedLicense;
}
