import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkOrGetDefaultVisibility } from './utils';

/**
 * Add illustrations to an existing book.
 */
export const addIllustrations = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateBookIllustrationsParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    const { bookId, illustrationsIds } = params;

    if (typeof bookId !== 'string' 
      || !Array.isArray(illustrationsIds) || illustrationsIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [id] and [illustrationsIds] parameters 
        which are respectively the book's id and the illustrations' ids array to add.`,
      );
    }

    const minimalIllustrations = await createBookIllustrations(illustrationsIds);

    const bookDoc = await adminApp.firestore()
      .collection('books')
      .doc(bookId)
      .get();

    const bookData = bookDoc.data();
    
    if (!bookDoc.exists || !bookData) {
      throw new functions.https.HttpsError(
        'not-found', 
        `The book to update doesn't exist anymore.`,
      );
    }

    const bookIllustrations: BookIllustration[] = bookData.illustrations;
    const newBookIllustrations = bookIllustrations.concat(minimalIllustrations);

    await adminApp.firestore()
      .collection('books')
      .doc(bookId)
      .update({
        illustrations: newBookIllustrations,
      });

    return {
      illustrationsIds,
      success: true,
    };
  });

/**
 * Create a book document in Firestore.
 */
export const createDocument = functions
  .region('europe-west3')
  .https
  .onCall(async (params: CreateBookParams, context) => {
    const userAuth = context.auth;
    const { name } = params;

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

    const bookIllustrations = await createBookIllustrations(params.illustrations);

    try {
      const addedBook = await adminApp.firestore()
        .collection('books')
        .add({
          createdAt: adminApp.firestore.FieldValue.serverTimestamp,
          description: params.description,
          illustrations: bookIllustrations,
          layout: 'grid',
          layoutMobile: 'grid',
          layoutOrientation: 'vertical',
          layoutOrientationMobile: 'vertical',
          matrice: [],
          name: params.name,
          updatedAt: adminApp.firestore.FieldValue.serverTimestamp,
          urls: {
            cover: '',
            icon: '',
          },
          user: {
            id: userAuth.uid,
          },
          visibility: checkOrGetDefaultVisibility(params.visibility),
        });

      // Update user's stats
      const userDoc = await adminApp.firestore()
        .collection('users')
        .doc(userAuth.uid)
        .get();

      const userData = userDoc.data();

      if (userData) {
        let added: number = userData.stats?.books?.added;
        let own: number = userData.stats?.books?.own;

        if (typeof added !== 'number') {
          added = 0;
        }

        if (typeof own !== 'number') {
          own = 0;
        }

        added++;
        own++;

        await userDoc
          .ref
          .update({
            'stats.books.added': added,
            'stats.books.own': own,
            updatedAt: adminApp.firestore.Timestamp.now(),
          });
      }

      return {
        id: addedBook.id,
        success: true,
      };
    } catch (error) {
      console.error(error);
      throw new functions.https.HttpsError(
        'internal', 
        `There was an internal error. Please try again later or contact us.`,
      );
    }
  });

/**
 * Delete a book document from Firestore.
 */
export const deleteDocument = functions
  .region('europe-west3')
  .https
  .onCall(async (params: DeleteBookParams, context) => {
    const userAuth = context.auth;
    const { id } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [id] argument
         which is the illustration's id to delete.`,
      );
    }

    try {
      await adminApp.firestore()
        .collection('books')
        .doc(id)
        .delete();

      // Update user's stats
      // -------------------
      const userDoc = await adminApp.firestore()
        .collection('users')
        .doc(userAuth.uid)
        .get();

      const userData = userDoc.data();

      if (userData) {
        let deleted: number = userData.stats?.books?.deleted;
        let own: number = userData.stats?.books?.own;

        if (typeof deleted !== 'number') {
          deleted = 0;
        }

        if (typeof own !== 'number') {
          own = 0;
        }

        own = own > 0 ? own - 1 : 0;
        deleted++

        await userDoc.ref
          .update({
            'stats.books.own': own,
            'stats.books.deleted': deleted,
            updatedAt: adminApp.firestore.Timestamp.now(),
          });
      }

      return {
        id,
        success: true,
      };
    } catch (error) {
      throw new functions.https.HttpsError(
        'internal', 
        `There was an internal error. Please try again later or contact us.`,
      );
    }
  });

/**
 * Delete multiple books documents from Firestore.
 */
export const deleteDocuments = functions
  .region('europe-west3')
  .https
  .onCall(async (params: DeleteBooksParams, context) => {
    const userAuth = context.auth;
    const { ids } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (!Array.isArray(ids) || ids.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [ids] argument 
        which is an array of illustrations' ids to delete.`,
      );
    }

    /** How many operations succeeded. */
    let successCount = 0;

    for await (const id of ids) {
      try {
        await adminApp.firestore()
          .collection('books')
          .doc(id)
          .delete();

        successCount++;

      } catch (error) {
        console.error(error);
      }
    }

    try { // Update user's stats
      const userDoc = await adminApp.firestore()
        .collection('users')
        .doc(userAuth.uid)
        .get();

      const userData = userDoc.data();

      if (userData) {
        let deleted: number = userData.stats?.books?.deleted;
        let own: number = userData.stats?.books?.own;

        if (typeof deleted !== 'number') {
          deleted = 0;
        }

        if (typeof own !== 'number') {
          own = 0;
        }

        own = own > 0 ? own - successCount : 0;
        deleted += successCount;

        await userDoc.ref
          .update({
            'stats.books.own': own,
            'stats.books.deleted': deleted,
            updatedAt: adminApp.firestore.Timestamp.now(),
          });
      }

      return {
        ids,
        successCount,
        success: successCount === ids.length,
      };
    } catch (error) {
      console.error(error);
      throw new functions.https.HttpsError(
        'internal', 
        `There was an internal error. Please try again later or contact us.`,
      );
    }
  });

/**
 * Delete illustrations from an existing book.
 */
export const removeIllustrations = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateBookIllustrationsParams, context) => {
    const userAuth = context.auth;
    const { bookId, illustrationsIds } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof bookId !== 'string') {
      throw new functions.https.HttpsError('invalid-argument',
        `The function must be called with a valid [bookId] parameter
         which is the book to update.`,
      );
    }

    if (!Array.isArray(illustrationsIds) || illustrationsIds.length === 0) {
      throw new functions.https.HttpsError('invalid-argument',
        `The function must be called with a valid [illustrationsIds] parameter
         which is the array of illustrations to remove from the book.`,
      );
    }

    const bookDoc = await adminApp.firestore()
      .collection('books')
      .doc(bookId)
      .get();
      
    const bookData = bookDoc.data();
    
    if (!bookDoc.exists || !bookData){
      throw new functions.https.HttpsError(
        'not-found', 
        `The book to update doesn't exist anymore.`,
      );
    }

    const bookIllustrations: BookIllustration[] = bookData.illustrations;
    const newBookIllustrations = bookIllustrations
      .filter(illus => !illustrationsIds.includes(illus.id));

    await bookDoc.ref.update({
      illustrations: newBookIllustrations,
    });

    return {
      illustrationsIds,
      success: true,
    };
  });

/**
 * Update book's properties.
 */
export const updateBookProperties = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateBookPropertiesParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    checkUpdateBookPropsParam(params);

    const { 
      description, 
      bookId, 
      layout, 
      layoutMobile, 
      layoutOrientation, 
      layoutOrientationMobile, 
      name, 
      urls, 
      visibility, 
    } = params;

    await adminApp.firestore()
      .collection('books')
      .doc(bookId)
      .update({
        description,
        layout,
        layoutMobile,
        layoutOrientation,
        layoutOrientationMobile,
        name,
        urls,
        visibility,
      });

    return {
      bookId,
      success: true,
    };
  });

/**
 * Update illustrations' position in an existing book.
 * For all [layout] except {extendedGrid} with the [matrice] property.
 */
export const updateIllusPosition = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateIllusPositionParams, context) => {
    const userAuth = context.auth;
    const { bookId,
       beforePosition,
       afterPosition,
       illustrationId,
    } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof bookId !== 'string' || typeof illustrationId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [bookId] & [illustrationId] parameters
         which are respectively the book's id & the illustration's id to update.`,
      );
    }

    if (typeof beforePosition !== 'number' || typeof afterPosition !== 'number') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid 
        [beforePosition] & [afterPosition] parameters 
        which are respectively the position before and the position after the update.`,
      );
    }

    const bookDoc = await adminApp.firestore()
      .collection('books')
      .doc(bookId)
      .get();
      
    const bookData = bookDoc.data();

    if (!bookDoc.exists || !bookData){
      throw new functions.https.HttpsError(
        'not-found', 
        `The book to update doesn't exist anymore.`,
      );
    }

    const illustrations: BookIllustration[] = bookData.illustrations;
    const deletedItems = illustrations.splice(beforePosition, 1);

    if (!deletedItems || deletedItems.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `Invalid [beforePosition] argument. The number specified may be out of range.`,
      );
    }

    const illusToMove = deletedItems[0];
    illustrations.splice(afterPosition, 0, illusToMove);

    await adminApp.firestore()
      .collection('books')
      .doc(bookId)
      .update({
        illustrations,
      });

    return {
      illustrationId,
      success: true,
    };
  });

// ----------------
// Helper functions
// ----------------

/**
 * Check new book's properties types and values.
 * @param params - Updated book's properties.
 */
function checkUpdateBookPropsParam(params: UpdateBookPropertiesParams) {
  if (!params) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must be called with a valid [id] & [illustrationsIds] parameters 
      which are respectively the book's id and an illustrations' ids array.`,
    );
  }

  const {
    description,
    layout,
    layoutMobile,
    layoutOrientation,
    layoutOrientationMobile,
    name,
    visibility,
  } = params;

  if (typeof description !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [description] parameter
       which is the updated Book's description.`,
    )
  }

  if (typeof layout !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [layout] parameter which is the updated Book's layout.`,
    );
  }

  const allowedLayouts = [
    'adaptativeGrid',
    'customExtendedGrid',
    'customGrid',
    'customList',
    'grid',
    'horizontalList',
    'horizontalListWide',
    'largeGrid',
    'smallGrid',
    'twoPagesBook',
    'verticalList',
    'verticalListWide',
  ];

  if (!allowedLayouts.includes(layout)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Allow values for [layout] parameter are: adaptativeGrid, 
      customExtendedGrid,customGrid, customList, grid, horizontalList, 
      horizontalListWide, largeGrid, smallGrid, twoPagesBook, 
      verticalList, verticalListWide.`,
    );
  }

  if (typeof layoutMobile !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [layoutMobile] parameter 
      which is the updated Book's layout on small screens.`,
    )
  }

  if (!allowedLayouts.includes(layoutMobile)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Allow values for [layout] parameter are: adaptativeGrid, customExtendedGrid,
       customGrid, customList, grid, horizontalList, horizontalListWide,
       largeGrid, smallGrid, twoPagesBook, verticalList, verticalListWide.`,
    );
  }

  const allowedLayoutOrientations = ['both', 'horizontal', 'vertical'];

  if (typeof layoutOrientation !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [layoutOrientation] parameter
       which is the updated Book's layout orientation.`,
    )
  }

  if (!allowedLayoutOrientations.includes(layoutOrientation)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Allow values for [layoutOrientation] parameter are:
       both, horizontal, vertical,`,
    );
  }

  if (typeof layoutOrientationMobile !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [layoutOrientationMbile] parameter
       which is the updated Book's layout orientation on small screens.`,
    )
  }

  if (!allowedLayoutOrientations.includes(layoutOrientationMobile)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Allow values for [layoutOrientationMobile] parameter are:
       both, horizontal, vertical.`,
    );
  }

  if (typeof name !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [name] parameter
       which is the updated Book's name.`,
    )
  }

  if (typeof visibility !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [visibility] parameter
       which is the updated Book's visibility.`,
    )
  }

  const allowedVisibility = ['acl', 'challenge', 'contest', 'gallery', 'private', 'public'];

  if (!allowedVisibility.includes(visibility)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Allow values for [visibility] parameter are:
       'acl', 'challenge', 'contest', 'gallery', 'private', 'public'.`,
    );
  }
}

/**
 * Create an array of simple illustrations objects.
 * @param ids - Illustrations' ids to create.
 */
async function createBookIllustrations(ids: string[]) {
  if (!ids || ids.length === 0) {
    return [];
  }

  const arrayResult: BookIllustration[] = [];

  for (const id of ids) {
    arrayResult.push({
      createdAt: adminApp.firestore.FieldValue.serverTimestamp,
      id,
      updatedAt: adminApp.firestore.FieldValue.serverTimestamp,
      vScaleFactor: {
        height: 1,
        width: 1,
        mobileHeight: 1,
        mobileWidth: 1,
      },
    });
  }

  return arrayResult;
}
