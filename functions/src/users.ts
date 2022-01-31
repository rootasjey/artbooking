import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';
import { checkUserIsSignedIn, cloudRegions, randomIntFromInterval } from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

/**
 * Update list.quote doc to use same id
 * Must be used after app updates (mobile & web).
 */
export const updateUserLists = functions
  .region(cloudRegions.eu)
  .https
  .onRequest(async ({}, res) => {
    // The app has very few users right now (less than 20).
    const userSnapshot = firestore
      .collection('users')
      .limit(100)
      .get();

    // For each user
    (await userSnapshot).docs.forEach(async (userDoc) => {
      // Get all lists
      const listsSnapshot = await firestore
        .collection(`users/${userDoc.id}/lists`)
        .get();

      // For each list
      for await (const listDoc of listsSnapshot.docs) {
        // Get all quotes
        const quotesSnap = await firestore
          .collection(`users/${userDoc.id}/lists/${listDoc.id}/quotes`)
          .get();

        // For each quote
        for await (const quoteDoc of quotesSnap.docs) {
          const quoteData = quoteDoc.data();

          // Check if the quote has the `quoteId` prop.
          // If this prop. exists, it uses the old data model 
          // so it must be updated.
          if (quoteData.quoteId) {
            // Add a new quote doc with the right id and the same data.
            await firestore
              .collection(`users/${userDoc.id}/lists/${listDoc.id}/quotes`)
              .doc(quoteDoc.id)
              .set(quoteDoc.data());

            // Delete the old quote doc.
            await quoteDoc.ref.delete();
          }
        }
      }
    });

    res.status(200).send('done');
  });

export const checkEmailAvailability = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data) => {
    const email: string = data.email;

    if (typeof email !== 'string' || email.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with one (string)
         argument [email] which is the email to check.`,
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
    const name: string = data.name;

    if (typeof name !== 'string' || name.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with one (string)
         argument "name" which is the name to check.`,
      );
    }

    if (!validateNameFormat(name)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [name]
         with at least 3 alpha-numeric characters (underscore is allowed) (A-Z, 0-9, _).`,
      );
    }

    const nameSnap = await firestore
      .collection('users')
      .where('nameLowerCase', '==', name.toLowerCase())
      .limit(1)
      .get();

    return {
      name: name,
      isAvailable: nameSnap.empty,
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

    const userRecord = await adminApp
      .auth()
      .createUser({
        displayName: username,
        password: password,
        email: email,
        emailVerified: false,
      });

    await adminApp.firestore()
      .collection('users')
      .doc(userRecord.uid)
      .set({
        createdAt: adminApp.firestore.Timestamp.now(),
        email: email,
        lang: 'en',
        name: username,
        nameLowerCase: username.toLowerCase(),
        pricing: 'free',
        profilePicture: {
          ext: '',
          path: {
            edited: '',
            original: '',
          },
          size: 0,
          updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
          url: {
            edited: '',
            original: getRandomProfilePictureLink(),
          },
        },
        rights: {
          'user:managedata': false,
        },
        settings: {
          notifications: {
            email: {
              tempQuotes: true,
              quotidians: false,
            },
            push: {
              quotidians: true,
              tempQuotes: true,
            }
          },
        },
        stats: {
          books: {
            created: 0,
            deleted: 0,
            fav: 0,
            owned: 0,
          },
          challenges: {
            created: 0,
            deleted: 0,
            entered: 0,
            owned: 0,
            participating: 0,
            won: 0,
          },
          contests: {
            created: 0,
            deleted: 0,
            entered: 0,
            owned: 0,
            participating: 0,
            won: 0,
          },
          galleries: {
            created: 0,
            deleted: 0,
            entered: 0,
            opened: 0,
            owned: 0,
          },
          illustrations: {
            created: 0,
            deleted: 0,
            fav: 0,
            owned: 0,
            updated: 0,
          },
          notifications: {
            total: 0,
            unread: 0,
          },
          storage: { // all number values are in bytes
            illustrations: {
              total: 0,
              used: 0,
            },
            videos: {
              total: 0,
              used: 0,
            },
          },
        },
        updatedAt: adminApp.firestore.Timestamp.now(),
        urls: {
          artstation: '',
          devianart: '',
          discord: '',
          dribbble: '',
          facebook: '',
          instagram: '',
          patreon: '',
          pp: '',
          tumblr: '',
          tiktok: '',
          tipeee: '',
          twitch: '',
          twitter: '',
          website: '',
          wikipedia: '',
          youtube: '',
        },
        uid: userRecord.uid,
      });

    return {
      user: {
        id: userRecord.uid,
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
    const { idToken } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    const userSnap = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userSnap.data();

    if (!userSnap.exists || !userData) {
      throw new functions.https.HttpsError(
        'not-found',
        `This user document doesn't exist. It may have been deleted.`,
      );
    }

    await adminApp
      .auth()
      .deleteUser(userAuth.uid);

    await firebaseTools.firestore
      .delete(userSnap.ref.path, {
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
 * Return user's data.
 */
export const fetchUser = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (data, context) => {
    const userId: string = data.userId;

    if (typeof userId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `'fetchUser' must be called with one (1) argument [userId]
        representing the user's id to fetch.`,
      );
    }

    const userSnap = await firestore
      .collection('users')
      .doc(userId)
      .get();

    const userData = userSnap.data();

    if (!userSnap.exists || !userData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The specified user does not exist. 
        It may have been deleted.`,
      );
    }


    const userDataWithId = {
      ...userData,
      ...{ id: userSnap.id },
    };

    return formatUserData(userDataWithId);
  });

/**
 * Create user's public information from private fields.
 */
export const onCreatePublicInfo = functions
  .region(cloudRegions.eu)
  .firestore
  .document('users/{userId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const userId: string = context.params.userId;
    
    if (typeof userId !== 'string') {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `There was an issue with the user's id. Its value: [${userId}].`,
      );
    }

    return await adminApp.firestore()
      .collection('users')
      .doc(userId)
      .collection('public')
      .doc('basic')
      .create({
        location: data.location,
        name: data.name,
        profilePicture: data.profilePicture,
        summary: data.summary,
        urls: data.urls,
      });
  })

/**
 * Keep public user's information in-sync with privated fields.
 * Fired after document change for an user.
 */
export const onUpdatePublicInfo = functions
  .region(cloudRegions.eu)
  .firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const shouldUpdate = shouldUpdatePublicInfo(change);
    if (!shouldUpdate) {
      return false;
    }

    const afterData = change.after.data();
    const userId: string = context.params.userId;
    
    if (typeof userId !== 'string') {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `There was an issue with the user's id. Its value: [${userId}].`,
      );
    }

    return await adminApp.firestore()
      .collection('users')
      .doc(userId)
      .collection('public')
      .doc('basic')
      .update({
        location: afterData.location,
        name: afterData.name,
        profilePicture: afterData.profilePicture,
        summary: afterData.summary,
        urls: afterData.urls,
      });
  })

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
    const { idToken, newEmail } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user (1).`,
      );
    }

    await checkUserIsSignedIn(context, idToken);
    const isFormatOk = validateEmailFormat(newEmail);

    if (!newEmail || !isFormatOk) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [newEmail] argument. 
        The value you specified is not in a correct email format.`,
      );
    }

    const isEmailTaken = await isUserExistsByEmail(newEmail);

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
        email: newEmail,
        emailVerified: false,
      });

    await firestore
      .collection('users')
      .doc(userAuth.uid)
      .update({
        email: newEmail,
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

    const { newUsername } = data;
    const isFormatOk = validateNameFormat(newUsername);

    if (!newUsername || !isFormatOk) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [newUsername].
         The value you specified is not in a correct format.`,
      );
    }

    const isUsernameTaken = await isUserExistsByUsername(newUsername.toLowerCase());

    if (isUsernameTaken) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The name specified is not available.
         Please try with a new one.`,
      );
    }

    await adminApp
      .auth()
      .updateUser(userAuth.uid, {
        displayName: newUsername,
      });

    await firestore
      .collection('users')
      .doc(userAuth.uid)
      .update({
        name: newUsername,
        nameLowerCase: newUsername.toLowerCase(),
      });

    return {
      success: true,
      user: { id: userAuth.uid },
    };
  });

/**
 * Update user's summary, location.
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

    const summary: string = data.summary;
    const location: string = data.location;

    if (typeof summary !== 'string' || typeof location !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `You provided a wrong argument type for [summary] or [location]. ` +
        `Both arguments should be string, but their value are: ` +
        `summary (${typeof summary}): ${summary}, location (${typeof location}): ${location}.`,
      );
    }

    return await adminApp.firestore()
      .collection('users')
      .doc(userAuth.uid)
      .update({
        location,
        summary,
      });
  })

/**
 * Update user's urls (mostly external social links).
 */
export const updateUrls = functions
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

    const urls = data.urls;

    if (typeof urls !== 'object') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `You provided a wrong argument type for [urls]. ` +
        `The function should be called with a [urls] argument wich is an object or map of urls.`,
      );
    }

    for (const [key, value] of Object.entries(urls)) {
      if (typeof key !== 'string' || typeof value !== 'string') {
        throw new functions.https.HttpsError(
          'invalid-argument',
          `The [urls] argument is not a map of (string, string) for (key, value). ` +
          `${key} has a type of ${typeof key}. ${value} has a type of ${typeof value}`,
        );
      }
    }

    return await adminApp.firestore()
      .collection('users')
      .doc(userAuth.uid)
      .update({
        urls
      });
  })

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

  if (typeof data['username'] !== 'string' ||
    typeof data['email'] !== 'string' ||
    typeof data['password'] !== 'string') {
    return false;
  }

  return true;
}

/**
 * Take a raw Firestore data object and return formated data.
 * @param userData User's data.
 * @returns Return a formated data to consume.
 */
function formatUserData(userData: any) {
  return {
    createdAt: userData.createdAt,
    email: userData.email,
    id: userData.id,
    job: userData.job ?? '',
    lang: userData.lang ?? '',
    location: userData.location,
    name: userData.name,
    pp: userData.pp,
    pricing: userData.pricing,
    role: userData.role,
    stats: userData.stats,
    summary: userData.summary,
    updatedAt: userData.updatedAt,
    urls: userData.urls,
  };
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

async function isUserExistsByEmail(email: string) {
  const emailSnapshot = await firestore
    .collection('users')
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
    .collection('users')
    .where('nameLowerCase', '==', nameLowerCase)
    .limit(1)
    .get();

  if (nameSnapshot.empty) {
    return false;
  }

  return true;
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

  const beforeProfilePicture = beforeData.profilePicture;
  const afterProfilePicture = afterData.profilePicture;

  for (const [key, value] of Object.entries(beforeProfilePicture)) {
    if (value !== afterProfilePicture[key]) {
      return true;
    }
  }

  const beforeUrls = beforeData.urls;
  const afterUrls = afterData.urls;

  for (const [key, value] of Object.entries(beforeUrls)) {
    if (value !== afterUrls[key]) {
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
