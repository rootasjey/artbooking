import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { 
  arraysEqual,
  BOOKS_COLLECTION_NAME, 
  BOOK_DOC_PATH, 
  cloudRegions, 
  ILLUSTRATIONS_COLLECTION_NAME, 
  POSTS_COLLECTION_NAME, 
  STATISTICS_COLLECTION_NAME, 
  STORAGES_DOCUMENT_NAME, 
  USERS_COLLECTION_NAME, 
  USER_STATISTICS_COLLECTION_NAME,
} from './utils';

const firestore = adminApp.firestore();

const ILLUSTRATION_DOC_PATH = 'illustrations/{illustration_id}'
const POST_DOC_PATH = "posts/{post_id}"
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

// -------------
// Posts
// -------------
export const onCreatePost = functions
  .region(cloudRegions.eu)
  .firestore
  .document(POST_DOC_PATH)
  .onCreate(async (postSnapshot) => {
    const postData = postSnapshot.data();

    // Update global posts stats.
    // ---------------------------------
    const postStatsSnapshot = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(POSTS_COLLECTION_NAME)
      .get();

    const postStatsData = postStatsSnapshot.data();
    if (!postStatsSnapshot.exists || !postStatsData) {
      return false;
    }

    let globalPostCreated: number = postStatsData.created ?? 0;
    let globalPostCurrent: number = postStatsData.current ?? 0;
    let globalPostDrafts: number = postStatsData.drafts ?? 0;

    globalPostCreated = typeof globalPostCreated === 'number' ? globalPostCreated + 1 : 1;
    globalPostCurrent = typeof globalPostCurrent === 'number' ? globalPostCurrent + 1 : 1;

    if (postData.visibility === 'private') {
      globalPostDrafts = typeof globalPostDrafts === 'number' ? globalPostDrafts + 1 : 1;
    }

    await postStatsSnapshot.ref.update({
      created: globalPostCreated, 
      current: globalPostCurrent, 
      drafts: globalPostDrafts,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    // Update user's posts stats.
    // ---------------------------------
    for await (const user_id of postData.user_ids) {
      await updateUserPostStatsAfterCreate({
        postData,
        userId : user_id,
      });
    }

    return true;
  });

export const onDeletePost = functions
  .region(cloudRegions.eu)
  .firestore
  .document(POST_DOC_PATH)
  .onDelete(async (postSnapshot) => {
    const postData = postSnapshot.data();

    // Update global post stats.
    // ---------------------------------
    const postStatsSnapshot = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(POSTS_COLLECTION_NAME)
      .get();

    const postStatsData = postStatsSnapshot.data();
    if (!postStatsSnapshot.exists || !postStatsData) {
      return false;
    }

    let globalPostCurrent: number = postStatsData.current ?? 0;
    let globalPostDeleted: number = postStatsData.deleted ?? 0;
    let globalPostDrafts: number = postStatsData.drafts ?? 0;

    globalPostCurrent = typeof globalPostCurrent === 'number' ? globalPostCurrent : 0;
    globalPostDeleted = typeof globalPostDeleted === 'number' ? globalPostDeleted : 0;
    
    globalPostCurrent = Math.max(0, globalPostCurrent - 1);
    globalPostDeleted++;

    if (postData.visibility === 'private') {
      globalPostDrafts = typeof globalPostDrafts === 'number' ? globalPostDrafts - 1 : 0;
    }

    await postStatsSnapshot.ref.update({
      current: globalPostCurrent, 
      deleted: globalPostDeleted,
      drafts: globalPostDrafts,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    // Update user's post stats.
    // ---------------------------------
    for await (const user_id of postData.user_ids) {
      await updateUserPostStatsAfterDelete({
        postData,
        userId: user_id,
      });
    }

    return true;
  });

export const onUpdatePost = functions
  .region(cloudRegions.eu)
  .firestore
  .document(POST_DOC_PATH)
  .onUpdate(async (changeSnapshot) => {
    const beforeData = changeSnapshot.before.data();
    const afterData = changeSnapshot.after.data();

    const beforeUserIds: string[] = beforeData.user_ids;
    const afterUserIds: string[] = afterData.user_ids;

    if (!arraysEqual(beforeUserIds, afterUserIds)) {
      // If there are new user ids after (missing in before).
      const newUserIds: string[] = afterUserIds
        .filter((userId: string) => !beforeUserIds.includes(userId));

      await updateUserPostStatsAfterAddAuthors({
        postData: afterData,
        userIds: newUserIds,
      });
      
      // If there are missing user ids in after (that were there before).
      const removedUserIds: string[] = beforeUserIds
      .filter((userId: string) => !afterUserIds.includes(userId));
      
      await updateUserPostStatsAfterRemoveAuthors({
        postData: afterData,
        userIds: removedUserIds,
      });

      return true;
    }

    if (beforeData.visibility === afterData.visibility) {
      return true;
    }

    // Update global post stats.
    // ---------------------------------
    const postStatsSnapshot = await firestore
      .collection(STATISTICS_COLLECTION_NAME)
      .doc(POSTS_COLLECTION_NAME)
      .get();

    const postStatsData = postStatsSnapshot.data();
    if (!postStatsSnapshot.exists || !postStatsData) {
      return false;
    }

    let globalPostDrafts: number = postStatsData.drafts ?? 0;

    if (afterData.visibility === 'private' || afterData.visibility === 'acl') {
      globalPostDrafts = typeof globalPostDrafts === 'number' ? globalPostDrafts + 1 : 0;
    }

    if (afterData.visibility === 'public') {
      globalPostDrafts = typeof globalPostDrafts === 'number' ? globalPostDrafts - 1 : 0;
    }

    await postStatsSnapshot.ref.update({
      drafts: globalPostDrafts,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

    // Update users' post stats.
    // ---------------------------------
    for await (const user_id of afterData.user_ids) {
      await updateUserPostStatsAfterUpdate({
        userId: user_id, 
        postData: afterData,
      });
    }

    return true;
  })

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

// ~~~~~~~~
// HELPERS
// ~~~~~~~~

/**
 * Update an user's post statistics after adding authors to a post.
 * @param updateUserPostStatsParams Contains post's data and user's id.
 * @returns Return true if eveything went well.
 */
 async function updateUserPostStatsAfterAddAuthors(updateUserPostStatsParams: UpdateUserListPostStatsParams) {
  const {postData, userIds } = updateUserPostStatsParams;

  for await (const userId of userIds) {
    await updateUserPostStatsAfterCreate({
      postData,
      userId,
    });
  }

  return true;
}

/**
 * Update an user's post statistics after creating a post.
 * @param updateUserPostStatsParams Contains post's data and user's id.
 * @returns Return true if eveything went well.
 */
async function updateUserPostStatsAfterCreate(updateUserPostStatsParams: UpdateUserPostStatsParams) {
  const {postData, userId } = updateUserPostStatsParams;

  const userPostStatsSnapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(userId)
      .collection(USER_STATISTICS_COLLECTION_NAME)
      .doc(POSTS_COLLECTION_NAME)
      .get();

    const userPostStatsData = userPostStatsSnapshot.data();
    if (!userPostStatsSnapshot.exists || !userPostStatsData) {
      return false;
    }

    let userPostCreated: number = userPostStatsData.created ?? 0;
    let userPostOwned: number = userPostStatsData.owned ?? 0;
    let userPostDrafts: number = userPostStatsData.drafts ?? 0;

    userPostCreated = typeof userPostCreated === 'number' ? userPostCreated + 1 : 1;
    userPostOwned = typeof userPostOwned === 'number' ? userPostOwned + 1 : 1;

    if (postData.visibility === 'private') {
      userPostDrafts = typeof userPostDrafts === 'number' ? userPostDrafts + 1 : 1;
    }

    await userPostStatsSnapshot.ref.update({
      created: userPostCreated,
      drafts: userPostDrafts,
      owned: userPostOwned,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

  return true;
}

/**
 * Update an user's post statistics after creating a post.
 * @param updateUserPostStatsParams Contains post's data and user's id.
 * @returns Return true if eveything went well.
 */
async function updateUserPostStatsAfterDelete(updateUserPostStatsParams: UpdateUserPostStatsParams) {
  const {postData, userId } = updateUserPostStatsParams;

  const userPostStatsSnapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(userId)
      .collection(USER_STATISTICS_COLLECTION_NAME)
      .doc(POSTS_COLLECTION_NAME)
      .get();

    const userPostStatsData = userPostStatsSnapshot.data();
    if (!userPostStatsSnapshot.exists || !userPostStatsData) {
      return false;
    }

    let userPostDeleted: number = userPostStatsData.deleted ?? 0;
    let userPostOwned: number = userPostStatsData.owned ?? 0;
    let userPostDrafts: number = userPostStatsData.drafts ?? 0;

    userPostDeleted = typeof userPostDeleted === 'number' ? userPostDeleted : 0;
    userPostOwned = typeof userPostOwned === 'number' ? userPostOwned : 0;

    if (postData.visibility === 'private') {
      userPostDrafts = typeof userPostDrafts === 'number' ? userPostDrafts - 1 : 1;
    }

    userPostOwned = Math.max(0, userPostOwned - 1);
    userPostDeleted++;

    await userPostStatsSnapshot.ref.update({
      deleted: userPostDeleted,
      drafts: userPostDrafts,
      owned: userPostOwned,
      updated_at: adminApp.firestore.Timestamp.now(),
    });

  return true;
}

/**
 * Update an user's post statistics after removing authors to a post.
 * @param updateUserPostStatsParams Contains post's data and user's id.
 * @returns Return true if eveything went well.
 */
 async function updateUserPostStatsAfterRemoveAuthors(updateUserPostStatsParams: UpdateUserListPostStatsParams) {
  const {postData, userIds } = updateUserPostStatsParams;

  for await (const userId of userIds) {
    await updateUserPostStatsAfterDelete({
      postData,
      userId,
    });
  }

  return true;
}

/**
 * Update an user's post statistics after a post's update.
 * @param updateUserPostStatsParams Contains post's data and user's id.
 * @returns Return true if eveything went well.
 */
 async function updateUserPostStatsAfterUpdate(updateUserPostStatsParams: UpdateUserPostStatsParams) {
  const {postData, userId } = updateUserPostStatsParams;

  const userPostStatsSnapshot = await firestore
    .collection(USERS_COLLECTION_NAME)
    .doc(userId)
    .collection(USER_STATISTICS_COLLECTION_NAME)
    .doc(POSTS_COLLECTION_NAME)
    .get();

  const userPostStatsData = userPostStatsSnapshot.data();
  if (!userPostStatsSnapshot.exists || !userPostStatsData) {
    return false;
  }

  let userPostDrafts: number = userPostStatsData.drafts ?? 0;

  if (postData.visibility === 'private' || postData.visibility === 'acl') {
    userPostDrafts = typeof userPostDrafts === 'number' ? userPostDrafts + 1 : 1;
  } else if (postData.visibility === 'public') {
    userPostDrafts = typeof userPostDrafts === 'number' ? userPostDrafts - 1 : 1;
  }

  await userPostStatsSnapshot.ref.update({
    drafts: userPostDrafts,
    updated_at: adminApp.firestore.Timestamp.now(),
  });

  return true;
}
