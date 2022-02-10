import * as functions from 'firebase-functions';
import algolia from 'algoliasearch';
import deepEqual = require('deep-equal');
import { BOOK_DOC_PATH, cloudRegions } from './utils';

const env = functions.config();

const client = algolia(env.algolia.appid, env.algolia.apikey);
const booksIndex = client.initIndex('books');
const illustrationsIndex = client.initIndex('illustrations');
const licensesIndex = client.initIndex('licenses');
const artMovementsIndex = client.initIndex('art_movements');
const usersIndex = client.initIndex('users');

const ART_MOVEMENT_DOC_PATH = 'art_movements/{art_movement_id}'
const ILLUSTRATION_DOC_PATH = 'illustrations/{illustration_id}'
const LICENSE_DOC_PATH = 'licenses/{license_id}'
const USER_DOC_PATH = 'users/{user_id}'

// ----------------
// Art movement index
// ----------------

/**
 * Update art movement index on create document.
 */
export const onIndexArtMovement = functions
  .region(cloudRegions.eu)
  .firestore
  .document(ART_MOVEMENT_DOC_PATH)
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    return artMovementsIndex.saveObject({
      objectID,
      ...data,
    })
  });

/**
 * Update art movement index on update document.
 */
  export const onReIndexArtMovement = functions
  .region(cloudRegions.eu)
  .firestore
  .document(ART_MOVEMENT_DOC_PATH)
  .onUpdate(async (snapshot) => {
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    return artMovementsIndex.saveObject({
      objectID,
      ...data,
    })
  });

/**
 * Update art movement index on delete document.
 */
  export const onUnIndexArtMovement = functions
  .region(cloudRegions.eu)
  .firestore
  .document(ART_MOVEMENT_DOC_PATH)
  .onDelete(async (snapshot) => {
    const objectID = snapshot.id;
    return artMovementsIndex.deleteObject(objectID);
  });


// ----------------
// Books index
// ----------------

/**
 * Update art movement index on create document.
 */
export const onIndexBook = functions
  .region(cloudRegions.eu)
  .firestore
  .document(BOOK_DOC_PATH)
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    // Do not index private book.
    if (data.visibility !== 'public') {
      return;
    }

    return booksIndex.saveObject({
      objectID,
      ...data,
    })
  });

/**
 * Update art movement index on update document.
 */
  export const onReIndexBook = functions
  .region(cloudRegions.eu)
  .firestore
  .document(BOOK_DOC_PATH)
  .onUpdate(async (snapshot) => {
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    // Remove book from index if not public anymore.
    if (data.visibility !== 'public') {
      return booksIndex.deleteObject(objectID);
    }

    return booksIndex.saveObject({
      objectID,
      ...data,
    })
  });

/**
 * Update book index on delete document.
 */
  export const onUnIndexBook = functions
  .region(cloudRegions.eu)
  .firestore
  .document(BOOK_DOC_PATH)
  .onDelete(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    // Do not index private book.
    if (data.visibility !== 'public') {
      return;
    }

    return booksIndex.deleteObject(objectID);
  });

// -------------------
// Illustrations index
// -------------------
export const onIndexIllustration = functions
  .region(cloudRegions.eu)
  .firestore
  .document(ILLUSTRATION_DOC_PATH)
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    // Do not index private iillustration.
    if (data.visibility !== 'public') {
      return;
    }

    return illustrationsIndex.saveObject({
      objectID,
      ...data,
    });
  });

export const onReIndexIllustration = functions
  .region(cloudRegions.eu)
  .firestore
  .document(ILLUSTRATION_DOC_PATH)
  .onUpdate(async (snapshot) => {
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    // Remove illustration from index if not public anymore.
    if (data.visibility !== 'public') {
      return illustrationsIndex.deleteObject(objectID);
    }

    return illustrationsIndex.saveObject({
      objectID,
      ...data,
    })
  });

export const onUnIndexIllustration = functions
  .region(cloudRegions.eu)
  .firestore
  .document(ILLUSTRATION_DOC_PATH)
  .onDelete(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    // This image was not indexed.
    if (data.visibility !== 'public') {
      return;
    }

    return illustrationsIndex.deleteObject(objectID);
  });

// ----------------
// Licenses index
// ----------------
/**
 * Update licenses index on create document.
 */
export const onIndexLicense = functions
  .region(cloudRegions.eu)
  .firestore
  .document(LICENSE_DOC_PATH)
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    return licensesIndex.saveObject({
      objectID,
      ...data,
    })
  });

/**
 * Update licenses index on update document.
 */
export const onReIndexLicense = functions
  .region(cloudRegions.eu)
  .firestore
  .document(LICENSE_DOC_PATH)
  .onUpdate(async (snapshot) => {
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    return licensesIndex.saveObject({
      objectID,
      ...data,
    })
  });

/**
 * Update licenses index on delete document.
 */
export const onUnIndexLicense = functions
  .region(cloudRegions.eu)
  .firestore
  .document(LICENSE_DOC_PATH)
  .onDelete(async (snapshot) => {
    const objectID = snapshot.id;
    return licensesIndex.deleteObject(objectID);
  });

// -----------
// Users index
// -----------
export const onIndexUser = functions
  .region(cloudRegions.eu)
  .firestore
  .document(USER_DOC_PATH)
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    return usersIndex.saveObject({
      objectID,
      language: data.language,
      links: data.links,
      name: data.name,
      name_lower_case: data.name_lower_case,
      pricing: data.pricing,
    });
  });

export const onReIndexUser = functions
  .region(cloudRegions.eu)
  .firestore
  .document(USER_DOC_PATH)
  .onUpdate(async (snapshot) => {
    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();
    const objectID = snapshot.after.id;

    if (!indexedPropChanged(beforeData, afterData)) {
      return;
    }

    return usersIndex.saveObject({
      objectID,
      language: afterData.language,
      links: afterData.links,
      name: afterData.name,
      name_lower_case: afterData.name_lower_case,
      pricing: afterData.pricing,
    });
  });

export const onUnIndexUser = functions
  .region(cloudRegions.eu)
  .firestore
  .document(USER_DOC_PATH)
  .onDelete(async (snapshot) => {
    const objectID = snapshot.id;
    return usersIndex.deleteObject(objectID);
  });

// -------
// Helpers
// -------

/**
 * Return true if indexed (search) properties was updated.
 * @param beforeData Firestore data before doc update.
 * @param afterData Firestore data after doc update.
 */
function indexedPropChanged(
  beforeData: FirebaseFirestore.DocumentData,
  afterData: FirebaseFirestore.DocumentData,
): boolean {
  if (beforeData.language !== afterData.language) {
    return true;
  }

  if (beforeData.name !== afterData.name) {
    return true;
  }

  if (beforeData.name_lower_case !== afterData.name_lower_case) {
    return true;
  }

  if (beforeData.pricing !== afterData.pricing) {
    return true;
  }

  // Links
  const beforeLinks = beforeData.links;
  const afterLinks = afterData.links;

  if (!deepEqual(beforeLinks, afterLinks, { strict: true })) {
    return true;
  }

  return false;
}
