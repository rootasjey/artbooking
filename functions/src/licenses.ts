import * as functions from 'firebase-functions';
// @ts-ignore
import * as fs from 'fs-extra';

import { adminApp } from './adminApp';
import { allowedLicenseFromValues, cloudRegions } from './utils';

const firestore = adminApp.firestore();

/**
 * Create one license for an artwork.
 * The created license must either be global (available to all users)
 * or to a specific user (only avaliable to them).
 * NOTE: Only admin can create global license.
 */
export const createOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: CreateOneLicenseParams, context) => {
    const userAuth = context.auth;
    const { from, license } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof from !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [from] parameter ` +
        `which tells if the license is created by a staff member (and is available for all users) ` +
        `or if it's created by an author (and is user specific).` +
        `The property [from] must be a string ` +
        `among these values: ${allowedLicenseFromValues.join(", ")}`,
      );
    }

    if (!allowedLicenseFromValues.includes(from)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The value provided for [from] parameter is not valid. ` +
        `Allowed values are: ${allowedLicenseFromValues.join(", ")}`,
      );
    }

    if (from === 'app') {
      await checkIfAdmin(userAuth.uid);
    }

    const formatedLicense = formatLicense(license);

    const docCreated = from === 'app' 
      ? await createLicenseInApp(formatedLicense)
      : await createLicenseInUser(formatedLicense, userAuth.uid);

    return {
      license: {
        id: docCreated.id
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
    const { from, licenseId } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof from !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [from] parameter ` +
        `which tells if the license is created by a staff member (and is available for all users) ` +
        `or if it's created by an author (and is user specific).` +
        `The property [from] must be a string ` +
        `among these values: ${allowedLicenseFromValues.join(", ")}`,
      );
    }

    if (!allowedLicenseFromValues.includes(from)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The value provided for [from] parameter is not valid. ` +
        `Allowed values are: ${allowedLicenseFromValues.join(", ")}`,
      );
    }
    
    from === 'app'
     ? await deleteOneAppLicense(licenseId, userAuth.uid)
     : await deleteOneUserLicense(licenseId, userAuth.uid);

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
    const { from, license } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof from !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [from] parameter ` +
        `which tells if the license is created by a staff member (and is available for all users) ` +
        `or if it's created by an author (and is user specific).` +
        `The property [from] must be a string ` +
        `among these values: ${allowedLicenseFromValues.join(", ")}`,
      );
    }

    if (!allowedLicenseFromValues.includes(from)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The value provided for [from] parameter is not valid. ` +
        `Allowed values are: ${allowedLicenseFromValues.join(", ")}`,
      );
    }

    if (from === 'app') {
      await checkIfAdmin(userAuth.uid);
    }

    const formatedLicense = formatLicense(license);

    const licenseId = formatedLicense.id;

    if (!licenseId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The updateOne(...) functionmust be called with a [license] parameter ` +
        `whis is an existing license. The license you provided doesn't have a valid [id] value.`,
      )
    }

    from === 'app' 
      ? await updateLicenseInApp(formatedLicense)
      : await updateLicenseInUser(formatedLicense, userAuth.uid);

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
async function createLicenseInApp(formatedLicense: License) {
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
async function createLicenseInUser(formatedLicense: License, userId: string) {
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
async function updateLicenseInApp(formatedLicense: License) {
  return await firestore
    .collection('licenses')
    .doc(formatedLicense.id)
    .update(formatedLicense);
}

/**
 * Update a license for a specific user.
 * @param formatedLicense License's data to update.
 * @param userId User performing the update.
 * @returns Updated license.
 */
async function updateLicenseInUser(formatedLicense: License, userId: string) {
  return await firestore
    .collection('users')
    .doc(userId)
    .collection('licenses')
    .doc(formatedLicense.id)
    .update(formatedLicense);
}

/**
 * Return true if the passed user's id belong to an admin.
 */
async function checkIfAdmin(userId: string) {
  const userSnap = await firestore
    .collection('users')
    .doc(userId)
    .get();

  const userData = userSnap.data();

  if (!userSnap.exists || !userData) {
    throw new functions.https.HttpsError(
      'not-found',
      `User's data for the id [${userId}] not found. ` + 
      `This user's data may have been deleted.`,
    );
  }

  const rights = userData['rights'];
  const userAdmin = rights['user:admin'];

  if (!userAdmin) {
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
async function deleteOneAppLicense(licenseId: string, userId: string) {
  await checkIfAdmin(userId);
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
async function deleteOneUserLicense(licenseId: string, userId: string) {
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
    from: LicenseFrom.app,
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
    version: '',
  };

  if (!data) {
    return wellFormatedLicense;
  }

  if (typeof data.abbreviation === 'string') {
    wellFormatedLicense.abbreviation = data.abbreviation;
  }

  if (typeof data.createdBy !== 'object') {
    data.createdBy = { id: '' };
  }

  if (typeof data.createdBy.id === 'string') {
    wellFormatedLicense.createdBy.id = data.createdBy.id;
  }

  if (typeof data.description === 'string') {
    wellFormatedLicense.description = data.description;
  }

  if (typeof data.from === 'string') {
    wellFormatedLicense.from = data.from;
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
  if (!data.usage) {
    return data;
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

  if (typeof data.updatedBy !== 'object') {
    data.updatedBy = { id: '' };
  }

  if (typeof data.updatedBy.id === 'string') {
    wellFormatedLicense.updatedBy.id = data.updatedBy.id;
  }

  if (typeof data.version === 'string') {
    wellFormatedLicense.version = data.version;
  }

  return wellFormatedLicense;
}
