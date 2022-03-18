import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { 
  BASE_DOCUMENT_NAME,
  BookCoverMode,
  BOOKS_COLLECTION_NAME,
  BOOK_STATISTICS_COLLECTION_NAME, 
  checkOrGetDefaultVisibility, 
  checkVisibilityValue, 
  cloudRegions, 
  ILLUSTRATIONS_COLLECTION_NAME,
  USERS_COLLECTION_NAME,
  USER_STATISTICS_COLLECTION_NAME
} from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

/**
 * Add illustrations to a list of existing books.
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
        `The function must be called with a valid [illustration_ids] parameter ` +
         `which is an array of illustrations' ids to add. It must not be empty.`,
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
    
    let bookCoverLinks = bookData.cover?.links
    if (bookData.cover?.mode === BookCoverMode.lastIllustrationAdded) {
      bookCoverLinks = await getBookCoverLinks(newBookIllustrations);
    }
    
    if (newBookIllustrations.length > 100) {
      newBookIllustrations = newBookIllustrations.slice(0, 100);
      warning = `max_illustration_100`;
    }

    await bookSnapshot.ref.update({
      count: newBookIllustrations.length,
      cover: { 
        links: bookCoverLinks,
        mode: bookData.cover?.mode ?? BookCoverMode.lastIllustrationAdded,
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
    const bookCoverLinks = await getBookCoverLinks(bookIllustrations);
    const user_custom_index = await getNextBookIndex(userAuth.uid)

    const addedBookDoc = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .add({
        count: bookIllustrations.length,
        cover: {
          mode: BookCoverMode.lastIllustrationAdded,
          links: bookCoverLinks,
          updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
        },
        created_at: adminApp.firestore.FieldValue.serverTimestamp(),
        description,
        illustrations: bookIllustrations,
        layout: 'grid',
        layout_orientation: 'vertical',
        name,
        staff_review: {
          approved: false,
          updated_at: adminApp.firestore.Timestamp.now(),
          user_id: '',
        },
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
        user_custom_index,
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

    
    let bookCoverLinks = bookData.cover?.links
    if (bookData.cover?.mode === BookCoverMode.lastIllustrationAdded) {
      bookCoverLinks = await getBookCoverLinks(newBookIllustrations);
    }

    if (newBookIllustrations.length > 100) {
      newBookIllustrations = newBookIllustrations.slice(0, 100);
      warning = `max_illustration_100`;
    }

    await bookSnapshot.ref.update({
      count: newBookIllustrations.length,
      cover: { 
        links: bookCoverLinks, 
        mode: bookData.cover?.mode ?? BookCoverMode.lastIllustrationAdded,
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

    let bookCoverLinks = bookData.cover?.links
    if (bookData.cover?.mode === BookCoverMode.lastIllustrationAdded) {
      bookCoverLinks = await getBookCoverLinks(newBookIllustrations);
    }

    await bookSnapshot.ref.update({
      count: newBookIllustrations.length,
      cover: {
        links: bookCoverLinks,
        mode: bookData.cover?.mode ?? BookCoverMode.lastIllustrationAdded,
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

    const bookSnapshot = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .doc(book_id)
      .get();

    const bookData = bookSnapshot.data();
    if (!bookSnapshot.exists || !bookData) {
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

    await bookSnapshot.ref.update({
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
        `The function must be called with a valid [bookId] (string) parameter ` +
         `which is the book to update.`,
      );
    }

    if (typeof illustration_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [illustrationId] (string) parameter `+
         `which is the book to update.`,
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

    const illustrationLinks = illustrationData.links;
    const coverLinks: MasterpieceLinks = {
      original: illustrationLinks.original,
      share: { read: "", write: "" },
      storage: illustrationLinks.storage,
      thumbnails: illustrationLinks.thumbnails,
    }

    await bookSnapshot.ref.update({
      cover: {
        id: illustrationSnapshot.id,
        links: coverLinks,
        mode: BookCoverMode.chosenIllustration,
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      },
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    return {
      book: { id: book_id },
      success: true,
    };
  });

/**
 * Update illustrations order inside a book.
 */
 export const reorderIllustrations = functions
 .region(cloudRegions.eu)
 .https
 .onCall(async (params: ReorderBookIllustrationsParams, context) => {
   const userAuth = context.auth;

   if (!userAuth) {
     throw new functions.https.HttpsError(
       'unauthenticated', 
       `The function must be called from an authenticated user.`,
     );
   }

   const { book_id, drop_index, drag_indexes } = params;

   if (typeof book_id !== 'string') {
     throw new functions.https.HttpsError(
       'invalid-argument',
       `The function must be called with a valid [bookId] parameter ` +
        `which is the book's id to update.`,
     );
   }

   if (typeof drop_index !== "number") {
     throw new functions.https.HttpsError(
       'invalid-argument',
       `The function must be called with a valid [drop_index] parameter ` +
        `which is the taregt illustration index where to drop illustrations to reorder.`,
     );
   }

   if (!Array.isArray(drag_indexes) || drag_indexes.length === 0) {
     throw new functions.https.HttpsError(
       'invalid-argument',
       `The function must be called with a valid [drag_indexes] parameter ` +
        `which is an array of indexes. It must not be empty.`,
     );
   }

   // Indexes type check
   for (const index of drag_indexes) {
     if (typeof index !== "number") {
       throw new functions.https.HttpsError(
         "invalid-argument",
         `The function must be called with a valid [drag_indexes] parameter ` +
         `which is an array of [number].`,
       )
     }
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
     )
   }

   const dragIndex = drag_indexes[0]
   let illustrations: BookIllustration[] = bookData.illustrations
   const dropIllustration = illustrations[drop_index]
   const dragIllustration = illustrations[dragIndex]

   illustrations[drop_index] = dragIllustration
   illustrations[dragIndex] = dropIllustration
   
   if (illustrations.length > 100) {
     illustrations = illustrations.slice(0, 100)
   }

   await bookSnapshot.ref.update({
     illustrations,
     updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
   });

   const items = illustrations.map((bookIllustration: BookIllustration) => { 
     return { 
       illustration: { 
         id: bookIllustration.id,
      }, 
       success: true, 
     };
   });

   return {
     items,
     successCount: illustrations.length,
     hasErrors: false,
     warning: "",
   };
 });

export const updateVisibility = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: any, context) => {
    const userAuth = context.auth;
    
    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const { book_id, visibility } = params

    if (typeof book_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [bookId] (string) parameter
         which is the book to update.`,
      );
    }

    if (typeof visibility !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called  with a valid [visibility] ` +
         `argument which is a string.`,
      );
    }

    checkVisibilityValue(visibility);

    const bookSnapshot = await firestore
      .collection(BOOKS_COLLECTION_NAME)
      .doc(book_id)
      .get();

    const bookData = bookSnapshot.data();
    if (!bookSnapshot.exists || !bookData) {
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

    await bookSnapshot.ref.update({
      visibility,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    return {
      book: { id: book_id },
      success: true,
    };
  })

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
 * @returns Thumbnail links of the last added illustration in this book.
 */
async function getBookCoverLinks(
  bookIllustrations: BookIllustration[],
): Promise<MasterpieceLinks> {
  const defaultLinks: MasterpieceLinks = {
    original: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fbooks%2Fdefault%2Fbook_cover_original.png?alt=media&token=81d7ff5f-c92f-4159-9716-25066bcc39b1",
    share: { read: "", write: "" },
    storage: "/static/images/books/default",
    thumbnails: {
      xs: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fbooks%2Fdefault%2Fbook_cover_xs.png?alt=media&token=4a6dc7aa-35de-47be-ad2e-74f3b899c54f",
      s: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fbooks%2Fdefault%2Fbook_cover_s.png?alt=media&token=59bb7c4d-d220-41d5-b493-4c09690d4dd3",
      m: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fbooks%2Fdefault%2Fbook_cover_m.png?alt=media&token=46edc8dd-cb55-4814-a579-06019ff76e7f",
      l: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fbooks%2Fdefault%2Fbook_cover_l.png?alt=media&token=68bfd99c-ccc8-4624-9d96-39988713afe6",
      xl: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fbooks%2Fdefault%2Fbook_cover_xl.png?alt=media&token=c02d42dc-ccbf-491f-ae76-bed4f2f4e20f",
      xxl: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fbooks%2Fdefault%2Fbook_cover_xxl.png?alt=media&token=f96cf2c7-0e8c-4852-a53d-9ae477120161",
    },
  }

  if (bookIllustrations.length === 0) {
    return defaultLinks;
  }

  const lastAddedIllustration = bookIllustrations[bookIllustrations.length - 1];
  if (!lastAddedIllustration.id) {
    return defaultLinks;
  }

  const illustrationSnapshot = await firestore
    .collection(ILLUSTRATIONS_COLLECTION_NAME)
    .doc(lastAddedIllustration.id)
    .get();

  const illustrationData = illustrationSnapshot.data();
  if (!illustrationSnapshot.exists || !illustrationData) {
    return defaultLinks;
  }

  return illustrationData.links;
}

async function getNextBookIndex(userId: string) {
  const userBookStatsSnapshot = await firestore
    .collection(USERS_COLLECTION_NAME)
    .doc(userId)
    .collection(USER_STATISTICS_COLLECTION_NAME)
    .doc(BOOKS_COLLECTION_NAME)
    .get()

  const userBookStatsData = userBookStatsSnapshot.data()
  if (!userBookStatsSnapshot.exists || !userBookStatsData) {
    return 0
  }

  let userBookCreated: number = userBookStatsData.created ?? 0
  userBookCreated = typeof userBookCreated === 'number' ? userBookCreated + 1 : 1
  return userBookCreated
}

