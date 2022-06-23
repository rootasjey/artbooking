///
/// Enums
///
enum BookCoverType {
  /** Booc uses the last uploaded illustration as cover. */
  lastIllustrationAdded = "last_illustration_added",
  /** User manually sets an illustration (inside this book) as cover. */
  chosenIllustration = "chosen_illustration",
  /** User upload a specific image to use as book's cover. */
  uploadedCover = "uploaded_cover",
}

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

enum EnumLicenseType {
  staff = 'staff',
  user = 'user',
}

///
/// Interfaces
///
interface AddTaskParams {
  book_id: string;
  bookCoverLinks: MasterpieceLinks;
  illustration_id: string;
}

interface ApproveBookParams {
  /** Target book to update. */
  book_id: string;
  /** Approved status. */
  approved: boolean;
}

interface ApproveIllustrationParams {
  /** Target illustration to update. */
  illustration_id: string;
  /** Approved status. */
  approved: boolean;
}

interface BookIllustration {
  /** Date when this illustration was added to this book. */
  created_at: FirebaseFirestore.FieldValue;

  /** This illustration's id. */
  id: string;

  /**
   * Virtual scale factor defines illustrations size inside a book 
   * when the [layout] (or [mobileLayout]) is {customGrid}, 
   * {customVerticalList} or {customHorizontalList}.
   */
  scale_factor: {
    height: number;
    width: number;
  };
}

interface CheckPropertiesParams {
  illustration_id: string;
}

interface CreatePostParams {
  /** Post's id to copy attribute from. */
  duplicate_post_id: string;

  /** Language of this post. */
  language: string;
}

interface CreateBookParams {
  description: string;
  illustration_ids: string[];
  name: string;
  visibility: Visibility;
}

interface CreateIllustrationParams {
  name: string;
  visibility: Visibility;
}

interface CreateOneLicenseParams {
  /** License's data. */
  license: License;
}

interface CreateUserAccountParams {
  email: string;
  password: string;
  username: string;
}

interface DataUpdateParams {
  beforeData: FirebaseFirestore.DocumentData;
  afterData: FirebaseFirestore.DocumentData;
  payload: any;
  docId: string;
}

interface DeleteAccountParams {
  id_token: string;
}


interface DeleteBookParams {
  /** Book's id. */
  book_id: string;
}

interface DeleteBooksParams {
  /** Book's id. */
  book_ids: string[];
}

interface DeleteIllustrationParams {
  /** Illustration's id. */
  illustration_id: string;
}

interface DeleteMultipleIllustrationsParams {
  /// Array of illustrations ids.
  illustration_ids: string[];
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
  type: EnumLicenseType,

  /** License to delete. */
  license_id: string;
}

interface DeletePostParams {
  /** Post's id. */
  post_id: string;
}

interface GenerateImageThumbsResult {
  dimensions: ImageDimensions;
  thumbnails: ThumbnailLinks;
}

/** Image's size, orientation & extension. */
interface ImageDimensions {
  /** Image's height. */
  height?: number;

  /** Image orientation. */
  orientation?: number;
  
  /** Image's extension. */
  type?: string;
  
  /** Image's width. */
  width?: number;
}

/** Illustration's license. */
interface License {
  /** The license short name. */
  abbreviation: string;

  /** When this entry was created in Firestore. */
  created_at: FirebaseFirestore.FieldValue;

  /** User's id who created this license. */
  created_by: string

  /** Information about this license. */
  description: string;

  /** Tell if this license has been created by an artist or by the platform's staff. */
  type: EnumLicenseType,

  /** License's id. */
  id: string;

  /** License's term of service & privacy policy update. */
  license_updated_at: FirebaseFirestore.FieldValue;

  /** License's links. */
  links: {
    /** Logo or image link. */
    image: string;

    /** Link to the legal code related to this license. */
    legal_code: string;

    /** Terms of Use url document. */
    terms: string;

    /** Privacy policy url document. */
    privacy: string;

    /** Wikipedia link related to this license. */
    wikipedia: string;

    /** Official website of this license. */
    website: string;
  },

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
    no_additional_restriction: boolean;
  };

  /** When this entry was last updated in Firestore. */
  updated_at: FirebaseFirestore.FieldValue;

  /** User who updated this license. */
  updated_by: string

  /** Specify how the illustration can be used. */
  usage: {
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

    /** Other can add, remove or modify part of this illustration freely. */
    remix: boolean;

    /** Can sell outside of the official app by another individual. */
    sell: boolean;

    /** Can be shared to other. */
    share: boolean;

    /** 
     * Require that anyone who use the work - licensees - 
     * make that new work available under the same license terms. 
    */
    share_a_like: boolean;
    /** Can be viewed. */
    view: boolean;
  },

  /** If this license has a specific version. */
  version: string;
}

interface MasterpieceLinks {
  illustration_id: string,
  original: string,
  share: { 
    read: string, 
    write: string, 
  },
  storage: string,
  thumbnails: {
    xs: string,
    s: string,
    m: string,
    l: string,
    xl: string,
    xxl: string,
  }
}

interface NotifFuncParams {
  userId: string;
  userData: any;
  notifSnapshot: FirebaseFirestore.QueryDocumentSnapshot;
}

interface SetUserAuthorParams {
  illustration_id: string;
}

interface RenameBookPropertiesParams {
  /** This book's id. */
  book_id: string;

  /** This book's description. */
  description: string;

  /** This book's name. */
  name: string;
}

interface ReorderBookIllustrationsParams {
  /** Book's id. */
  book_id: string;

  /** Drop illustration index.. */
  drop_index: number;

  /** Indexes of illustrations being dragged.  */
  drag_indexes: number[];
}

interface SetCoverParams {
  book_id: string
  illustration_id: string
  cover_type: BookCoverType
}

interface ThumbnailLinks {
  [key: string]: String,
  xs: String;
  s: String;
  m: String;
  l: String;
  xl: String;
  xxl: String;
}

interface UpdateBookIllustrationsParams {
  /** Book's id. */
  book_id: string;

  /** illustrations' ids. */
  illustration_ids: string[];
}

interface UpdateBookPropertiesParams {
  /** This book's id. */
  book_id: string;

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
  email: string;
  id_token: string;
}

interface UpdateIllusStylesParams {
  /** Illustration's art movements to set. */
  art_movements: [string],
  
  /** Illustration's id. */
  illustration_id: string;
}

/**
 * Parameters when updating an illustration's license.
 */
interface UpdateIllusLicenseParams {
  /** Illustration'id to update. */
  illustration_id: string;
  /** Specifies how this illustration can be used. */
  license: {
    /**
     * Tell if the license is from the platform or the author.
     * This property is mandatory to know where to find the license from its id.
     */
    type: EnumLicenseType,
    
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
  illustration_id: string;

  /** Illustration's name. */
  name: string;

  /** Detailed text explaining more about this illustration. */
  lore: string;
}

interface UpdateIllusTopicsParams {
  /** Illustration's topics. */
  topics: [string],
  
  /** Illustration's id. */
  illustration_id: string;
}

interface UpdateIllusVisibilityParams {
  /** Illustration's id. */
  illustration_id: string;

  /** Illustration's visibility. */
  visibility: Visibility;
}

interface UpdateUsernameParams {
  username: string;
}
