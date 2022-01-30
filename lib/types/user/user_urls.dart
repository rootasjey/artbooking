import 'dart:convert';

class UserUrls {
  UserUrls({
    this.artbooking = '',
    this.artstation = '',
    this.behance = '',
    this.deviantart = '',
    this.discord = '',
    this.dribbble = '',
    this.facebook = '',
    this.github = '',
    this.instagram = '',
    this.linkedin = '',
    this.map = const {},
    this.other = '',
    this.patreon = '',
    this.profilePicture = '',
    this.socialMap = const {},
    this.tiktok = '',
    this.tipeee = '',
    this.tumblr = '',
    this.twitch = '',
    this.twitter = '',
    this.website = '',
    this.wikipedia = '',
    this.youtube = '',
  }) {}

  /// All URLs in a map.
  Map<String, String> map = Map<String, String>();

  /// Only social URLs in a map (without [image] for example).
  Map<String, String> socialMap = Map<String, String>();

  String artbooking;
  String artstation;
  String behance;
  String deviantart;
  String discord;
  String dribbble;
  String facebook;
  String github;
  String instagram;
  String linkedin;
  String other;
  String patreon;
  String profilePicture;
  String tiktok;
  String tipeee;
  String tumblr;
  String twitch;
  String twitter;
  String website;
  String wikipedia;
  String youtube;

  UserUrls copyWith({
    String? artbooking,
    String? artstation,
    String? behance,
    String? deviantart,
    String? discord,
    String? dribbble,
    String? facebook,
    String? github,
    String? instagram,
    String? linkedin,
    String? other,
    String? patreon,
    Map<String, String>? map,
    Map<String, String>? socialMap,
    String? profilePicture,
    String? tiktok,
    String? tipeee,
    String? tumblr,
    String? twitch,
    String? twitter,
    String? website,
    String? wikipedia,
    String? youtube,
  }) {
    return UserUrls(
      artbooking: artbooking ?? this.artbooking,
      artstation: artstation ?? this.artstation,
      behance: behance ?? this.behance,
      deviantart: deviantart ?? this.deviantart,
      discord: discord ?? this.discord,
      dribbble: dribbble ?? this.dribbble,
      facebook: facebook ?? this.facebook,
      github: github ?? this.github,
      instagram: instagram ?? this.instagram,
      linkedin: linkedin ?? this.linkedin,
      map: map ?? this.map,
      socialMap: socialMap ?? this.socialMap,
      other: other ?? this.other,
      patreon: patreon ?? this.patreon,
      profilePicture: profilePicture ?? this.profilePicture,
      tiktok: tiktok ?? this.tiktok,
      tipeee: tipeee ?? this.tipeee,
      tumblr: tumblr ?? this.tumblr,
      twitch: twitch ?? this.twitch,
      twitter: twitter ?? this.twitter,
      website: website ?? this.website,
      wikipedia: wikipedia ?? this.wikipedia,
      youtube: youtube ?? this.youtube,
    );
  }

  static const artbookingString = 'artbooking';
  static const artstationString = 'artstation';
  static const behanceString = 'behance';
  static const deviantartString = 'deviantart';
  static const discordString = 'discord';
  static const dribbbleString = 'dribbble';
  static const facebookString = 'facebook';
  static const githubString = 'github';
  static const instagramString = 'instagram';
  static const linkedinString = 'linkedin';
  static const otherString = 'other';
  static const patreonString = 'patreon';
  static const profilePictureString = 'profilePicture';
  static const tiktokString = 'tiktok';
  static const tipeeeString = 'tipeee';
  static const tumblrString = 'tumblr';
  static const twitchString = 'twitch';
  static const twitterString = 'twitter';
  static const websiteString = 'website';
  static const wikipediaString = 'wikipedia';
  static const youtubeString = 'youtube';

  Map<String, dynamic> toMap() {
    return {
      artbookingString: artbooking,
      artstationString: artstation,
      behanceString: behance,
      deviantartString: deviantart,
      discordString: discord,
      dribbbleString: dribbble,
      facebookString: facebook,
      githubString: github,
      instagramString: instagram,
      linkedinString: linkedin,
      otherString: other,
      patreonString: patreon,
      profilePictureString: profilePicture,
      tiktokString: tiktok,
      tipeeeString: tipeee,
      tumblrString: tumblr,
      twitchString: twitch,
      twitterString: twitter,
      websiteString: website,
      wikipediaString: wikipedia,
      youtubeString: youtube,
    };
  }

  factory UserUrls.empty() {
    return UserUrls(
      artbooking: '',
      artstation: '',
      behance: '',
      deviantart: '',
      discord: '',
      dribbble: '',
      facebook: '',
      github: '',
      instagram: '',
      linkedin: '',
      map: {},
      socialMap: {},
      other: '',
      patreon: '',
      profilePicture: '',
      tiktok: '',
      tipeee: '',
      tumblr: '',
      twitch: '',
      twitter: '',
      website: '',
      wikipedia: '',
      youtube: '',
    );
  }

  void copyFrom(UserUrls copy) {
    artbooking = copy.artbooking;
    artstation = copy.artstation;
    behance = copy.behance;
    deviantart = copy.deviantart;
    discord = copy.discord;
    dribbble = copy.dribbble;
    facebook = copy.facebook;
    github = copy.github;
    instagram = copy.instagram;
    linkedin = copy.linkedin;
    map = copy.map;
    socialMap = copy.socialMap;
    other = copy.other;
    patreon = copy.patreon;
    profilePicture = copy.profilePicture;
    tiktok = copy.tiktok;
    tipeee = copy.tipeee;
    tumblr = copy.tumblr;
    twitch = copy.twitch;
    twitter = copy.twitter;
    website = copy.website;
    wikipedia = copy.wikipedia;
    youtube = copy.youtube;
  }

  Map<String, String> getAvailableLinks() {
    return Map.from(socialMap)..removeWhere((key, value) => value.isEmpty);
  }

  /// Update the URL specified by [key] with the new [value].
  /// This function will propagate update to [map] and [socialMap].
  void setUrl(String key, String value) {
    map[key] = value;
    socialMap[key] = value;

    switch (key) {
      case artbookingString:
        artbooking = value;
        break;
      case artstationString:
        artstation = value;
        break;
      case behanceString:
        behance = value;
        break;
      case deviantartString:
        deviantart = value;
        break;
      case discordString:
        discord = value;
        break;
      case dribbbleString:
        dribbble = value;
        break;
      case facebookString:
        facebook = value;
        break;
      case githubString:
        github = value;
        break;
      case instagramString:
        instagram = value;
        break;
      case linkedinString:
        linkedin = value;
        break;
      case otherString:
        other = value;
        break;
      case patreonString:
        patreon = value;
        break;
      case profilePictureString:
        profilePicture = value;
        break;
      case tiktokString:
        tiktok = value;
        break;
      case tipeeeString:
        tipeee = value;
        break;
      case tumblrString:
        tumblr = value;
        break;
      case twitchString:
        twitch = value;
        break;
      case twitterString:
        twitter = value;
        break;
      case websiteString:
        website = value;
        break;
      case wikipediaString:
        wikipedia = value;
        break;
      case youtubeString:
        youtube = value;
        break;
      default:
    }
  }

  factory UserUrls.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserUrls.empty();
    }

    final dataMap = Map<String, String>();
    final socialMap = Map<String, String>();

    map.forEach((key, value) {
      dataMap[key] = value;

      if (key != "image") {
        socialMap[key] = value;
      }
    });

    return UserUrls(
      artbooking: map[artbookingString] ?? '',
      artstation: map[artstationString] ?? '',
      behance: map[behanceString] ?? '',
      deviantart: map[deviantartString] ?? '',
      discord: map[discordString] ?? '',
      dribbble: map[dribbbleString] ?? '',
      facebook: map[facebookString] ?? '',
      github: map[githubString] ?? '',
      instagram: map[instagramString] ?? '',
      linkedin: map[linkedinString] ?? '',
      map: dataMap,
      socialMap: socialMap,
      other: map[otherString] ?? '',
      patreon: map[patreonString] ?? '',
      profilePicture: map[profilePictureString] ?? '',
      tiktok: map[tiktokString] ?? '',
      tipeee: map[tipeeeString] ?? '',
      tumblr: map[tumblrString] ?? '',
      twitch: map[twitchString] ?? '',
      twitter: map[twitterString] ?? '',
      website: map[websiteString] ?? '',
      wikipedia: map[wikipediaString] ?? '',
      youtube: map[youtubeString] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserUrls.fromJson(String source) =>
      UserUrls.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserUrls(artbooking: $artbooking, artstation: $artstation, '
        'behance: $behance, deviantart: $deviantart, discord: $discord, '
        'dribbble: $dribbble, facebook: $facebook, github: $github, '
        'instagram: $instagram, linkedin: $linkedin, other: $other, '
        'patreon: $patreon, profilePicture: $profilePicture, tiktok: $tiktok, '
        'tipeee: $tipeee, tumblr: $tumblr, twitch: $twitch, twitter: $twitter, '
        'website: $website, wikipedia: $wikipedia, youtube: $youtube)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserUrls &&
        other.artbooking == artbooking &&
        other.artstation == artstation &&
        other.behance == behance &&
        other.deviantart == deviantart &&
        other.discord == discord &&
        other.dribbble == dribbble &&
        other.facebook == facebook &&
        other.github == github &&
        other.instagram == instagram &&
        other.linkedin == linkedin &&
        other.other == other &&
        other.patreon == patreon &&
        other.profilePicture == profilePicture &&
        other.tiktok == tiktok &&
        other.tipeee == tipeee &&
        other.tumblr == tumblr &&
        other.twitch == twitch &&
        other.twitter == twitter &&
        other.website == website &&
        other.wikipedia == wikipedia &&
        other.youtube == youtube;
  }

  @override
  int get hashCode {
    return artbooking.hashCode ^
        artstation.hashCode ^
        behance.hashCode ^
        deviantart.hashCode ^
        discord.hashCode ^
        dribbble.hashCode ^
        facebook.hashCode ^
        github.hashCode ^
        instagram.hashCode ^
        linkedin.hashCode ^
        other.hashCode ^
        patreon.hashCode ^
        profilePicture.hashCode ^
        tiktok.hashCode ^
        tipeee.hashCode ^
        tumblr.hashCode ^
        twitch.hashCode ^
        twitter.hashCode ^
        website.hashCode ^
        wikipedia.hashCode ^
        youtube.hashCode;
  }
}
