import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

// ------
// Books
// ------
export const onCreateBook = functions
  .region('europe-west3')
  .firestore
  .document('books/{bookId}')
  .onCreate(async (bookSnap) => {
    const bookData = bookSnap.data();

    const statsSnap = await firestore
      .collection('stats')
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

    const payload: Record<string, number> = { total, created };
    await statsSnap.ref.update(payload);

    // Update user's stats.
    const userSnap = await firestore
      .collection('users')
      .doc(bookData.user.id)
      .get();

    const userData = userSnap.data();

    if (!userSnap.exists || !userData) {
      return false;
    }

    let userCreated: number = userData.stats?.books?.created ?? 0;
    let userOwned: number = userData.stats?.books?.owned ?? 0;

    userCreated = typeof userCreated === 'number' ? userCreated + 1 : 1;
    userOwned = typeof userOwned === 'number' ? userOwned + 1 : 1;

    await userSnap.ref.update({
      'stats.books.created': userCreated,
      'stats.books.owned': userOwned,
      updatedAt: adminApp.firestore.Timestamp.now(),
    });

    return true;
  });


export const onDeleteBook = functions
  .region('europe-west3')
  .firestore
  .document('books/{bookId}')
  .onDelete(async (bookSnap) => {
    const bookData = bookSnap.data();

    const statsSnap = await firestore
      .collection('stats')
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

    const payload: Record<string, number> = { 
      total, 
      deleted, 
    };

    await statsSnap.ref.update(payload);

    // Update user's stats.
    const userSnap = await firestore
      .collection('users')
      .doc(bookData.user.id)
      .get();

    const userData = userSnap.data();

    if (!userSnap.exists || !userData) {
      return false;
    }

    let userDeleted: number = userData.stats?.books?.deleted;
    let userOwned: number = userData.stats?.books?.owned;

    userDeleted = typeof userDeleted === 'number' ? userDeleted : 0;
    userOwned = typeof userOwned === 'number' ? userOwned : 0;

    userOwned = Math.max(0, userOwned - 1);
    userDeleted++

    await userSnap.ref.update({
      'stats.books.owned': userOwned,
      'stats.books.deleted': userDeleted,
      updatedAt: adminApp.firestore.Timestamp.now(),
    });

    return true;
  });


// -------------
// Illustrations
// -------------
export const onCreateIllustration = functions
  .region('europe-west3')
  .firestore
  .document('illustrations/{illustrationId}')
  .onCreate(async (illustrationSnap) => {
    const illustrationData = illustrationSnap.data();

    const statsSnap = await firestore
      .collection('stats')
      .doc('illustrations')
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
    await statsSnap.ref.update(payload);

    // Update user's stats.
    const userSnap = await firestore
      .collection('users')
      .doc(illustrationData.user.id)
      .get();

    const userData = userSnap.data();

    if (!userSnap.exists || !userData) {
      return false;
    }

    let userCreated: number = userData.stats?.illustrations?.created ?? 0;
    let userOwned: number = userData.stats?.illustrations?.owned ?? 0;

    userCreated = typeof userCreated === 'number' ? userCreated + 1 : 1;
    userOwned = typeof userOwned === 'number' ? userOwned + 1 : 1;

    await userSnap.ref.update({
      'stats.illustrations.created': userCreated,
      'stats.illustrations.owned': userOwned,
      updatedAt: adminApp.firestore.Timestamp.now(),
    });

    return true;
  });


export const onDeleteIllustration = functions
  .region('europe-west3')
  .firestore
  .document('illustrations/{illustrationId}')
  .onDelete(async (illustrationSnap) => {
    const illustrationData = illustrationSnap.data();

    const statsSnap = await firestore
      .collection('stats')
      .doc('illustrations')
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

    let payload: Record<string, number> = { total, deleted };
    await statsSnap.ref.update(payload);

    // Update user's stats.
    const userSnap = await firestore
      .collection('users')
      .doc(illustrationData.user.id)
      .get();

    const userData = userSnap.data();

    if (!userSnap.exists || !userData) {
      return false;
    }

    let imageBytesToRemove = 0;

    if (illustrationData) {
      imageBytesToRemove = illustrationData.size ?? 0;
    }

    let storageIllustrationsUsed: number = userData.stats.storage.illustrations.used;
    storageIllustrationsUsed -= imageBytesToRemove;
    
    let userDeleted: number = userData.stats?.illustrations?.deleted;
    let userOwned: number = userData.stats?.illustrations?.owned;

    userDeleted = typeof userDeleted === 'number' ? userDeleted : 0;
    userOwned = typeof userOwned === 'number' ? userOwned : 0;

    userOwned = Math.max(0, userOwned - 1);
    userDeleted++

    await userSnap.ref.update({
      'stats.illustrations.owned': userOwned,
      'stats.illustrations.deleted': userDeleted,
      'stats.storage.illustrations.used': storageIllustrationsUsed,
      updatedAt: adminApp.firestore.Timestamp.now(),
    });

    return true;
  });

// ------
// Users
// ------
export const onCreateUser = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onCreate(async (userSnap) => {
    const userData = userSnap.data();
    const isDev: boolean = userData.developer?.isProgramActive;

    const statsSnap = await firestore
      .collection('stats')
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

    await statsSnap.ref.update(payload);
    return true;
  });

export const onUpdateUser = functions
  .region('europe-west3')
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
      .collection('stats')
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
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onDelete(async (userSnap) => {
    const userData = userSnap.data();
    const wasDev: boolean = userData.developer?.isProgramActive ?? false;

    const statsSnap = await firestore
      .collection('stats')
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

    await statsSnap.ref.update(payload);
    return true;
  });

