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
  LIKE_BOOK_TYPE, 
  LIKE_ILLUSTRATION_TYPE, 
  NOTIFICATIONS_DOCUMENT_NAME, 
  randomIntFromInterval, 
  STORAGES_DOCUMENT_NAME, 
  USERS_COLLECTION_NAME, 
  USER_PUBLIC_FIELDS_COLLECTION_NAME, 
  USER_STATISTICS_COLLECTION_NAME 
} from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

const LIKE_DOC_PATH = 'users/{user_id}/user_likes/{like_id}'

/**
 * Update list.quote doc to use same id
 * Must be used after app updates (mobile & web).
 */
export const migration = functions
  .region(cloudRegions.eu)
  .https
  .onRequest(async ({}, res) => {
    // migrate users
    // -----
    // const usersSnapshot = await firestore
    //   .collection(USERS_COLLECTION_NAME)
    //   .limit(100)
    //   .get();

    // for await (const userDoc of usersSnapshot.docs) {
    //   const userData = userDoc.data()

      // await userDoc.ref.set({
      //   created_at: userData.createdAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
      //   email: userData.email,
      //   language: userData.lang || 'en',
      //   name: userData.name,
      //   name_lower_case: userData.nameLowerCase,
      //   pricing: userData.pricing,
      //   profile_picture: {
      //     dimension: {
      //       height: userData.profilePicture?.dimensions?.height ?? 0,
      //       width: userData.profilePicture?.dimensions?.width ?? 0,
      //     },
      //     extension: userData.profilePicture?.ext ?? userData.profilePicture?.extension ?? '',
      //     links: {
      //       edited: userData.profilePicture.url.edited,
      //       original: userData.profilePicture.url.original,
      //     },
      //     path: {
    //   //       edited: userData.profilePicture?.path?.edited ?? '',
    //   //       original: userData.profilePicture?.path?.original ?? '',
    //   //     },
    //   //     size: userData.profilePicture?.size ?? 0,
    //   //     updated_at: userData.profilePicture?.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //   //   },
    //   //   rights: {
    //   //     'user:manage_licenses': userData.rights['user:managelicenses'] ?? false,
    //   //     'user:manage_art_movements': userData.rights['user:manageartstyles'] ?? false,
    //   //     'user:manage_sections': userData.rights['user:managesections'] ?? false,
    //   //     'user:manage_users': userData.rights['user:manageusers'] ?? false,
    //   //   },
    //   //   social_links: {
    //   //     artstation: userData.urls.artstation ?? '',
    //   //     devianart: userData.urls.deviantart ?? '',
    //   //     discord: userData.urls.discord ?? '',
    //   //     dribbble: userData.urls.dribbble ?? '',
    //   //     facebook: userData.urls.facebook ?? '',
    //   //     instagram: userData.urls.instagram ?? '',
    //   //     patreon: userData.urls.patreon ?? '',
    //   //     tumblr: userData.urls.tumblr ?? '',
    //   //     tiktok: userData.urls.tiktok ?? '',
    //   //     tipeee: userData.urls.tipeee ?? '',
    //   //     twitch: userData.urls.twitch ?? '',
    //   //     twitter: userData.urls.twitter ?? '',
    //   //     website: userData.urls.website ?? '',
    //   //     wikipedia: userData.urls.wikipedia ?? '',
    //   //     youtube: userData.urls.youtube ?? '',
    //   //   },
    //   //   updated_at: userData.updatedAt ?? adminApp.firestore.Timestamp.now(),
    //   //   user_id: userData.uid,
    //   // })

    // //   // migrate user's licenses
    // //   const userLicensesSnapshot = await adminApp.firestore()
    // //     .collection(USERS_COLLECTION_NAME)
    // //     .doc(userDoc.id)
    // //     .collection(LICENSES_COLLECTION_NAME)
    // //     .get()

    // //   for await (const licenseDoc of userLicensesSnapshot.docs) {
    // //     const data = licenseDoc.data()

    // //     await adminApp.firestore()
    // //     .collection(USERS_COLLECTION_NAME)
    // //     .doc(userDoc.id)
    // //     .collection(USER_LICENSES_COLLECTION_NAME)
    // //     .add({
    // //       abbreviation: data.abbreviation ?? '',
    // //       created_at: data.createdAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    // //       created_by: data.createdBy?.id ?? '',
    // //       description: data.description ?? '',
    // //       id: data.id ?? '',
    // //       license_updated_at: data.licenseUpdatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    // //       links: {
    // //         image: data.urls?.image ?? '',
    // //         legal_code: data.urls?.legalCode ?? '',
    // //         terms: data.urls?.terms ?? '',
    // //         privacy: data.urls?.privacy ?? '',
    // //         wikipedia: data.urls?.wikipedia ?? '',
    // //         website: data.urls?.website ?? '',
    // //       },
    // //       name: data.name ?? '',
    // //       notice: data.notice ?? '',
    // //       terms: {
    // //         attribution: false,
    // //         no_additional_restriction: false,
    // //       },
    // //       type: data.type ?? "user" as EnumLicenseType.user,
    // //       updated_at: data.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    // //       updated_by: data.updatedBy?.id ??'',
    // //       usage: {
    // //         commercial: data.usage.commercial ?? false,
    // //         foss: data.usage.foss ?? false,
    // //         free: data.usage.free ?? false,
    // //         oss: data.usage.oss ?? false,
    // //         personal: data.usage.personal ?? false,
    // //         print: data.usage.print ?? false,
    // //         remix: data.usage.adapt ?? false,
    // //         sell: data.usage.sell ?? false,
    // //         share: data.usage.share ?? false,
    // //         share_a_like: data.usage.shareALike ?? false,
    // //         view: data.usage.view ?? true,
    // //       },
    // //       version: '1.0',
    // //     })
    // //   }

    // //   // migrate user pages
    // //   const pagesSnapshot = await adminApp.firestore()
    // //     .collection(USERS_COLLECTION_NAME)
    // //     .doc(userDoc.id)
    // //     .collection("pages")
    // //     .get()

    // //   for await (const pageDoc of pagesSnapshot.docs) {
    // //     const pageData = pageDoc.data();
    // //     const sectionsData = pageData.sections.map((sectionData: any) => {
    // //       return {
    // //         data_types: sectionData.dataTypes,
    // //         description: sectionData.description,
    // //         id: sectionData.id,
    // //         items: sectionData.items,
    // //         mode: sectionData.mode,
    // //         modes: sectionData.modes,
    // //         name: sectionData.name,
    // //         size: sectionData.size ?? 'large',
    // //         sizes: sectionData.sizes,
    // //       }
    // //     })

    // //     await adminApp.firestore()
    // //       .collection(USERS_COLLECTION_NAME)
    // //       .doc(userDoc.id)
    // //       .collection(USER_PAGES_COLLECTION_NAME)
    // //       .add({
    // //         created_at: pageData.createdAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    // //         is_active: pageData.isActive,
    // //         is_draft: pageData.isDraft,
    // //         name: pageData.name,
    // //         sections: sectionsData,
    // //         type: pageData.type,
    // //         updated_at: pageData.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    // //       })
    // //   }

    // //   // migrate user public fields
    // //   const publicSnap = await adminApp.firestore()
    // //     .collection(USERS_COLLECTION_NAME)
    // //     .doc(userDoc.id)
    // //     .collection('public')
    // //     .doc("basic")
    // //     .get()

    // //   const publicDocData = publicSnap.data();

    // //   if (publicDocData) {
    // //     await adminApp.firestore()
    // //       .collection(USERS_COLLECTION_NAME)
    // //       .doc(userDoc.id)
    // //       .collection(USER_PUBLIC_FIELDS_COLLECTION_NAME)
    // //       .doc(BASE_DOCUMENT_NAME)
    // //       .create({
    // //         location: publicDocData.location,
    // //         name: publicDocData.name,
    // //         profile_picture: {
    // //           dimensions: {
    // //             height: publicDocData.profilePicture?.dimensions?.height ?? 0,
    // //             width: publicDocData.profilePicture?.dimensions?.width ?? 0,
    // //           },
    // //           extension: userData.profilePicture?.ext ?? userData.profilePicture?.extension ?? '',
    // //           links: {
    // //             edited: userData.profilePicture?.url?.edited ?? '',
    // //             original: userData.profilePicture?.url?.original ?? '',
    // //           },
    // //           path: {
    // //             edited: userData.profilePicture?.path?.edited ?? '',
    // //             original: userData.profilePicture?.path?.original ?? '',
    // //           },
    // //           size: userData.profilePicture?.size ?? 0,
    // //           updated_at: userData.profilePicture?.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    // //         },
    // //         social_links: publicDocData.urls,
    // //         summary: publicDocData.summary,
    // //       })
    // //   }

    // //   // migrate user statistics
    // //   const statisticsSnap = await adminApp.firestore()
    // //     .collection(USERS_COLLECTION_NAME)
    // //     .doc(userDoc.id)
    // //     .collection(STATISTICS_COLLECTION_NAME)
    // //     .get();

    // //   for await (const statsDoc of statisticsSnap.docs) {
    // //     const statsDocData = statsDoc.data()

    // //     let payload: Record<string, any> = {
    // //       created: statsDocData.created,
    // //       deleted: statsDocData.deleted,
    // //       name: statsDoc.id,
    // //       owned: statsDocData.owned,
    // //       updated_at: statsDocData.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    // //       user_id: userDoc.id,
    // //     }

    // //     if (statsDoc.id === 'books') {
    // //       payload = { ... payload, ...{ liked: statsDocData.liked }}
    // //     }

    // //     if (statsDoc.id === 'challenges' || statsDoc.id === 'contests') {
    // //       payload = { ...payload, ...{ 
    // //         entered: statsDocData.entered,
    // //         participating: statsDocData.participating,
    // //         won: statsDocData.won,
    // //       }}
    // //     }

    // //     if (statsDoc.id === 'galleries') {
    // //       payload = { ...payload, ...{ 
    // //         entered: statsDocData.entered,
    // //       }}
    // //     }

    // //     if (statsDoc.id === 'illustrations') {
    // //       payload = { ... payload, ...{ 
    // //         liked: statsDocData.liked, 
    // //         updated: statsDocData.updated ?? 0, 
    // //       }}
    // //     }

    // //     if (statsDoc.id === 'notifications') {
    // //       payload = {
    // //         name: statsDoc.id,
    // //         total: 0,
    // //         unread: 0,
    // //         user_id: userDoc.id,
    // //         updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    // //       }
    // //     }

    // //     if (statsDoc.id === 'storages') {
    // //       payload = {
    // //         illustrations: {
    // //           total: 0,
    // //           updated_at: statsDocData.illustrations?.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    // //           used: statsDocData.illustrations.used,
    // //         },
    // //         name: statsDoc.id,
    // //         videos: {
    // //           total: 0,
    // //           updated_at: statsDocData.videos?.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    // //           used: statsDocData.videos.used,
    // //         },
    // //         user_id: userDoc.id,
    // //       }
    // //     }

    // //     await adminApp.firestore()
    // //     .collection(USERS_COLLECTION_NAME)
    // //     .doc(userDoc.id)
    // //     .collection(USER_STATISTICS_COLLECTION_NAME)
    // //     .doc(statsDoc.id)
    // //     .set(payload)
    // //   }
    // }

    // // migrate global licenses
    // const licensesSnapshot = await adminApp.firestore()
    //     .collection(LICENSES_COLLECTION_NAME)
    //     .get()

    // for await (const licenseSnapshot of licensesSnapshot.docs) {
    //   const licenseData = licenseSnapshot.data()

    //   await adminApp.firestore()
    //   .collection(LICENSES_COLLECTION_NAME)
    //   .doc(licenseSnapshot.id)
    //   .set({
    //     abbreviation: licenseData.abbreviation,
    //     created_at: licenseData.createdAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //     created_by: licenseData.createdBy?.id ?? '',
    //     description: licenseData.description ?? '',
    //     license_updated_at: licenseData.licenseUpdatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //     links: {
    //       image: licenseData.urls.image ?? '',
    //       legal_code: licenseData.urls.legalCode ?? '',
    //       terms: licenseData.urls.terms ?? '',
    //       privacy: licenseData.urls.privacy ?? '',
    //       wikipedia: licenseData.urls.wikipedia ?? '',
    //       website: licenseData.urls.website ?? '',
    //     },
    //     name: licenseData.name ?? '',
    //     notice: licenseData.notice ?? '',
    //     terms: {
    //       attribution: false,
    //       no_additional_restriction: false,
    //     },
    //     type: licenseData.type ?? "staff" as EnumLicenseType.user,
    //     updated_at: licenseData.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //     updated_by: licenseData.updatedBy?.id ?? '',
    //     usage: {
    //       commercial: licenseData.usage?.commercial ?? false,
    //       foss: licenseData.usage?.foss ?? false,
    //       free: licenseData.usage?.free ?? false,
    //       oss: licenseData.usage?.oss ?? false,
    //       personal: licenseData.usage?.personal ?? false,
    //       print: licenseData.usage?.print ?? false,
    //       remix: licenseData.usage?.adapt ?? false,
    //       sell: licenseData.usage?.sell ?? false,
    //       share: licenseData.usage?.share ?? false,
    //       share_a_like: licenseData.usage?.shareALike ?? false,
    //       view: licenseData.usage?.view ?? true,
    //     },
    //     version: licenseData.version ?? '1.0',
    //   })
    // }

    // migrate global sections
    // const sectionsSnap = await adminApp.firestore()
    //   .collection("sections")
    //   .get()

    // for await (const sectionDoc of sectionsSnap.docs) {
    //   const sectionData = sectionDoc.data()

    //   await adminApp.firestore()
    //   .collection("sections")
    //   .doc(sectionDoc.id)
    //   .set({
    //     created_at: sectionData.createdAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //     data_types: sectionData.dataTypes,
    //     description: sectionData.description,
    //     // items: sectionData.items,
    //     // mode: sectionData.mode,
    //     modes: sectionData.modes,
    //     name: sectionData.name,
    //     // size: sectionData.size ?? 'large',
    //     sizes: sectionData.sizes,
    //     updated_at: sectionData.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //   })
    // }

    // // migrate gloabl stats
    // const bookStatsSnapshot = await adminApp.firestore()
    //   .collection(STATISTICS_COLLECTION_NAME)
    //   .doc(BOOKS_COLLECTION_NAME)
    //   .get()

    // const bookStatsData = bookStatsSnapshot.data()
    // if (bookStatsData) {
    //   await bookStatsSnapshot.ref.set({
    //     created: bookStatsData.created ?? 0,
    //     current: bookStatsData.total ?? 0,
    //     deleted: bookStatsData.deleted ?? 0,
    //     shared: bookStatsData.shared ?? 0,
    //     updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    //   })
    // }

    // const illusStatsSnapshot = await adminApp.firestore()
    //   .collection(STATISTICS_COLLECTION_NAME)
    //   .doc(ILLUSTRATIONS_COLLECTION_NAME)
    //   .get()

    // const illusStatsData = illusStatsSnapshot.data()
    // if (illusStatsData) {
    //   await illusStatsSnapshot.ref.set({
    //     created: illusStatsData.created ?? 0,
    //     current: illusStatsData.total ?? 0,
    //     deleted: illusStatsData.deleted ?? 0,
    //     downloaded: illusStatsData.downloaded ?? 0,
    //     remixed: 0,
    //     shared: illusStatsData.shared ?? 0,
    //     updated: illusStatsData.updated ?? 0,
    //     updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    //   })
    // }

    // await adminApp.firestore()
    //   .collection(STATISTICS_COLLECTION_NAME)
    //   .doc(LICENSES_COLLECTION_NAME)
    //   .create({
    //     created: 0,
    //     current: 0,
    //     deleted: 0,
    //     updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    //   })

    // await adminApp.firestore()
    //   .collection(STATISTICS_COLLECTION_NAME)
    //   .doc("pages")
    //   .create({
    //     created: 0,
    //     current: 0,
    //     deleted: 0,
    //     shared: 0,
    //     updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    //   })
      

    // await adminApp.firestore()
    //   .collection(STATISTICS_COLLECTION_NAME)
    //   .doc("sections")
    //   .create({
    //     created: 0,
    //     current: 0,
    //     deleted: 0,
    //     updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    //   })

    // await adminApp.firestore()
    //   .collection(STATISTICS_COLLECTION_NAME)
    //   .doc(USERS_COLLECTION_NAME)
    //   .create({
    //     created: 0,
    //     current: 0,
    //     deleted: 0,
    //     updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    //   })
    
    // // migrate gloabl styles -> art_movements
    // const artStyleSnap = await adminApp.firestore()
    //   .collection("styles")
    //   .get()

    //   for await (const artStyleDoc of artStyleSnap.docs) {
    //     const data = artStyleDoc.data()
    //     await adminApp.firestore()
    //       .collection("art_movements")
    //       .doc(artStyleDoc.id)
    //       .create({
    //         created_at: data.createdAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //         description: data.description ?? '',
    //         links: data.urls,
    //         name: data.name ?? '',
    //         udpated_at: data.udpatedAt?? adminApp.firestore.FieldValue.serverTimestamp(),
    //       })
    //   }

    // migrate gloabl books
    // const booksSnapshot = await adminApp.firestore()
    //   .collection(BOOKS_COLLECTION_NAME)
    //   .get()

    // for await (const bookSnapshot of booksSnapshot.docs) {
    //   const bookData = bookSnapshot.data()

    //   await bookSnapshot.ref
    //     .set({
    //       count: bookData.count,
    //       cover: {
    //         mode: 'last_illustration_added',
    //         link: bookData.cover?.auto?.url ?? '',
    //         updated_at: bookData.cover?.auto?.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //       },
    //       created_at: bookData.createdAt,
    //       description: bookData.description,
    //       illustrations: bookData.illustrations.map((illus: any) => {
    //         return {
    //           created_at: illus.createdAt ?? adminApp.firestore.Timestamp.now(),
    //           id: illus.id,
    //           scale_factor: {
    //             height: 1,
    //             width: 1,
    //           },
    //         }
    //       }),
    //       layout: 'grid',
    //       layout_orientation: 'vertical',
    //       links: {
    //         share: {
    //           read: '',
    //           write: '',
    //         }
    //       },
    //       name: bookData.name || '',
    //       updated_at: bookData.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //       user_id: bookData.user.id,
    //       visibility: bookData.visibility ?? 'public',
    //     })

    //   await bookSnapshot.ref.collection(BOOK_STATISTICS_COLLECTION_NAME)
    //     .doc(BASE_DOCUMENT_NAME)
    //     .create({
    //       book_id: bookSnapshot.id,
    //       downloads: 0,
    //       likes: 0,
    //       shares: 0,
    //       user_id: bookData.user.id,
    //       views: 0,
    //     })
    // }

    // migrate gloabl illustrations
    // const illustrationsSnap = await adminApp.firestore()
    //   .collection(ILLUSTRATIONS_COLLECTION_NAME)
    //   .get()

    // for await (const illustrationSnapshot of illustrationsSnap.docs) {
    //   // const illustrationData = illustrationSnapshot.data()
    //   await illustrationSnapshot.ref.update({
    //     'links.share': {
    //       read: '',
    //       write: '',
    //     },
    //   })

    //   // await illustrationSnapshot.ref
    //   //   .set({
    //   //     art_movements: illustrationData.styles ?? {},
    //   //     created_at: illustrationData.createdAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //   //     description: illustrationData.description ?? '',
    //   //     dimensions: illustrationData.dimensions,
    //   //     extension: illustrationData.extension ?? illustrationData.ext ?? '',
    //   //     license: {
    //   //       id: illustrationData.license?.id ?? '',
    //   //       type: illustrationData.license?.from ?? illustrationData.license?.type ?? '',
    //   //     },
    //   //     links: {
    //   //       original: illustrationData.urls.original ?? '',
    //   //       share: illustrationData.urls.share ?? '',
    //   //       storage: illustrationData.urls.storage ?? '',
    //   //       thumbnails: illustrationData.urls.thumbnails,
    //   //     },
    //   //     lore: illustrationData.story ?? '',
    //   //     name: illustrationData.name,
    //   //     size: illustrationData.size,
    //   //     topics: illustrationData.topics ?? {},
    //   //     updated_at: illustrationData.updatedAt ?? adminApp.firestore.FieldValue.serverTimestamp(),
    //   //     user_id: illustrationData.user.id,
    //   //     version: illustrationData.version ?? 1,
    //   //     visibility: illustrationData.visibility ?? 'public',
    //   //   })

    //     // await illustrationSnapshot.ref
    //     // .collection(ILLUSTRATION_STATISTICS_COLLECTION_NAME)
    //     // .doc(BASE_DOCUMENT_NAME)
    //     // .create({
    //     //   downloads: 0,
    //     //   illustration_id: illustrationSnapshot.id,
    //     //   likes: 0,
    //     //   shares: 0,
    //     //   views: 0,
    //     //   updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    //     //   user_id: illustrationData.user.id,
    //     // })
    // }

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
      .collection(USERS_COLLECTION_NAME)
      .where('name_lower_case', '==', name.toLowerCase())
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
          'user:manage_sections': false,
          'user:manage_users': false,
        },
        social_links: {
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

    if (type !== LIKE_ILLUSTRATION_TYPE && type !== LIKE_BOOK_TYPE) {
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

    return await likeSnapshot.ref.update({
      created_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });
  })

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

    if (type !== LIKE_ILLUSTRATION_TYPE && type !== LIKE_BOOK_TYPE) {
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

    const user_id_path_param: string = context.params.user_id
    await decrementUserLikeCount(user_id_path_param, type)
    await decrementDocumentLikeCount(likeSnapshot.id, type)

    if (type === LIKE_BOOK_TYPE) {
      await removeUserToBookLike(likeSnapshot.id, user_id_path_param)
    }

    if (type === LIKE_ILLUSTRATION_TYPE) {
      await removeUserToIllustrationLike(likeSnapshot.id, user_id_path_param)
    }

    return true
  })

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
        location: data.location,
        name: data.name,
        profile_picture: data.profile_picture,
        lore: data.lore,
        social_links: data.social_links,
      });
  })

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
        location: afterData.location,
        name: afterData.name,
        profile_picture: afterData.profile_picture,
        lore: afterData.lore,
        social_links: afterData.social_links,
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

    const lore: string = data.lore;
    const location: string = data.location;

    if (typeof lore !== 'string' || typeof location !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `You provided a wrong argument type for [lore] or [location]. ` +
        `Both arguments should be string, but their value are: ` +
        `lore (${typeof lore}): ${lore}, location (${typeof location}): ${location}.`,
      );
    }

    return await adminApp.firestore()
      .collection(USERS_COLLECTION_NAME)
      .doc(userAuth.uid)
      .update({
        location,
        lore,
      });
  })

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

    const socialLinks = data.socialLinks;

    if (typeof socialLinks !== 'object') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `You provided a wrong argument type for [socialLinks]. ` +
        `The function should be called with a [socialLinks] argument wich is an object or map of strings.`,
      );
    }

    for (const [key, value] of Object.entries(socialLinks)) {
      if (typeof key !== 'string' || typeof value !== 'string') {
        throw new functions.https.HttpsError(
          'invalid-argument',
          `The [socialLinks] argument is not a map of (string, string) for (key, value). ` +
          `${key} has a type of ${typeof key}. ${value} has a type of ${typeof value}`,
        );
      }
    }

    return await adminApp.firestore()
      .collection(USERS_COLLECTION_NAME)
      .doc(userAuth.uid)
      .update({
        social_links: socialLinks
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

  if (typeof data.username !== 'string' ||
    typeof data.email !== 'string' ||
    typeof data.password !== 'string') {
    return false;
  }

  return true;
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
  const docName = likeType === 'books' 
  ? BOOKS_COLLECTION_NAME
  : ILLUSTRATIONS_COLLECTION_NAME;

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
  const collectionName = likeType === 'book' 
    ? BOOKS_COLLECTION_NAME
    : ILLUSTRATIONS_COLLECTION_NAME;

  const statsCollectionName = likeType === 'book'
    ? BOOK_STATISTICS_COLLECTION_NAME
    : ILLUSTRATION_STATISTICS_COLLECTION_NAME;

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
  const docStatsName = likeType === 'books' 
  ? BOOKS_COLLECTION_NAME
  : ILLUSTRATIONS_COLLECTION_NAME;

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
  const collectionName = likeType === 'book' 
    ? BOOKS_COLLECTION_NAME
    : ILLUSTRATIONS_COLLECTION_NAME;

  const statsCollectionName = likeType === 'book'
    ? BOOK_STATISTICS_COLLECTION_NAME
    : ILLUSTRATION_STATISTICS_COLLECTION_NAME;

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
 * @param bookId Illustration's id or book's id.
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
 * @param illustrationId Illustration's id or book's id.
 * @param userId User's id who liked this book.
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
