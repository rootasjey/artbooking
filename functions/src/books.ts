import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { 
  BASE_DOCUMENT_NAME,
  BOOKS_COLLECTION_NAME, 
  BOOK_STATISTICS_COLLECTION_NAME, 
  checkOrGetDefaultVisibility, 
  cloudRegions, 
  ILLUSTRATIONS_COLLECTION_NAME
} from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

/**
 * Add illustrations to an existing book.
 */
export const addIllustrations = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: UpdateBookIllustrationsParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    const { book_id, illustration_ids } = params;

    if (typeof book_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [bookId] parameter
         which is the book's id to update.`,
      );
    }

    if (!Array.isArray(illustration_ids) || illustration_ids.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [illustrationIds] parameter
         which is an array of illustrations' ids to add. And not be empty.`,
      );
    }

    const newIllustrations = await createBookIllustrations(illustration_ids);

    const bookSnapshot = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .doc(book_id)
      .get();

    const bookData = bookSnapshot.data();
    if (!bookSnapshot.exists || !bookData) {
      throw new functions.https.HttpsError(
        'not-found', 
        `The book ${book_id} to update doesn't exist anymore.`,
      );
    }

    if (bookData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to update this book ${book_id}.`,
      )
    }

    /** Indicates if an operation had issue without resulting in an error. */
    let warning = '';

    const bookIllustrations: BookIllustration[] = bookData.illustrations;
    let newBookIllustrations = bookIllustrations.concat(newIllustrations);
    const bookThumbnailLink = await getBookThumbnailLink(newBookIllustrations);
    
    if (newBookIllustrations.length > 100) {
      newBookIllustrations = newBookIllustrations.slice(0, 100);
      warning = `max_illustration_100`;
    }

    await bookSnapshot.ref.update({
      count: newBookIllustrations.length,
      cover: { 
        link: bookThumbnailLink, 
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      },
      illustrations: newBookIllustrations,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    const items = illustration_ids.map((id) => { 
      return { 
        illustration: { id }, 
        success: true, 
      };
    });

    return {
      items,
      successCount: illustration_ids.length,
      hasErrors: false,
      warning,
    };
  });

/**
 * Create a book document in Firestore.
 */
export const createOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: CreateBookParams, context) => {
    const userAuth = context.auth;
    const { name, illustration_ids, visibility } = params;
    let { description } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof name !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [name] parameter 
        which is the illustration's name.`,
      );
    }

    description = typeof description === 'string' ? description : '';

    const bookIllustrations = await createBookIllustrations(illustration_ids);
    const bookThumbnailLink: string = await getBookThumbnailLink(bookIllustrations);

    const addedBookDoc = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .add({
        count: 0,
        cover: {
          mode: 'last_illustration_added',
          link: bookThumbnailLink,
          updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
        },
        created_at: adminApp.firestore.FieldValue.serverTimestamp(),
        description,
        illustrations: bookIllustrations,
        layout: 'grid',
        layout_orientation: 'vertical',
        name,
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
        user_id: userAuth.uid,
        visibility: checkOrGetDefaultVisibility(visibility),
      });

    await createStatsCollection(addedBookDoc.id)

    return {
      book: {
        id: addedBookDoc.id,
      },
      success: true,
    };
  });

/**
 * Delete a book document from Firestore.
 */
export const deleteOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: DeleteBookParams, context) => {
    const userAuth = context.auth;
    const { book_id } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof book_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [book_id] argument
         which is the illustration's id to delete.`,
      );
    }

    const bookSnap = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .doc(book_id)
      .get();

    const bookData = bookSnap.data();
    if (!bookSnap.exists || !bookData) {
      throw new functions.https.HttpsError(
        'not-found',
        `This book doesn't exist.`,
      )
    }

    if (bookData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to delete this book.`,
      )
    }

    await firebaseTools.firestore
      .delete(bookSnap.ref.path, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
      });

    return {
      book: { id: book_id },
      success: true,
    };
  });

/**
 * Delete multiple books documents from Firestore.
 */
export const deleteMany = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: DeleteBooksParams, context) => {
    const userAuth = context.auth;
    const { book_ids } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (!Array.isArray(book_ids) || book_ids.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [book_ids] argument ` +
        `which is an array of illustrations' ids to delete.`,
      );
    }

    /** How many operations succeeded. */
    let successCount = 0;
    const itemsProcessed = [];

    for await (const book_id of book_ids) {
      try { // Some deletion may fail.
        const bookSnapshot = await firestore
          .collection(BOOKS_COLLECTION_NAME)
          .doc(book_id)
          .get();

        const bookData = bookSnapshot.data();
        let errorMessage = `This book doesn't exist anymore.`;

        if (!bookSnapshot.exists || !bookData) {
          itemsProcessed.push({
            book: { id: book_id },
            success: false,
            errorMessage,
          });

          throw new functions.https.HttpsError(
            'not-found',
            errorMessage,
          );
        }

        if (bookData.user_id !== userAuth.uid) {
          errorMessage = `You don't have the permission to delete the book [${book_id}].`;

          itemsProcessed.push({
            book: { id: book_id },
            success: false,
            errorMessage,
          });

          throw new functions.https.HttpsError(
            'permission-denied',
            errorMessage,
          );
        }

        await firebaseTools.firestore
          .delete(bookSnapshot.ref.path, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
          });

        itemsProcessed.push({
          book: { id: book_id },
          success: true,
        });

        successCount++;

      } catch (error) {
        console.error(`Error while deleting book [${book_id}]`);
        console.error(error);
      }
    }

    return {
      items: itemsProcessed,
      successCount,
      hasErrors: successCount === book_ids.length,
    };
  });

/**
 * For a given book, check a list of illustrations from their id.
 * Check that each illustration currently exists.
 * If a illustration does NOT exist anymore, remove it from this book.
 */
export const removeDeletedIllustrations = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: UpdateBookIllustrationsParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const { book_id, illustration_ids } = params;

    if (typeof book_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [book_id] parameter
        which is the book's id to update.`,
      );
    }

    if (!Array.isArray(illustration_ids) || illustration_ids.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [illustration_ids] parameter
         which is an array of illustrations' ids to add. And not be empty.`,
      );
    }

    /** Indicates if an operation had issue without resulting in an error. */
    let warning = '';
    const deletedIllustrations: Array<String> = [];

    for await (const illustration_id of illustration_ids) {
      const illustrationSnapshot = await firestore
        .collection(ILLUSTRATIONS_COLLECTION_NAME)
        .doc(illustration_id)
        .get();

      if (!illustrationSnapshot.exists) {
        deletedIllustrations.push(illustration_id);
      }
    }

    if (deletedIllustrations.length === 0) {      
      return {
        items: deletedIllustrations,
        successCount: 0,
        hasErrors: false,
        warning,
      };
    }

    const bookSnapshot = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .doc(book_id)
      .get();

    const bookData = bookSnapshot.data();
    if (!bookSnapshot.exists || !bookData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The book ${book_id} to update doesn't exist anymore.`,
      );
    }

    if (bookData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to update this book ${book_id}.`,
      );
    }

    const bookIllustrations: BookIllustration[] = bookData.illustrations;
    let newBookIllustrations = bookIllustrations.filter(
      (bookIllustration) => !deletedIllustrations.includes(bookIllustration.id),
    );

    const bookThumbnailLink = await getBookThumbnailLink(newBookIllustrations);

    if (newBookIllustrations.length > 100) {
      newBookIllustrations = newBookIllustrations.slice(0, 100);
      warning = `max_illustration_100`;
    }

    await bookSnapshot.ref.update({
      count: newBookIllustrations.length,
      cover: { 
        link: bookThumbnailLink, 
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      },
      illustrations: newBookIllustrations,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    const items = deletedIllustrations.map((id) => {
      return {
        illustration: { id },
        success: true,
      };
    });

    return {
      items,
      successCount: deletedIllustrations,
      hasErrors: false,
      warning,
    };
  });

/**
 * Delete illustrations from an existing book.
 */
export const removeIllustrations = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: UpdateBookIllustrationsParams, context) => {
    const userAuth = context.auth;
    const { book_id, illustration_ids } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof book_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [book_id] (string) parameter ` +
         `which is the book to update.`,
      );
    }

    if (!Array.isArray(illustration_ids) || illustration_ids.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [illustration_ids] parameter ` +
         `which is the array of (string) illustrations to remove from the book.`,
      );
    }

    const bookSnapshot = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .doc(book_id)
      .get();
      
    const bookData = bookSnapshot.data();
    if (!bookSnapshot.exists || !bookData){
      throw new functions.https.HttpsError(
        'not-found', 
        `The book ${book_id} to update doesn't exist anymore.`,
      );
    }
    
    if (bookData.user_id !== userAuth.uid){
      throw new functions.https.HttpsError(
        'permission-denied', 
        `You don't have the permission to update this book ${bookData.user_id}.`,
      );
    }

    const bookIllustrations: BookIllustration[] = bookData.illustrations;
    const newBookIllustrations = bookIllustrations
      .filter(illustration => !illustration_ids.includes(illustration.id));

    const bookThumbnailLink = await getBookThumbnailLink(newBookIllustrations);

    await bookSnapshot.ref.update({
      count: newBookIllustrations.length,
      cover: { 
        link: bookThumbnailLink, 
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      },
      illustrations: newBookIllustrations,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    const items = illustration_ids.map((id) => {
      return {
        illustration: { id },
        success: true,
      };
    });

    return {
      items,
      successCount: illustration_ids.length,
      hasErrors: false,
    };
  });

/**
 * Update book's name and description.
 */
export const renameOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: UpdateBookPropertiesParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    checkRenameBookPropsParam(params);

    const {
      description,
      book_id,
      name,
    } = params;

    const bookSnap = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .doc(book_id)
      .get();

    const bookData = bookSnap.data();
    if (!bookSnap.exists || !bookData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The book [${book_id}] doesn't exist anymore.`,
      )
    }

    if (bookData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to update this book ${bookData.user_id}.`,
      )
    }

    await bookSnap.ref.update({
      description,
      name,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    return {
      book: { id: book_id },
      success: true,
    };
  });

/**
 * Set a new cover to an existing book.
 * The cover is from an existing illustration in the current book.
 */
export const setCover = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: any, context) => {
    const userAuth = context.auth;
    const { book_id, illustration_id } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof book_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [bookId] (string) parameter
         which is the book to update.`,
      );
    }

    if (typeof illustration_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [illustrationId] (string) parameter
         which is the book to update.`,
      );
    }

    const bookSnapshot = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .doc(book_id)
      .get();

    const bookData = bookSnapshot.data()
    if (!bookSnapshot.exists || !bookData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The book [${book_id}] doesn't exist.`,
      )
    }

    if (bookData.user_id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have permission to update this book ${bookSnapshot.id}.`,
      )
    }

    const illustrationSnapshot = await firestore
      .collection(ILLUSTRATIONS_COLLECTION_NAME)
      .doc(illustration_id)
      .get();

    const illustrationData = illustrationSnapshot.data();
    if (!illustrationSnapshot.exists || !illustrationData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The illustration [${illustration_id}] doesn't exist.`,
      )
    }

    const thumbnails = illustrationData.urls.thumbnails;

    await bookSnapshot.ref.update({
      cover: {
        id: illustrationSnapshot.id,
        url: thumbnails.t720 || thumbnails.t480 || thumbnails.t360,
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      },
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    return {
      book: { id: book_id },
      success: true,
    };
  });

// ----------------
// Helper functions
// ----------------

/**
 * Check book's rename properties types and values.
 * @param params - Updated book's properties.
 */
function checkRenameBookPropsParam(params: RenameBookPropertiesParams) {
  if (!params) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must be called with a valid [id] & [illustrationsIds] parameters 
      which are respectively the book's id and an illustrations' ids array.`,
    );
  }

  const {
    description,
    name,
  } = params;

  if (typeof description !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [description] parameter
       which is the updated Book's description.`,
    )
  }

  if (typeof name !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [name] parameter
       which is the updated Book's name.`,
    )
  }
}

/**
 * Create an array of simple illustrations objects.
 * @param ids - Illustrations' ids to create.
 */
async function createBookIllustrations(ids: string[]) {
  if (!ids || !Array.isArray(ids) || ids.length === 0) {
    return [];
  }

  const bookIllustrations: BookIllustration[] = [];

  for (const id of ids) {
    bookIllustrations.push({
      created_at: adminApp.firestore.Timestamp.now(),
      id,
      scale_factor: {
        height: 1,
        width: 1,
      },
    });
  }

  return bookIllustrations;
}

/**
 * Create book's stats sub-collection
 * @param bookId book's id.
 * @returns void.
 */
 async function createStatsCollection(bookId: string) {
  const snapshot = await firestore
    .collection(BOOKS_COLLECTION_NAME)
    .doc(bookId)
    .get();

  if (!snapshot.exists) {
    return;
  }

  await snapshot.ref
    .collection(BOOK_STATISTICS_COLLECTION_NAME)
    .doc(BASE_DOCUMENT_NAME)
    .create({
      book_id: bookId,
      downloads: 0,
      likes: 0,
      shares: 0,
      views: 0,
    });
}

/**
 * Return the last added illustration thumbnail in the array.
 * @param bookIllustrations Array of illustrations.
 * @returns Thumbnail link of the last added illustration in this book.
 */
async function getBookThumbnailLink(
  bookIllustrations: BookIllustration[],
): Promise<string> {
  if (bookIllustrations.length === 0) {
    return '';
  }

  const lastAddedIllustration = bookIllustrations[bookIllustrations.length - 1];
  if (!lastAddedIllustration.id) {
    return '';
  }

  const illustrationSnapshot = await firestore
    .collection(ILLUSTRATIONS_COLLECTION_NAME)
    .doc(lastAddedIllustration.id)
    .get();

  const illustrationData = illustrationSnapshot.data();
  if (!illustrationSnapshot.exists || !illustrationData) {
    return '';
  }

  const thumbnails = illustrationData.links.thumbnails;
  return thumbnails.t480 || thumbnails.t360 || thumbnails.t720;
}

