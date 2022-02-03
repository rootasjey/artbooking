import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { cloudRegions, ILLUSTRATIONS_COLLECTION_NAME, STATISTICS_COLLECTION_NAME, STORAGES_DOCUMENT_NAME, USERS_COLLECTION_NAME } from './utils';

const firestore = adminApp.firestore();

// ------
// Books
// ------
export const onCreateBook = functions
  .region(cloudRegions.eu)
  .firestore
  .document('books/{bookId}')
  .onCreate(async (bookSnap) => {
    const bookData = bookSnap.data();

    const statsSnap = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc('books')
      .get();

    const statsData = statsSnap.data();
    if (!statsSnap.exists || !statsData) {
      return false;
    }

    let total: number = statsData.total ?? 0;
    let created: number = statsData.created ?? 0;

    total = typeof total === 'number' ? total + 1 : 1;
    created = typeof created === 'number' ? created + 1 : 1;

    await statsSnap.ref.update({
      total,
      created,
      updatedAt: adminApp.firestore.Timestamp.now(),
    });

    // Update user's books stats.
    // -------------------------
    const userStatsSnap = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(bookData.user.id)
      .collection(STATISTICS_COLLECTION_NAME)
      .doc('books')
      .get();

    const bookStatsData = userStatsSnap.data();
    if (!userStatsSnap.exists || !bookStatsData) {
      return false;
    }

    let bookCreated: number = bookStatsData.created ?? 0;
    let bookOwned: number = bookStatsData.owned ?? 0;

    bookCreated = typeof bookCreated === 'number' ? bookCreated + 1 : 1;
    bookOwned = typeof bookOwned === 'number' ? bookOwned + 1 : 1;

    await userStatsSnap.ref.update({
      created: bookCreated,
      owned: bookOwned,
      updatedAt: adminApp.firestore.Timestamp.now(),
    });
    
    return true;
  });


export const onDeleteBook = functions
  .region(cloudRegions.eu)
  .firestore
  .document('books/{bookId}')
  .onDelete(async (bookSnap) => {
    const bookData = bookSnap.data();

    const statsSnap = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc('books')
      .get();

    const statsData = statsSnap.data();
    if (!statsSnap.exists || !statsData) {
      return false;
    }

    let total: number = statsData.total ?? 0;
    let deleted: number = statsData.deleted ?? 0;

    total = typeof total === 'number' ? total : 0;
    deleted = typeof deleted === 'number' ? deleted : 0;

    total = Math.max(0, total - 1);
    deleted++;

    await statsSnap.ref.update({
      total, 
      deleted,
      updatedAt: adminApp.firestore.Timestamp.now(),
    });

    // Update user's books stats.
    // -------------------------
    const userStatsSnap = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(bookData.user.id)
      .collection(STATISTICS_COLLECTION_NAME)
      .doc('books')
      .get();

    const bookStatsData = userStatsSnap.data();
    if (!userStatsSnap.exists || !bookStatsData) {
      return false;
    }

    let bookDeleted: number = bookStatsData.deleted ?? 0;
    let bookOwned: number = bookStatsData.owned ?? 0;

    bookDeleted = typeof bookDeleted === 'number' ? bookDeleted : 0;
    bookOwned = typeof bookOwned === 'number' ? bookOwned : 0;

    bookOwned = Math.max(0, bookOwned - 1);
    bookDeleted++

    await userStatsSnap.ref.update({
      deleted: bookDeleted,
      owned: bookOwned,
      updatedAt: adminApp.firestore.Timestamp.now(),
    })

    return true;
  });


// -------------
// Illustrations
// -------------
export const onCreateIllustration = functions
  .region(cloudRegions.eu)
  .firestore
  .document('illustrations/{illustrationId}')
  .onCreate(async (illustrationSnap) => {
    const illustrationData = illustrationSnap.data();

    const statsSnap = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(ILLUSTRATIONS_COLLECTION_NAME)
      .get();

    const statsData = statsSnap.data();
    if (!statsSnap.exists || !statsData) {
      return false;
    }

    let total: number = statsData.total ?? 0;
    let created: number = statsData.created ?? 0;

    total = typeof total === 'number' ? total + 1 : 1;
    created = typeof created === 'number' ? created + 1 : 1;

    await statsSnap.ref.update({
      total, 
      created, 
      updatedAt: adminApp.firestore.Timestamp.now(),
    });

    // Update user's illustrations stats.
    // ---------------------------------
    const userStatsSnap = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(illustrationData.user.id)
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(ILLUSTRATIONS_COLLECTION_NAME)
      .get();

    const illustrationStatsData = userStatsSnap.data();
    if (!userStatsSnap.exists || !illustrationStatsData) {
      return false;
    }

    let illustrationCreated: number = illustrationStatsData.created ?? 0;
    let illustrationOwned: number = illustrationStatsData.owned ?? 0;

    illustrationCreated = typeof illustrationCreated === 'number' ? illustrationCreated + 1 : 1;
    illustrationOwned = typeof illustrationOwned === 'number' ? illustrationOwned + 1 : 1;

    await userStatsSnap.ref.update({
      created: illustrationCreated,
      owned: illustrationOwned,
      updatedAt: adminApp.firestore.Timestamp.now(),
    })

    return true;
  });


export const onDeleteIllustration = functions
  .region(cloudRegions.eu)
  .firestore
  .document('illustrations/{illustrationId}')
  .onDelete(async (illustrationSnap) => {
    const illustrationData = illustrationSnap.data();

    const statsSnap = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(ILLUSTRATIONS_COLLECTION_NAME)
      .get();

    const statsData = statsSnap.data();
    if (!statsSnap.exists || !statsData) {
      return false;
    }

    let total: number = statsData.total ?? 0;
    let deleted: number = statsData.deleted ?? 0;

    total = typeof total === 'number' ? total : 0;
    deleted = typeof deleted === 'number' ? deleted : 0;
    
    total = Math.max(0, statsData.total - 1);
    deleted++;

    await statsSnap.ref.update({
      total, 
      deleted,
      updatedAt: adminApp.firestore.Timestamp.now(),
    });

    // Update user's illustrations stats.
    // ---------------------------------
    const userStatsSnap = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(illustrationData.user.id)
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(ILLUSTRATIONS_COLLECTION_NAME)
      .get();

    const illustrationStatsData = userStatsSnap.data();
    if (!userStatsSnap.exists || !illustrationStatsData) {
      return false;
    }

    let illustrationDeleted: number = illustrationStatsData.deleted ?? 0;
    let illustrationOwned: number = illustrationStatsData.owned ?? 0;

    illustrationDeleted = typeof illustrationDeleted === 'number' ? illustrationDeleted : 0;
    illustrationOwned = typeof illustrationOwned === 'number' ? illustrationOwned : 0;

    illustrationOwned = Math.max(0, illustrationOwned - 1);
    illustrationDeleted++;

    await userStatsSnap.ref.update({
      deleted: illustrationDeleted,
      owned: illustrationOwned,
      updatedAt: adminApp.firestore.Timestamp.now(),
    })

    let imageBytesToRemove = 0;
    if (illustrationData) {
      imageBytesToRemove = illustrationData.size ?? 0;
    }

    const storageSnapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(illustrationData.user.id)
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(STORAGES_DOCUMENT_NAME)
      .get();
    
    const storageData = storageSnapshot.data();
    if (!storageSnapshot.exists || !storageData) {
      return
    }

    let storageIllustrationsUsed: number = storageData.illustrations.used;
    storageIllustrationsUsed -= imageBytesToRemove;
    
    await storageSnapshot.ref.update({
      illustrations: {
        used: storageIllustrationsUsed,
        updatedAt: adminApp.firestore.Timestamp.now(),
      },
    });

    return true;
  });

// ------
// Users
// ------
export const onCreateUser = functions
  .region(cloudRegions.eu)
  .firestore
  .document('users/{userId}')
  .onCreate(async (userSnap) => {
    const userData = userSnap.data();
    const isDev: boolean = userData.developer?.isProgramActive;

    const statsSnap = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc('users')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    let total: number = statsData.total ?? 0;
    let created: number = statsData.created ?? 0;

    total = typeof total === 'number' ? total + 1 : 1;
    created = typeof created === 'number' ? created + 1 : 1;

    const payload: Record<string, number> = { total, created };

    if (isDev) {
      payload.dev = statsData.dev + 1;
    }

    await statsSnap.ref.update({
      ...payload, 
      ...{ updatedAt: adminApp.firestore.Timestamp.now() },
    });
    return true;
  });

export const onUpdateUser = functions
  .region(cloudRegions.eu)
  .firestore
  .document('users/{userId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before || !after) {
      return;
    }

    const devBefore: boolean = before.developer?.isProgramActive ?? false;
    const devAfter: boolean = after.developer?.isProgramActive ?? false;

    if (devAfter === devBefore) {
      return;
    }

    const statsSnap = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc('users')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    let dev: number = statsData.dev;

    // New dev account.
    if (devBefore === false && devAfter === true) {
      dev++;
    }

    // Closed dev account
    if (devBefore === true && devAfter === false) {
      dev--;
    }

    await statsSnap.ref.update({
      dev,
    });

    return true;
  });

export const onDeleteUser = functions
  .region(cloudRegions.eu)
  .firestore
  .document('users/{userId}')
  .onDelete(async (userSnap) => {
    const userData = userSnap.data();
    const wasDev: boolean = userData.developer?.isProgramActive ?? false;

    const statsSnap = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc('users')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    let total: number = statsData.total ?? 0;
    let deleted: number = statsData.deleted ?? 0;

    total = typeof total === 'number' ? total : 0;
    deleted = typeof deleted === 'number' ? deleted : 0;

    total = Math.max(0, statsData.total - 1);
    deleted++;

    const payload: Record<string, number> = { total, deleted };

    if (wasDev) {
      payload.dev = Math.max(0, statsData.dev - 1);
    }

    await statsSnap.ref.update({
      ...payload,
      ...{ updatedAt: adminApp.firestore.Timestamp.now() }
    });

    return true;
  });

