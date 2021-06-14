enum BookLayout {
  /**
   * Display illustrations on a grid with a size adapted 
   * to the aspect ratio of each illustration's dimensions.
   * e.g. if an illustration has an original size of 2000x2000, 
   * it'll be displayed as a 300x300 item — 
   * if another one is 2000x3000, it'll be displayed as a 150x300 item.
   */
  adaptativeGrid = 'adaptativeGrid',

  /**
   * Display items on a grid with a custom size for each illustrations. 
   * They're 300x300 by default. With the [vScaleFactor] property, they can be larger or smaller. 
   * The grid can both be scrolled on the horizontal and vertical axis. 
   * This grid con contain a row and a column that exceed the screen's size. 
   * Items's position are stored in the [matrice] property.
   */
  customExtendedGrid = 'customExtendedGrid',

  /**
   * Display items on a grid with a custom size for each illustrations. 
   * They're 300x300 by default. With the [vScaleFactor] property, they can be larger or smaller. 
   * The grid can only be scrolled on the horizontal or vertical axis according to [layoutOrientation].
   */
  customGrid = 'customGrid',

  /**
   * Display items in a list with a custom size for each illustrations. 
   * They're 300x300 by default. With the [vScaleFactor] property, they can be larger or smaller.
   */
  customList = 'customList',

  /** Display illustrations on a grid of 300x300. */
  grid = 'grid',

  /** Display illustrations in a horizontal list of 300x300px. */
  horizontalList = 'horizontalList',

  /** Display illustrations in a horizontal list of 300px width, and 150px height. */
  horizontalListWide = 'horizontalListWide',

  /** Display illustrations on a grid of 600x600. */
  largeGrid = 'largeGrid',

  /** Display illustrations on a grid of 150x150. */
  smallGrid = 'smallGrid',
  
  /** Display two illustrations at a time on a screen. */
  twoPagesBook = 'twoPagesBook',
  
  /** Display illustrations in a list with item of 300x300 pixels. */
  verticalList = 'verticalList',
  
  /** Display illustrations on a grid of 300px width and 150px height. */
  verticalListWide = 'verticalListWide',
}

enum LayoutOrientation {
  both = 'both',
  horizontal = 'horizontal',
  vertical = 'vertical',
}

/** Control if other people can view this content. */
enum Visibility {
  /** Custom access control list based on users' roles. */
  acl = 'acl',

  /** Only the owner can view this illustration. */
  private = 'private',

  /** Anyone with a link can view this illustration. */
  public = 'public',

  /**
   * Hidden from user's profile (if not the owner) but accessible through link or containers.
   * Containers can be: books, challenges, contests, galleries.
   */
  unlisted = 'inlisted',
}

enum LicenseFrom {
  app = 'app',
  author = 'author',
}

interface CreateUserAccountParams {
  email: string;
  password: string;
  username: string;
}

interface CreateBookParams {
  description: string;
  illustrationIds: string[];
  name: string;
  visibility: Visibility;
}

interface CreateIllustrationParams {
  name: string;
  isUserAuthor: boolean;
  visibility: Visibility;
}

interface CreateOneLicenseParams {
  /**
   * Tell if the license is from the platform or the author.
   * This property is mandatory to know where to find the license from its id.
   */
  from: LicenseFrom,
  
  /** License's data. */
  license: License;
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


interface DeleteBookParams {
  /** Book's id. */
  bookId: string;
}

interface DeleteBooksParams {
  /** Book's id. */
  bookIds: string[];
}

interface DeleteIllustrationParams {
  /** Illustration's id. */
  illustrationId: string;
}

interface DeleteMultipleIllustrationsParams {
  /// Array of illustrations ids.
  illustrationIds: string[];
}

interface DeleteListParams {
  listId: string;
  idToken: string;
}

interface DeleteOneLicenseParams {
  /**
   * Tell if the license is from the platform or the author.
   * This property is mandatory to know where to find the license from its id.
   */
  from: LicenseFrom,

  /** License to delete. */
  licenseId: string;
}

interface GenerateImageThumbsResult {
  dimensions: ImageDimensions;
  thumbnails: ThumbnailUrls;
}

interface ImageDimensions {
  height: number;
  width: number;
}

/** Illustration's license. */
interface License {
  /** The license short name. */
  abbreviation: string;

  /** When this entry was created in Firestore. */
  createdAt: FirebaseFirestore.FieldValue;

  /** User who created this license. */
  createdBy: {
    id: string;
  },

  /** Information about this license. */
  description: string;

  /** Tell if this license has been created by an artist or by the platform's staff. */
  from: LicenseFrom,

  /** License's id. */
  id: string;

  /** License's term of service & privacy policy update. */
  licenseUpdatedAt: FirebaseFirestore.FieldValue;

  /** License's name. */
  name: string;

  /** Additional information about this license usage. */
  notice: string;

  /** Restrictions related to usage. */
  terms: {
    /** 
     * You must give appropriate credit, provide a link to the license, 
     * and indicate if changes were made. 
    */
    attribution: boolean;

    /**
     * You may not apply legal terms or technological measures 
     * that legally restricts others from doing anything the license permits.
     */
    noAdditionalRestriction: boolean;
  };

  /** When this entry was last updated in Firestore. */
  updatedAt: FirebaseFirestore.FieldValue;

  /** User who updated this license. */
  updatedBy: {
    id: string;
  },

  /** Specify how the illustration can be used. */
  usage: {
    /** Other can add, remove or modify part of this illustration freely. */
    adapt: boolean;

    /** Can be used in commercial projects & products. */
    commercial: boolean;

    /** Can be used in other free and open source projects. */
    foss: boolean;

    /** Can be used in other free softwares and projects. */
    free: boolean;

    /** Can be used in other open source projects. */
    oss: boolean;

    /** Can be used for personal use (e.g. wallpaper). */
    personal: boolean;

    /** Can be freely printed. */
    print: boolean;

    /** Can sell outside of the official app by another individual. */
    sell: boolean;

    /** Can be shared to other. */
    share: boolean;

    /** 
     * Require that anyone who use the work - licensees - 
     * make that new work available under the same license terms. 
    */
    shareALike: boolean;
    /** Can be viewed. */
    view: boolean;
  },

  /** License's urls. */
  urls: {
    /** Logo or image link. */
    image: string;

    /** Link to the legal code related to this license. */
    legalCode: string;

    /** Terms of Use url document. */
    terms: string;

    /** Privacy policy url document. */
    privacy: string;

    /** Wikipedia link related to this license. */
    wikipedia: string;

    /** Official website of this license. */
    website: string;
  },

  /** If this license has a specific version. */
  version: string;
}

interface NotifFuncParams {
  userId: string;
  userData: any;
  notifSnapshot: FirebaseFirestore.QueryDocumentSnapshot;
}

interface SetUserAuthorParams {
  illustrationId: string;
}

interface BookIllustration {
  id: string;
  vScaleFactor: {
    height: number;
    mobileHeight: number;
    mobileWidth: number;
    width: number;
  };
}

interface ThumbnailUrls {
  [key: string]: String,
  t360: String;
  t480: String;
  t720: String;
  t1080: String;
}

interface UpdateBookIllustrationsParams {
  /** Book's id. */
  bookId: string;

  /** illustrations' ids. */
  illustrationIds: string[];
}

interface UpdateBookPropertiesParams {
  /** This book's id. */
  bookId: string;

  /** This book's description. */
  description: string;

  /** Defines content layout and presentation. */
  layout: BookLayout;
  
  /** Defines content layout and presentation for small screens. Same as layout. */
  layoutMobile: BookLayout;
  
  /** 
   * Defines layout scroll orientation. 
   * Will be used if [layout] value is {adaptativeGrid}, 
   * {customGrid}, {customList}, {grid}, {smallGrid}, {largeGrid}.
   */
  layoutOrientation: LayoutOrientation;

  /**
   * For small resolutions, defines layout scroll orientation. 
   * Will be used if [layout] value is {adaptativeGrid}, 
   * {customGrid}, {customList}, {grid}, {smallGrid}, {largeGrid}.
   */
  layoutOrientationMobile: LayoutOrientation;

  /** This book's name. */
  name: string;

  urls: {
    cover: string;
    icon: string;
  }

  visibility: Visibility;
}

interface UpdateEmailParams {
  newEmail: string;
  idToken: string;
}
interface UpdateIllusPositionParams {
  /** Illustration's position (int) before the update. */
  afterPosition: number;
  
  /** Illustration's position (int) after the update. */
  beforePosition: number;
  
  /** Book's id to update. */
  bookId: string;

  /** Illustration's id to re-order. */
  illustrationId: string;
}

interface UpdateIllusStylesParams {
  /** Image's styles. */
  styles: [string],
  
  /** Illustration's id. */
  illustrationId: string;
}

/**
 * Parameters when updating an illustration's license.
 */
interface UpdateIllusLicenseParams {
  /** Illustration'id to update. */
  illustrationId: string;
  /** Specifies how this illustration can be used. */
  license: {
    /**
     * Tell if the license is from the platform or the author.
     * This property is mandatory to know where to find the license from its id.
     */
    from: LicenseFrom,
    
    /**
     * Match an existing license id if not empty.
     * The license can be a predefined on from the platform or a custom author's one.
     */
    id: string,
  },
}

interface UpdateIllusPresentationParams {
  /** Illustration's description. */
  description: string,

  /** Illustration's id. */
  illustrationId: string;

  /** Illustration's name. */
  name: string;

  /** Detailed text explaining more about this illustration. */
  story: string;
}

interface UpdateIllusTopicsParams {
  /** Image's topics. */
  topics: [string],
  
  /** Illustration's id. */
  illustrationId: string;
}

interface UpdateIllusVisibilityParams {
  /** Illustration's id. */
  illustrationId: string;

  /** Illustration's visibility. */
  visibility: Visibility;
}

interface UpdateUsernameParams {
  newUsername: string;
}
