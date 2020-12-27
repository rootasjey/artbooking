enum Visibility {
  acl = 'acl',
  challenge = 'challenge',
  contest = 'contest',
  gallery = 'gallery',
  private = 'private',
  publiic = 'public',
}

interface CreateUserAccountParams {
  email: string;
  password: string;
  username: string;
}

interface CreateImageParams {
  name: string;
  isUserAuthor: boolean;
  visibility: Visibility;
}

interface DataUpdateParams {
  beforeData: FirebaseFirestore.DocumentData;
  afterData: FirebaseFirestore.DocumentData;
  payload: any;
  docId: string;
}

interface DeleteAccountParams {
  idToken: string;
}


interface DeleteImageParams {
  /// Image's id.
  id: string;
}

interface DeleteMultipleImagesParams {
  /// Array of images ids.
  ids: string[];
}

interface DeleteListParams {
  listId: string;
  idToken: string;
}
interface NotifFuncParams {
  userId: string;
  userData: any;
  notifSnapshot: FirebaseFirestore.QueryDocumentSnapshot;
}

interface SetUserAuthorParams {
  imageId: string;
}

interface ThumbnailUrls {
  [key: string]: String,
  t360: String;
  t480: String;
  t720: String;
  t1080: String;
}

interface UpdateEmailParams {
  newEmail: string;
  idToken: string;
}

interface UpdateImagePropsParams {
  /// Image's description.
  description: string,
  
  /// Image's id.
  id: string;
  
  /// Image's name.
  name: string;
  
  /// Image's license.
  license: string;

  /// Image's visibility.
  visibility: Visibility;
}

interface UpdateImageCategoriesParams {
  /// Image's categories.
  categories: [string],
  
  /// Image's id.
  id: string;
}

interface UpdateImageTopicsParams {
  /// Image's topics.
  topics: [string],
  
  /// Image's id.
  id: string;
}

interface UpdateUsernameParams {
  newUsername: string;
}
