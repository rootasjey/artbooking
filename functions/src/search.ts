import * as functions from 'firebase-functions';
import algolia from 'algoliasearch';
import deepEqual = require('deep-equal');

const env = functions.config();

const client = algolia(env.algolia.appid, env.algolia.apikey);
const illustrationsIndex = client.initIndex('illustrations');
const usersIndex = client.initIndex('users');

// Illustrations index
// -------------------
export const onIndexIllustration = functions
  .region('europe-west3')
  .firestore
  .document('illustrations/{illustrationId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    // Do not index private iillustrations.
    if (data.visibility !== 'public') {
      return;
    }

    return illustrationsIndex.saveObject({
      objectID,
      ...data,
    });
  });

export const onReIndexIllustration = functions
  .region('europe-west3')
  .firestore
  .document('illustrations/{illustrationId}')
  .onUpdate(async (snapshot) => {
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    // Remove image from index if not public anymore.
    if (data.visibility !== 'public') {
      return illustrationsIndex.deleteObject(objectID);
    }

    return illustrationsIndex.saveObject({
      objectID,
      ...data,
    })
  });

export const onUnIndexIllustration = functions
  .region('europe-west3')
  .firestore
  .document('illustrations/{illustrationId}')
  .onDelete(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    // This image was not indexed.
    if (data.visibility !== 'public') {
      return;
    }

    return illustrationsIndex.deleteObject(objectID);
  });

// Users index
// -----------
export const onIndexUser = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    return usersIndex.saveObject({
      objectID,
      lang: data.lang,
      name: data.name,
      nameLowerCase: data.nameLowerCase,
      pricing: data.pricing,
      urls: data.urls,
    });
  });

export const onReIndexUser = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onUpdate(async (snapshot) => {
    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();
    const objectID = snapshot.after.id;

    if (!indexedPropChanged(beforeData, afterData)) {
      return;
    }

    return usersIndex.saveObject({
      objectID,
      lang: afterData.lang,
      name: afterData.name,
      nameLowerCase: afterData.nameLowerCase,
      pricing: afterData.pricing,
      urls: afterData.urls,
    });
  });

export const onUnIndexUser = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
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

  if (beforeData.lang !== afterData.lang) {
    return true;
  }

  if (beforeData.name !== afterData.name) {
    return true;
  }

  if (beforeData.nameLowerCase !== afterData.nameLowerCase) {
    return true;
  }

  if (beforeData.pricing !== afterData.pricing) {
    return true;
  }

  // Urls
  const beforeUrls = beforeData.urls;
  const afterUrls = afterData.urls;

  if (!deepEqual(beforeUrls, afterUrls, { strict: true })) {
    return true;
  }

  return false;
}
