import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';
import { 
  BASE_DOCUMENT_NAME, 
  BOOKS_COLLECTION_NAME, 
  BOOK_LIKED_BY_COLLECTION_NAME, 
  BOOK_STATISTICS_COLLECTION_NAME, 
  CHALLENGES_COLLECTION_NAME, 
  checkUserIsSignedIn, 
  cloudRegions, 
  CONTESTS_COLLECTION_NAME, 
  GALLERIES_COLLECTION_NAME, 
  ILLUSTRATIONS_COLLECTION_NAME, 
  ILLUSTRATION_LIKED_BY_COLLECTION_NAME, 
  ILLUSTRATION_STATISTICS_COLLECTION_NAME, 
  LAYOUT_DOC_NAME, 
  LIKE_BOOK_TYPE, 
  LIKE_ILLUSTRATION_TYPE, 
  LIKE_POST_TYPE, 
  NOTIFICATIONS_DOCUMENT_NAME, 
  POSTS_COLLECTION_NAME, 
  POST_LIKED_BY_COLLECTION_NAME, 
  POST_STATISTICS_COLLECTION_NAME, 
  randomIntFromInterval, 
  STORAGES_DOCUMENT_NAME, 
  USERS_COLLECTION_NAME, 
  USER_PUBLIC_FIELDS_COLLECTION_NAME, 
  USER_SETTINGS_COLLECTION_NAME, 
  USER_STATISTICS_COLLECTION_NAME 
} from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

const LIKE_DOC_PATH = 'users/{user_id}/user_likes/{like_id}'

export const checkEmailAvailability = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data) => {
    const email: string = data.email;

    if (typeof email !== 'string' || email.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with one (string) ` +
        `argument [email] which is the email to check.`,
      );
    }

    if (!validateEmailFormat(email)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid email address.`,
      );
    }

    const exists = await isUserExistsByEmail(email);
    const isAvailable = !exists;

    return {
      email,
      isAvailable,
    };
  });

export const checkUsernameAvailability = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data) => {
    const usernname: string = data.usernname;

    if (typeof usernname !== 'string' || usernname.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with one (string) ` +
        `argument "usernname" which is the usernname to check.`,
      );
    }

    if (!validateNameFormat(usernname)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [usernname] ` +
        `with at least 3 alpha-numeric characters (underscore is allowed) (A-Z, 0-9, _).`,
      );
    }

    const snapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .where('name_lower_case', '==', usernname.toLowerCase())
      .limit(1)
      .get();

    return {
      usernname: usernname,
      isAvailable: snapshot.empty,
    };
  });

/**
 * Create an user with Firebase auth then with Firestore.
 * Check user's provided arguments and exit if wrong.
 */
export const createAccount = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: CreateUserAccountParams) => {
    if (!checkCreateAccountData(data)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with 3 string 
        arguments [username], [email] and [password].`,
      );
    }

    const { username, password, email } = data;

    const userAuthRecord = await adminApp
      .auth()
      .createUser({
        password: password,
        email: email,
        emailVerified: false,
      });

    await adminApp.firestore()
      .collection(USERS_COLLECTION_NAME)
      .doc(userAuthRecord.uid)
      .set({
        bio: '',
        created_at: adminApp.firestore.FieldValue.serverTimestamp(),
        email: email,
        language: 'en',
        name: username,
        name_lower_case: username.toLowerCase(),
        pricing: 'free',
        profile_picture: {
          dimensions: {
            height: 0,
            width: 0,
          },
          extension: '',
          links: {
            edited: '',
            original: getRandomProfilePictureLink(),
            storage: '',
          },
          size: 0,
          type: '',
          updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
        },
        rights: {
          'user:manage_art_movements': false,
          'user:manage_data': false,
          'user:manage_licenses': false,
          'user:manage_pages': false,
          'user:manage_posts': false,
          'user:manage_reviews': false,
          'user:manage_sections': false,
          'user:manage_users': false,
        },
        social_links: {
          artbooking: '',
          artstation: '',
          devianart: '',
          discord: '',
          dribbble: '',
          facebook: '',
          instagram: '',
          patreon: '',
          tumblr: '',
          tiktok: '',
          tipeee: '',
          twitch: '',
          twitter: '',
          website: '',
          wikipedia: '',
          youtube: '',
        },
        updated_at: adminApp.firestore.Timestamp.now(),
        user_id: userAuthRecord.uid,
      });

    await createUserStatisticsCollection(userAuthRecord.uid)
    await createUserSettingsCollection(userAuthRecord.uid)

    return {
      user: {
        id: userAuthRecord.uid,
        email,
      },
    };
  });

/**
 * Delete user's entry from Firebase auth and from Firestore. 
 */
export const deleteAccount = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: DeleteAccountParams, context) => {
    const userAuth = context.auth;
    const { id_token } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, id_token);

    const userSnapshot = await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(userAuth.uid)
      .get();

    const userData = userSnapshot.data();
    if (!userSnapshot.exists || !userData) {
      throw new functions.https.HttpsError(
        'not-found',
        `This user document doesn't exist. It may have been deleted.`,
      );
    }

    await adminApp
      .auth()
      .deleteUser(userAuth.uid);

    await firebaseTools.firestore
      .delete(userSnapshot.ref.path, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
      });

    return {
      success: true,
      user: {
        id: userAuth.uid,
      },
    };
  });

/**
 * When an user likes something (illustration, book).
 */
export const onLike = functions
  .region(cloudRegions.eu)
  .firestore
  .document(LIKE_DOC_PATH)
  .onCreate(async (likeSnapshot, context) => {
    const data = likeSnapshot.data();
    const { type, target_id, user_id } = data;

    // Check fields availability.
    if (!data || !type || !target_id) {
      return await likeSnapshot.ref.delete();
    }

    if (type !== LIKE_ILLUSTRATION_TYPE && type !== LIKE_BOOK_TYPE 
        && type !== LIKE_POST_TYPE) {
      return await likeSnapshot.ref.delete();
    }

    if (target_id !== likeSnapshot.id) {
      return await likeSnapshot.ref.delete();
    }

    // Check fields match right values
    if (type === LIKE_ILLUSTRATION_TYPE) {
      const illustrationSnapshot = await firestore
        .collection(ILLUSTRATIONS_COLLECTION_NAME)
        .doc(likeSnapshot.id)
        .get();

      if (!illustrationSnapshot.exists) {
        return await likeSnapshot.ref.delete();
      }
    }

    if (type === LIKE_BOOK_TYPE) {
      const bookSnapshot = await firestore
        .collection(BOOKS_COLLECTION_NAME)
        .doc(likeSnapshot.id)
        .get();

      if (!bookSnapshot.exists) {
        return await likeSnapshot.ref.delete();
      }
    }

    if (type === LIKE_POST_TYPE) {
      const postSnapshot = await firestore
        .collection(POSTS_COLLECTION_NAME)
        .doc(likeSnapshot.id)
        .get();

      if (!postSnapshot.exists) {
        return await likeSnapshot.ref.delete();
      }
    }

    const user_id_path_param: string = context.params.user_id;
    if (user_id !== user_id_path_param) {
      return await likeSnapshot.ref.delete();
    }

    await incrementUserLikeCount(user_id_path_param, type)
    await incrementDocumentLikeCount(likeSnapshot.id, type)

    if (type === LIKE_BOOK_TYPE) {
      await addUserToBookLike(likeSnapshot.id, user_id_path_param)
    }

    if (type === LIKE_ILLUSTRATION_TYPE) {
      await addUserToIllustrationLike(likeSnapshot.id, user_id_path_param)
    }

    if (type === LIKE_POST_TYPE) {
      await addUserToPostLike(likeSnapshot.id, user_id_path_param)
    }

    return await likeSnapshot.ref.update({
      created_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });
  });

/**
 * When an user un-likes something (illustration, book).
 */
export const onUnLike = functions
  .region(cloudRegions.eu)
  .firestore
  .document(LIKE_DOC_PATH)
  .onDelete(async (likeSnapshot, context) => {
    const data = likeSnapshot.data();
    const { type, target_id } = data;

    // Check fields availability.
    if (!data || !type || !target_id) {
      return;
    }

    if (type !== LIKE_ILLUSTRATION_TYPE && type !== LIKE_BOOK_TYPE 
        && type !== LIKE_POST_TYPE) {
      return;
    }

    if (target_id !== likeSnapshot.id) {
      return;
    }

    // Check fields match right values
    if (type === LIKE_ILLUSTRATION_TYPE) {
      const illustrationSnapshot = await firestore
        .collection(ILLUSTRATIONS_COLLECTION_NAME)
        .doc(likeSnapshot.id)
        .get();

      if (!illustrationSnapshot.exists) {
        return;
      }
    }

    if (type === LIKE_BOOK_TYPE) {
      const bookSnapshot = await firestore
        .collection(BOOKS_COLLECTION_NAME)
        .doc(likeSnapshot.id)
        .get();

      if (!bookSnapshot.exists) {
        return;
      }
    }

    if (type === LIKE_POST_TYPE) {
      const bookSnapshot = await firestore
        .collection(POSTS_COLLECTION_NAME)
        .doc(likeSnapshot.id)
        .get();

      if (!bookSnapshot.exists) {
        return;
      }
    }

    const user_id_path_param: string = context.params.user_id
    await decrementUserLikeCount(user_id_path_param, type)
    await decrementDocumentLikeCount(likeSnapshot.id, type)

    if (type === LIKE_BOOK_TYPE) {
      await removeUserToBookLike(likeSnapshot.id, user_id_path_param)
    }

    if (type === LIKE_ILLUSTRATION_TYPE) {
      await removeUserToIllustrationLike(likeSnapshot.id, user_id_path_param)
    }

    if (type === LIKE_POST_TYPE) {
      await removeUserToPostLike(likeSnapshot.id, user_id_path_param)
    }

    return true
  });

/**
 * Create user's public information from private fields.
 */
export const onCreatePublicInfo = functions
  .region(cloudRegions.eu)
  .firestore
  .document('users/{user_id}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const user_id_path_param: string = context.params.user_id;

    return await adminApp.firestore()
      .collection(USERS_COLLECTION_NAME)
      .doc(user_id_path_param)
      .collection(USER_PUBLIC_FIELDS_COLLECTION_NAME)
      .doc(BASE_DOCUMENT_NAME)
      .create({
        created_at: adminApp.firestore.FieldValue.serverTimestamp(),
        id: user_id_path_param,
        location: data.location,
        name: data.name,
        profile_picture: data.profile_picture,
        lore: data.lore,
        social_links: data.social_links,
        type: "base",
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      });
  });

/**
 * Keep public user's information in-sync with privated fields.
 * Fired after document change for an user.
 */
export const onUpdatePublicInfo = functions
  .region(cloudRegions.eu)
  .firestore
  .document('users/{user_id}')
  .onUpdate(async (change, context) => {
    const shouldUpdate = shouldUpdatePublicInfo(change);
    if (!shouldUpdate) {
      return false;
    }

    const afterData = change.after.data();
    const user_id: string = context.params.user_id;

    return await adminApp.firestore()
      .collection(USERS_COLLECTION_NAME)
      .doc(user_id)
      .collection(USER_PUBLIC_FIELDS_COLLECTION_NAME)
      .doc(BASE_DOCUMENT_NAME)
      .update({
        bio: afterData.bio ?? '',
        location: afterData.location,
        name: afterData.name,
        profile_picture: afterData.profile_picture,
        social_links: afterData.social_links,
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      });
  });

/**
 * Update an user's email in Firebase auth and in Firestore.
 * Several security checks are made (email format, password, email unicity)
 * before validating the new email.
 */
export const updateEmail = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: UpdateEmailParams, context) => {
    const userAuth = context.auth;
    const { id_token, email } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user (1).`,
      );
    }

    await checkUserIsSignedIn(context, id_token);
    const isFormatOk = validateEmailFormat(email);

    if (!email || !isFormatOk) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [newEmail] argument. 
        The value you specified is not in a correct email format.`,
      );
    }

    const isEmailTaken = await isUserExistsByEmail(email);

    if (isEmailTaken) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The email specified is not available.
         Try specify a new one in the "newEmail" argument.`,
      );
    }

    await adminApp
      .auth()
      .updateUser(userAuth.uid, {
        email: email,
        emailVerified: false,
      });

    await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(userAuth.uid)
      .update({
        email: email,
      });

    return {
      success: true,
      user: { id: userAuth.uid },
    };
  });

/**
 * Update a new username in Firebase auth and in Firestore.
 * Several security checks are made (name format & unicity, password)
 * before validating the new username.
 */
export const updateUsername = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data: UpdateUsernameParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const { username } = data;
    const isFormatOk = validateNameFormat(username);

    if (!username || !isFormatOk) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [username]. ` +
         `The value you specified is not in a correct format.`,
      );
    }

    const isUsernameTaken = await isUserExistsByUsername(username.toLowerCase());

    if (isUsernameTaken) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The name specified is not available. ` +
         `Please try with a new one.`,
      );
    }

    await adminApp
      .auth()
      .updateUser(userAuth.uid, {
        displayName: username,
      });

    await firestore
      .collection(USERS_COLLECTION_NAME)
      .doc(userAuth.uid)
      .update({
        name: username,
        name_lower_case: username.toLowerCase(),
      });

    return {
      success: true,
      user: { id: userAuth.uid },
    };
  });

/**
 * Update user's lore, location.
 */
export const updatePublicStrings = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const bio: string = data.bio ?? '';
    const location: string = data.location ?? '';

    if (typeof bio !== 'string' || typeof location !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `You provided a wrong argument type for [bio] or [location]. ` +
        `Both arguments should be string, but their value are: ` +
        `bio (${typeof bio}): ${bio}, location (${typeof location}): ${location}.`,
      );
    }

    return await adminApp.firestore()
      .collection(USERS_COLLECTION_NAME)
      .doc(userAuth.uid)
      .update({
        bio,
        location,
      });
  });

/**
 * Update user's social links.
 */
export const updateSocialLinks = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const {social_links} = data;

    if (typeof social_links !== 'object') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `You provided a wrong argument type for [social_links]. ` +
        `The function should be called with a [social_links] argument wich is an object or map of strings.`,
      );
    }

    for (const [key, value] of Object.entries(social_links)) {
      if (typeof key !== 'string' || typeof value !== 'string') {
        throw new functions.https.HttpsError(
          'invalid-argument',
          `The [social_links] argument is not a map of (string, string) for (key, value). ` +
          `${key} has a type of ${typeof key}. ${value} has a type of ${typeof value}`,
        );
      }
    }

    return await adminApp.firestore()
      .collection(USERS_COLLECTION_NAME)
      .doc(userAuth.uid)
      .update({
        social_links: social_links
      });
  });

// ----------------
// HELPER FUNCTIONS
// ----------------

function checkCreateAccountData(data: any) {
  if (Object.keys(data).length !== 3) {
    return false;
  }

  const keys = Object.keys(data);

  if (!keys.includes('username')
    || !keys.includes('email')
    || !keys.includes('password')) {
    return false;
  }

  if (typeof data.username !== 'string' ||
    typeof data.email !== 'string' ||
    typeof data.password !== 'string') {
    return false;
  }

  return true;
}

async function createUserSettingsCollection(user_id: string) {
  return await adminApp.firestore()
  .collection(USERS_COLLECTION_NAME)
  .doc(user_id)
  .collection(USER_SETTINGS_COLLECTION_NAME)
  .doc(LAYOUT_DOC_NAME)
  .create({
    illustrations_three_in_a_row: true,
    book_default_layout: "grid",
  });
}
/**
 * Create user's statistics sub-collection.
 * @param user_id User's id.
 */
 async function createUserStatisticsCollection(user_id: string) {
  const userStatsCollection = adminApp.firestore()
  .collection(USERS_COLLECTION_NAME)
  .doc(user_id)
  .collection(USER_STATISTICS_COLLECTION_NAME);

  await userStatsCollection
    .doc(BOOKS_COLLECTION_NAME)
    .create({
      created: 0,
      deleted: 0,
      liked: 0,
      name: BOOKS_COLLECTION_NAME,
      owned: 0,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      user_id,
    })

  await userStatsCollection
    .doc(CHALLENGES_COLLECTION_NAME)
    .create({
      created: 0,
      deleted: 0,
      entered: 0,
      name: CHALLENGES_COLLECTION_NAME,
      owned: 0,
      participating: 0,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      user_id,
      won: 0,
    })

  await userStatsCollection
    .doc(CONTESTS_COLLECTION_NAME)
    .create({
      created: 0,
      deleted: 0,
      entered: 0,
      name: CONTESTS_COLLECTION_NAME,
      owned: 0,
      participating: 0,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      user_id,
      won: 0,
    })

  await userStatsCollection
    .doc(GALLERIES_COLLECTION_NAME)
    .create({
      created: 0,
      deleted: 0,
      entered: 0,
      name: GALLERIES_COLLECTION_NAME,
      opened: 0,
      owned: 0,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      user_id,
    })

  await userStatsCollection
    .doc(ILLUSTRATIONS_COLLECTION_NAME)
    .create({
      created: 0,
      deleted: 0,
      liked: 0,
      name: ILLUSTRATIONS_COLLECTION_NAME,
      owned: 0,
      updated: 0,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      user_id,
    })

  await userStatsCollection
    .doc(POSTS_COLLECTION_NAME)
    .create({
      created: 0,
      deleted: 0,
      drafts: 0,
      liked: 0,
      name: POSTS_COLLECTION_NAME,
      owned: 0,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      user_id,
    })

  await userStatsCollection
    .doc(NOTIFICATIONS_DOCUMENT_NAME)
    .create({
      name: NOTIFICATIONS_DOCUMENT_NAME,
      total: 0,
      unread: 0,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      user_id,
    })


  await userStatsCollection
    .doc(STORAGES_DOCUMENT_NAME)
    .create({ // all number values are in bytes
      illustrations: {
        total: 0,
        used: 0,
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      },
      name: STORAGES_DOCUMENT_NAME,
      user_id,
      videos: {
        total: 0,
        used: 0,
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      },
    })
}

/**
 * Decrement of 1 the likes count of an illustration or a book.
 * @param userId User's id.
 * @param likeType Should be equals to 'book' or 'illustration'.
 * @returns void.
 */
async function decrementUserLikeCount(userId:string, likeType: string) {
  let docName = ''; 

  if (likeType === LIKE_BOOK_TYPE) {
    docName = BOOKS_COLLECTION_NAME;
  } else if (likeType === LIKE_ILLUSTRATION_TYPE) {
    docName = ILLUSTRATIONS_COLLECTION_NAME;
  } else if (likeType === LIKE_POST_TYPE) {
    docName = POSTS_COLLECTION_NAME;
  }

  const snapshot = await firestore
    .collection(USERS_COLLECTION_NAME)
    .doc(userId)
    .collection(USER_STATISTICS_COLLECTION_NAME)
    .doc(docName)
    .get();

  const data = snapshot.data();
  if (!snapshot.exists || !data) { return; }

  let liked: number = data.liked;
  liked = typeof liked === 'number' ? liked - 1: 0;
  liked = Math.max(0, liked);

  return await snapshot.ref.update({
    liked,
    updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Decrement of 1 the likes count of an illustration or a book.
 * @param documentId Illustration's id or book's id.
 * @param likeType Should be equals to 'book' or 'illustration'.
 * @returns void.
 */
async function decrementDocumentLikeCount(documentId:string, likeType: string) {
  let collectionName = ''; 
  let statsCollectionName = '';

  if (likeType === LIKE_BOOK_TYPE) {
    collectionName = BOOKS_COLLECTION_NAME;
    statsCollectionName = BOOK_STATISTICS_COLLECTION_NAME;
  } else if (likeType === LIKE_ILLUSTRATION_TYPE) {
    collectionName = ILLUSTRATIONS_COLLECTION_NAME;
    statsCollectionName = ILLUSTRATION_STATISTICS_COLLECTION_NAME;
  } else if (likeType === LIKE_POST_TYPE) {
    collectionName = POSTS_COLLECTION_NAME;
    statsCollectionName = POST_STATISTICS_COLLECTION_NAME;
  }

  const snapshot = await firestore
    .collection(collectionName)
    .doc(documentId)
    .collection(statsCollectionName)
    .doc(BASE_DOCUMENT_NAME)
    .get();

  const data = snapshot.data();
  if (!snapshot.exists || !data) { return; }

  let likes: number = data.likes;
  likes = typeof likes === 'number' ? likes - 1 : 0;
  likes = Math.max(0, likes);

  return await snapshot.ref.update({ 
    likes,
    updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Increment of 1 the likes count of an illustration or a book.
 * @param userId User's id.
 * @param likeType Should be equals to 'book' or 'illustration'.
 * @returns void.
 */
 async function incrementUserLikeCount(userId:string, likeType: string) {
  let docStatsName = '';

  if (likeType === LIKE_BOOK_TYPE) {
    docStatsName = BOOKS_COLLECTION_NAME;
  } else if (likeType === LIKE_ILLUSTRATION_TYPE) {
    docStatsName = ILLUSTRATIONS_COLLECTION_NAME;
  } else if (likeType === LIKE_POST_TYPE) {
    docStatsName = POSTS_COLLECTION_NAME;
  }

  const userStatsSnapshot = await firestore
    .collection(USERS_COLLECTION_NAME)
    .doc(userId)
    .collection(USER_STATISTICS_COLLECTION_NAME)
    .doc(docStatsName)
    .get();

  const userStatsData = userStatsSnapshot.data();
  if (!userStatsSnapshot.exists || !userStatsData) { return; }

  let liked: number = userStatsData.liked;
  liked = typeof liked === 'number' ? liked + 1: 1;

  return await userStatsSnapshot.ref.update({
    liked,
    updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Return a random profile picture url (pre-defined images).
 * @returns A random profile picture url.
 */
function getRandomProfilePictureLink(): string {
  const sampleAvatars = [
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatars%2Favatar_woman_0.png?alt=media&token=d6ab47e3-709f-449a-a6c6-b53f854ec0fb",
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatars%2Favatar_man_2.png?alt=media&token=9a4cc0ce-b12f-4095-a49e-9a38ed44d5de",
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatars%2Favatar_man_1.png?alt=media&token=1d405ba5-7ec3-4058-ba59-6360c4dfc200",
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatars%2Favatar_man_0.png?alt=media&token=2c8edef3-5e6f-4b84-a52b-2c9034951e20",
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatars%2Favatar_woman_2.png?alt=media&token=a6f889d9-0ca1-4aa7-8aa5-f137d6fca138",
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatars%2Favatar_woman_1.png?alt=media&token=2ef023f4-53c8-466b-93e4-70f58e6067bb",
  ]

  return sampleAvatars[randomIntFromInterval(0, sampleAvatars.length -1)]
}

/**
 * Increment of 1 the likes count of an illustration or a book.
 * @param documentId Illustration's id or book's id.
 * @param likeType Should be equals to 'book' or 'illustration'.
 * @returns void.
 */
 async function incrementDocumentLikeCount(documentId:string, likeType: string) {
  let collectionName = '';
  let statsCollectionName = '';
  
  if (likeType === LIKE_BOOK_TYPE) {
    collectionName = BOOKS_COLLECTION_NAME;
    statsCollectionName = BOOK_STATISTICS_COLLECTION_NAME;
  } else if (likeType === LIKE_ILLUSTRATION_TYPE) {
    collectionName = ILLUSTRATIONS_COLLECTION_NAME;
    statsCollectionName = ILLUSTRATION_STATISTICS_COLLECTION_NAME;
  } else if (likeType === LIKE_POST_TYPE) {
    collectionName = POSTS_COLLECTION_NAME;
    statsCollectionName = POST_STATISTICS_COLLECTION_NAME;
  }

  const snapshot = await firestore
    .collection(collectionName)
    .doc(documentId)
    .collection(statsCollectionName)
    .doc(BASE_DOCUMENT_NAME)
    .get();

  const data = snapshot.data();
  if (!snapshot.exists || !data) { return; }

  let likes: number = data.likes;
  likes = typeof likes === 'number' ? likes + 1 : 1;

  return await snapshot.ref.update({ 
    likes,
    updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Add a target user to book's [book_liked_by] collection.
 * @param bookId Book's id.
 * @param userId User's id who liked this book.
 * @returns void.
 */
 async function addUserToBookLike(bookId:string, userId: string) {
  return await firestore
    .collection(BOOKS_COLLECTION_NAME)
    .doc(bookId)
    .collection(BOOK_LIKED_BY_COLLECTION_NAME)
    .doc(userId)
    .create({
      book_id: bookId,
      created_at: adminApp.firestore.FieldValue.serverTimestamp(),
      user_id: userId,
    })
}

/**
 * Add a target user to illustration's [illustration_liked_by] collection.
 * @param illustrationId Illustration's id.
 * @param userId User's id who liked this illustration.
 * @returns void.
 */
 async function addUserToIllustrationLike(illustrationId:string, userId: string) {
  return await firestore
    .collection(ILLUSTRATIONS_COLLECTION_NAME)
    .doc(illustrationId)
    .collection(ILLUSTRATION_LIKED_BY_COLLECTION_NAME)
    .doc(userId)
    .create({
      created_at: adminApp.firestore.FieldValue.serverTimestamp(),
      illustration_id: illustrationId,
      user_id: userId,
    })
}

/**
 * Add a target user to post's [post_liked_by] collection.
 * @param postId Post's id.
 * @param userId User's id who liked this post.
 * @returns void.
 */
 async function addUserToPostLike(postId:string, userId: string) {
  return await firestore
    .collection(POSTS_COLLECTION_NAME)
    .doc(postId)
    .collection(POST_LIKED_BY_COLLECTION_NAME)
    .doc(userId)
    .create({
      created_at: adminApp.firestore.FieldValue.serverTimestamp(),
      post_id: postId,
      user_id: userId,
    })
}

/**
 * Return true if an user ewist with the specified email. Return false otherwise.
 * @param email Email to check.
 * @returns Return a boolean. True if the email is already used. False otherwise.
 */
async function isUserExistsByEmail(email: string) {
  const emailSnapshot = await firestore
    .collection(USERS_COLLECTION_NAME)
    .where('email', '==', email)
    .limit(1)
    .get();

  if (!emailSnapshot.empty) {
    return true;
  }

  try {
    const userRecord = await adminApp
      .auth()
      .getUserByEmail(email);

    if (userRecord) {
      return true;
    }

    return false;

  } catch (error) {
    return false;
  }
}

async function isUserExistsByUsername(nameLowerCase: string) {
  const nameSnapshot = await firestore
    .collection(USERS_COLLECTION_NAME)
    .where('name_lower_case', '==', nameLowerCase)
    .limit(1)
    .get();

  if (nameSnapshot.empty) {
    return false;
  }

  return true;
}

/**
 * Remove a target user to book's [book_liked_by] collection.
 * @param bookId Illustration's id or book's id.
 * @param userId User's id who liked this book.
 * @returns void.
 */
 async function removeUserToBookLike(bookId:string, userId: string) {
  await firestore
    .collection(BOOKS_COLLECTION_NAME)
    .doc(bookId)
    .collection(BOOK_LIKED_BY_COLLECTION_NAME)
    .doc(userId)
    .delete()
}

/**
 * Remove a target user to illustration's [illustration_liked_by] collection.
 * @param illustrationId Illustration's id or book's id.
 * @param userId User's id who liked this book.
 * @returns void.
 */
 async function removeUserToIllustrationLike(illustrationId:string, userId: string) {
  await firestore
    .collection(ILLUSTRATIONS_COLLECTION_NAME)
    .doc(illustrationId)
    .collection(ILLUSTRATION_LIKED_BY_COLLECTION_NAME)
    .doc(userId)
    .delete()
}

/**
 * Remove a target user to post's [post_liked_by] collection.
 * @param postId post's id or book's id.
 * @param userId User's id who liked this book.
 * @returns void.
 */
 async function removeUserToPostLike(postId:string, userId: string) {
  await firestore
    .collection(POSTS_COLLECTION_NAME)
    .doc(postId)
    .collection(POST_LIKED_BY_COLLECTION_NAME)
    .doc(userId)
    .delete()
}

/**
 * Return true if an user's field value has changed among public information.
 * (e.g. name, profile picture, urls).
 * @param change Firestore document updated.
 * @returns True if a public value has changed.
 */
function shouldUpdatePublicInfo(change: functions.Change<functions.firestore.QueryDocumentSnapshot>): boolean {
  const beforeData = change.before.data();
  const afterData = change.after.data();

  if (beforeData.name !== afterData.name) {
    return true;
  }

  const beforeProfilePicture = beforeData.profile_picture;
  const afterProfilePicture = afterData.profile_picture;

  for (const [key, value] of Object.entries(beforeProfilePicture)) {
    if (value !== afterProfilePicture[key]) {
      return true;
    }
  }

  const beforeSocialLinks = beforeData.social_links;
  const afterSocialLinks = afterData.social_links;

  for (const [key, value] of Object.entries(beforeSocialLinks)) {
    if (value !== afterSocialLinks[key]) {
      return true;
    }
  }

  return false;
}
  
function validateEmailFormat(email: string) {
  const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

function validateNameFormat(name: string) {
  const re = /[a-zA-Z0-9_]{3,}/;
  const matches = re.exec(name);

  if (!matches) { return false; }
  if (matches.length < 1) { return false; }

  const firstMatch = matches[0];
  return firstMatch === name;
}
