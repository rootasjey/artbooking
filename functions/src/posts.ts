import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { cloudRegions } from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

/**
 * Create a post in Firestore & its associated file in Firebase Storage.
 */
export const createOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: CreatePostParams, context) => {
    const userAuth = context.auth;
    const uid = userAuth?.uid ?? "";

    if (!userAuth || !uid) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    const { language } = params;

    const postDoc = await firestore.collection("posts")
      .add({
        acl: {
          [uid]: "owner",
        },
        cover: {
          path: "",
          updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
        },
        created_at: adminApp.firestore.FieldValue.serverTimestamp(),
        description: "",
        icon: {
          path: "",
          type: "uniconsline",
          updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
        },
        languages: {
          [language]: true,
        },
        name: "",
        published_at: adminApp.firestore.FieldValue.serverTimestamp(),
        storage_path: "",
        tags: {},
        translations: {},
        visibility: "private",
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
        user_ids: {
          [uid]: true,
        },
        word_count: 0,
      });

    const storage_path = `posts/${postDoc.id}/content.md`;

    await postDoc.update({
      storage_path,
    });

    const fileRef = adminApp.storage().bucket().file(storage_path);
    await fileRef.create();
    await fileRef.setMetadata({
      metadata: {
        owner: uid,
        post_id: postDoc.id,
        visibility: "private",
        [uid]: "write"
      },
    })
  })

/**
 * Delete a post in Firestore & its associated file content & media in Firebase Storage.
 */
export const deleteOne = functions
  .region(cloudRegions.eu)
  .https
  .onCall(async (params: DeletePostParams, context) => {
    const userAuth = context.auth;
    const { post_id } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof post_id !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [post_id] argument (string) ` +
         ` which is the post's id to delete.`,
        );
    }

    const postSnap = await firestore
      .collection("posts")
      .doc(post_id)
      .get();

    const postData = postSnap.data();
    if (!postSnap.exists || !postData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The post id [${post_id}] doesn't exist.`,
      );
    }

    const userIds = Object.keys(postData.user_ids);

    if (!userIds.includes(userAuth.uid)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to delete this post.`,
      );
    }
    
    const role = postData.acl[userAuth.uid];
    
    if (role !== "owner" && role !== "write") {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to delete this post.`,
      );
    }

    // Delete files from Cloud Storage
    // const dir = await adminApp.storage()
    //   .bucket()
    //   .getFiles({
    //     directory: `posts/${post_id}`
    //   });

    // const files = dir[0];
    // for await (const file of files) {
    //   await file.delete();
    // }

    await firebaseTools.firestore
      .delete(`posts/${post_id}`, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
      });


    await postSnap.ref.delete();

    return {
      post: {
        id: post_id,
      },
      success: true,
    };
  })

  /**
   * Update `updated_at` field of the Firestore document when the file's content has changed.
   */
export const onUpdatePostContent = functions
  .region(cloudRegions.eu)
  .storage
  .object()
  .onFinalize(async (objectMetadata, context) => {
    const customMetadata = objectMetadata.metadata;
    if (!customMetadata) { return; }

    const postId = customMetadata.post_id;
    const fileType = customMetadata.file_type;
    if (fileType !== "post" || !postId) { return; }

    return await firestore.collection("posts").doc(postId).update({
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });
  })

/**
 * Update `updated_at` field of the Firestore document when a metadata property has changed.
 */
export const onUpdatePostMetadata = functions
  .region(cloudRegions.eu)
  .firestore
  .document("posts/{post_id}")
  .onUpdate(async (snapshot, context) => {
    if (!atLeastOnePropertyChanged(snapshot)) {
      return;
    }
    
    const payload: Record<string, any> = {
      updated_at: adminApp.firestore.FieldValue.serverTimestamp()
    };

    const beforeVisibility = snapshot.before.data()["visibility"];
    const afterVisibility = snapshot.after.data()["visibility"];

    if ((beforeVisibility === "private" || beforeVisibility === "acl") 
      && afterVisibility === "public") {
        payload.published_at = adminApp.firestore.FieldValue.serverTimestamp();
      }

    await syncVisibility(snapshot);

    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();

    if (afterData.cover.path !== beforeData.cover.path) {
      payload.cover.updated_at = adminApp.firestore.FieldValue.serverTimestamp();
    }
    
    if (afterData.icon.path !== beforeData.icon.path) {
      payload.icon.updated_at = adminApp.firestore.FieldValue.serverTimestamp();
    }

    await snapshot.after.ref.update(payload);
  })

/**
 * Return true if at least one field is different from this old document version.
 * Some fields are ignored to avoid infinite loop (as `updated_at`).
 * @param snapshot Firestore change document snapshot.
 * @returns True if the target document has a different field.
 */
function atLeastOnePropertyChanged(snapshot: functions.Change<functions.firestore.QueryDocumentSnapshot>): boolean {
  const beforeData = snapshot.before.data();
  const afterData = snapshot.after.data();

  if (afterData.name !== beforeData.name) {
    return true;
  }

  if (afterData.description !== beforeData.description) {
    return true;
  }

  if (afterData.word_count !== beforeData.word_count) {
    return true;
  }

  const beforeTags = Object.keys(beforeData.tags);
  const afterTags = Object.keys(afterData.tags);
  
  for (const afterTag of afterTags) {
    if (!beforeTags.includes(afterTag)) {
      return true;
    }
  }
  
  const beforeUserIds = Object.keys(beforeData.user_ids);
  const afterUserIds = Object.keys(afterData.user_ids);
  
  for (const afterUserId of afterUserIds) {
    if (!beforeUserIds.includes(afterUserId)) {
      return true;
    }
  }

  if (afterData.cover.path !== beforeData.cover.path) {
    return true;
  }

  if (afterData.icon.path !== beforeData.icon.path) {
    return true;
  }

  if (afterData.visibility !== beforeData.visibility) {
    return true;
  }

  return false;
}

async function syncVisibility(snapshot: functions.Change<functions.firestore.QueryDocumentSnapshot>) {
  const beforeVisibility = snapshot.before.data()["visibility"];
  const afterVisibility = snapshot.after.data()["visibility"];

  if (beforeVisibility === afterVisibility) {
    return;
  }

  const file = adminApp.storage().bucket().file(`posts/${snapshot.after.id}/content.md`);

  const [metadata] = await file.getMetadata();
  metadata.metadata.visibility = afterVisibility;

  await file.setMetadata(metadata);
}

