import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { BOOKS_COLLECTION_NAME, cloudRegions, ILLUSTRATIONS_COLLECTION_NAME, STATISTICS_COLLECTION_NAME, STORAGES_DOCUMENT_NAME, USERS_COLLECTION_NAME, USER_STATISTICS_COLLECTION_NAME } from './utils';

const firestore = adminApp.firestore();

const BOOK_DOC_PATH = 'books/{book_id}'
const ILLUSTRATION_DOC_PATH = 'illustrations/{illustration_id}'
const USER_DOC_PATH = 'users/{user_id}'

// ------
// Books
// ------
export const onCreateBook = functions
  .region(cloudRegions.eu)
  .firestore
  .document(BOOK_DOC_PATH)
  .onCreate(async (bookSnapshot) => {
    const bookData = bookSnapshot.data();

    // Update global books stats.
    // -------------------------
    const bookStatsSnapshot = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(BOOKS_COLLECTION_NAME)
      .get();

    const bookStatsData = bookStatsSnapshot.data();
    if (!bookStatsSnapshot.exists || !bookStatsData) {
      return false;
    }

    let globalBookCreated: number = bookStatsData.created ?? 0;
    let globalBookCurrent: number = bookStatsData.current ?? 0;

    globalBookCreated = typeof globalBookCreated === 'number' ? globalBookCreated + 1 : 1;
    globalBookCurrent = typeof globalBookCurrent === 'number' ? globalBookCurrent + 1 : 1;

    await bookStatsSnapshot.ref.update({
      created: globalBookCreated,
      current: globalBookCurrent,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    // Update user's books stats.
    // -------------------------
    const userBookStatsSnapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(bookData.user_id)
      .collection(USER_STATISTICS_COLLECTION_NAME)
      .doc(BOOKS_COLLECTION_NAME)
      .get();

    const userBookStatsData = userBookStatsSnapshot.data();
    if (!userBookStatsSnapshot.exists || !userBookStatsData) {
      return false;
    }

    let userBookCreated: number = userBookStatsData.created ?? 0;
    let userBookOwned: number = userBookStatsData.owned ?? 0;

    userBookCreated = typeof userBookCreated === 'number' ? userBookCreated + 1 : 1;
    userBookOwned = typeof userBookOwned === 'number' ? userBookOwned + 1 : 1;

    await userBookStatsSnapshot.ref.update({
      created: userBookCreated,
      owned: userBookOwned,
      updated_at: adminApp.firestore.Timestamp.now(),
    });
    
    return true;
  });


export const onDeleteBook = functions
  .region(cloudRegions.eu)
  .firestore
  .document(BOOK_DOC_PATH)
  .onDelete(async (bookSnapshot) => {
    const bookData = bookSnapshot.data();

    // Update global books stats.
    // -------------------------
    const bookStatsSnapshot = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(BOOKS_COLLECTION_NAME)
      .get();

    const bookStatsData = bookStatsSnapshot.data();
    if (!bookStatsSnapshot.exists || !bookStatsData) {
      return false;
    }

    let globalBookCurrent: number = bookStatsData.current ?? 0;
    let globalBookDeleted: number = bookStatsData.deleted ?? 0;

    globalBookCurrent = typeof globalBookCurrent === 'number' ? globalBookCurrent : 0;
    globalBookDeleted = typeof globalBookDeleted === 'number' ? globalBookDeleted : 0;

    globalBookCurrent = Math.max(0, globalBookCurrent - 1);
    globalBookDeleted++;

    await bookStatsSnapshot.ref.update({
      current: globalBookCurrent, 
      deleted: globalBookDeleted,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    // Update user's books stats.
    // -------------------------
    const userBookStatsSnapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(bookData.user_id)
      .collection(USER_STATISTICS_COLLECTION_NAME)
      .doc(BOOKS_COLLECTION_NAME)
      .get();

    const userBookStatsData = userBookStatsSnapshot.data();
    if (!userBookStatsSnapshot.exists || !userBookStatsData) {
      return false;
    }

    let userBookDeleted: number = userBookStatsData.deleted ?? 0;
    let userBookOwned: number = userBookStatsData.owned ?? 0;

    userBookDeleted = typeof userBookDeleted === 'number' ? userBookDeleted : 0;
    userBookOwned = typeof userBookOwned === 'number' ? userBookOwned : 0;

    userBookOwned = Math.max(0, userBookOwned - 1);
    userBookDeleted++

    await userBookStatsSnapshot.ref.update({
      deleted: userBookDeleted,
      owned: userBookOwned,
      updated_at: adminApp.firestore.Timestamp.now(),
    })

    return true;
  });


// -------------
// Illustrations
// -------------
export const onCreateIllustration = functions
  .region(cloudRegions.eu)
  .firestore
  .document(ILLUSTRATION_DOC_PATH)
  .onCreate(async (illustrationSnapshot) => {
    const illustrationData = illustrationSnapshot.data();

    // Update global illustrations stats.
    // ---------------------------------
    const illustrationStatsSnapshot = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(ILLUSTRATIONS_COLLECTION_NAME)
      .get();

    const illustrationStatsData = illustrationStatsSnapshot.data();
    if (!illustrationStatsSnapshot.exists || !illustrationStatsData) {
      return false;
    }

    let globalIllustrationCreated: number = illustrationStatsData.created ?? 0;
    let globalIllustrationCurrent: number = illustrationStatsData.current ?? 0;

    globalIllustrationCreated = typeof globalIllustrationCreated === 'number' ? globalIllustrationCreated + 1 : 1;
    globalIllustrationCurrent = typeof globalIllustrationCurrent === 'number' ? globalIllustrationCurrent + 1 : 1;

    await illustrationStatsSnapshot.ref.update({
      created: globalIllustrationCreated, 
      current: globalIllustrationCurrent, 
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    // Update user's illustrations stats.
    // ---------------------------------
    const userIllustrationStatsSnapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(illustrationData.user_id)
      .collection(USER_STATISTICS_COLLECTION_NAME)
      .doc(ILLUSTRATIONS_COLLECTION_NAME)
      .get();

    const userIllustrationStatsData = userIllustrationStatsSnapshot.data();
    if (!userIllustrationStatsSnapshot.exists || !userIllustrationStatsData) {
      return false;
    }

    let userIllustrationCreated: number = userIllustrationStatsData.created ?? 0;
    let userIllustrationOwned: number = userIllustrationStatsData.owned ?? 0;

    userIllustrationCreated = typeof userIllustrationCreated === 'number' ? userIllustrationCreated + 1 : 1;
    userIllustrationOwned = typeof userIllustrationOwned === 'number' ? userIllustrationOwned + 1 : 1;

    await userIllustrationStatsSnapshot.ref.update({
      created: userIllustrationCreated,
      owned: userIllustrationOwned,
      updated_at: adminApp.firestore.Timestamp.now(),
    })

    return true;
  });


export const onDeleteIllustration = functions
  .region(cloudRegions.eu)
  .firestore
  .document(ILLUSTRATION_DOC_PATH)
  .onDelete(async (illustrationSnapshot) => {
    const illustrationData = illustrationSnapshot.data();

    // Update global illustrations stats.
    // ---------------------------------
    const illustrationStatsSnapshot = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(ILLUSTRATIONS_COLLECTION_NAME)
      .get();

    const illustrationStatsData = illustrationStatsSnapshot.data();
    if (!illustrationStatsSnapshot.exists || !illustrationStatsData) {
      return false;
    }

    let globalIllustrationCurrent: number = illustrationStatsData.current ?? 0;
    let globalIllustrationDeleted: number = illustrationStatsData.deleted ?? 0;

    globalIllustrationCurrent = typeof globalIllustrationCurrent === 'number' ? globalIllustrationCurrent : 0;
    globalIllustrationDeleted = typeof globalIllustrationDeleted === 'number' ? globalIllustrationDeleted : 0;
    
    globalIllustrationCurrent = Math.max(0, globalIllustrationCurrent - 1);
    globalIllustrationDeleted++;

    await illustrationStatsSnapshot.ref.update({
      current: globalIllustrationCurrent, 
      deleted: globalIllustrationDeleted,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    // Update user's illustrations stats.
    // ---------------------------------
    const userIllustrationStatsSnapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(illustrationData.user_id)
      .collection(USER_STATISTICS_COLLECTION_NAME)
      .doc(ILLUSTRATIONS_COLLECTION_NAME)
      .get();

    const userIllustrationStatsData = userIllustrationStatsSnapshot.data();
    if (!userIllustrationStatsSnapshot.exists || !userIllustrationStatsData) {
      return false;
    }

    let userIllustrationDeleted: number = userIllustrationStatsData.deleted ?? 0;
    let userIllustrationOwned: number = userIllustrationStatsData.owned ?? 0;

    userIllustrationDeleted = typeof userIllustrationDeleted === 'number' ? userIllustrationDeleted : 0;
    userIllustrationOwned = typeof userIllustrationOwned === 'number' ? userIllustrationOwned : 0;

    userIllustrationOwned = Math.max(0, userIllustrationOwned - 1);
    userIllustrationDeleted++;

    await userIllustrationStatsSnapshot.ref.update({
      deleted: userIllustrationDeleted,
      owned: userIllustrationOwned,
      updated_at: adminApp.firestore.Timestamp.now(),
    })

    // Update user's storages stats.
    // ---------------------------------
    const imageBytesToRemove = illustrationData?.size ?? 0;

    const storageSnapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(illustrationData.user_id)
      .collection(USER_STATISTICS_COLLECTION_NAME)
      .doc(STORAGES_DOCUMENT_NAME)
      .get();
    
    const storageData = storageSnapshot.data();
    if (!storageSnapshot.exists || !storageData) {
      return
    }

    let userStorageIllustrationsUsed: number = storageData.illustrations.used;
    userStorageIllustrationsUsed -= imageBytesToRemove;
    
    await storageSnapshot.ref.update({
      illustrations: {
        used: userStorageIllustrationsUsed,
        updated_at: adminApp.firestore.Timestamp.now(),
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
  .document(USER_DOC_PATH)
  .onCreate(async (userSnapshot) => {
    const userStatsSnapshot = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(USERS_COLLECTION_NAME)
      .get();

    const userStatsData = userStatsSnapshot.data();
    if (!userStatsSnapshot.exists || !userStatsData) {
      return false;
    }

    let globalUserCurrent: number = userStatsData.current ?? 0;
    let globalUserCreated: number = userStatsData.created ?? 0;

    globalUserCurrent = typeof globalUserCurrent === 'number' ? globalUserCurrent + 1 : 1;
    globalUserCreated = typeof globalUserCreated === 'number' ? globalUserCreated + 1 : 1;

    return await userStatsSnapshot.ref.update({ 
      created: globalUserCreated, 
      current: globalUserCurrent, 
      updated_at: adminApp.firestore.Timestamp.now(), 
    });
  });

export const onDeleteUser = functions
  .region(cloudRegions.eu)
  .firestore
  .document(USER_DOC_PATH)
  .onDelete(async (userSnapshot) => {
    const userStatsSnapshot = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(USERS_COLLECTION_NAME)
      .get();

    const userStatsData = userStatsSnapshot.data();
    if (!userStatsSnapshot.exists || !userStatsData) {
      return false;
    }

    let globalUserCurrent: number = userStatsData.current ?? 0;
    let globalUserDeleted: number = userStatsData.deleted ?? 0;

    globalUserCurrent = typeof globalUserCurrent === 'number' ? globalUserCurrent : 0;
    globalUserDeleted = typeof globalUserDeleted === 'number' ? globalUserDeleted : 0;

    globalUserCurrent = Math.max(0, globalUserCurrent - 1);
    globalUserDeleted++;

    await userStatsSnapshot.ref.update({ 
      current: globalUserCurrent,
      deleted: globalUserDeleted,
      updated_at: adminApp.firestore.Timestamp.now(), 
    });

    return true;
  });

