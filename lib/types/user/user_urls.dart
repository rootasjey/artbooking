class UserUrls {
  /// All URLs in a map.
  Map<String, String>? map = Map<String, String>();

  /// Only social URLs in a map (without [image] for example).
  Map<String, String>? socialMap = Map<String, String>();

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
  String pp;
  String tiktok;
  String tipeee;
  String tumblr;
  String twitch;
  String twitter;
  String website;
  String wikipedia;
  String youtube;

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
    this.map,
    this.other = '',
    this.socialMap,
    this.patreon = '',
    this.pp = '',
    this.tiktok = '',
    this.tipeee = '',
    this.tumblr = '',
    this.twitch = '',
    this.twitter = '',
    this.website = '',
    this.wikipedia = '',
    this.youtube = '',
  });

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
      socialMap: Map(),
      map: Map(),
      other: '',
      patreon: '',
      pp: '',
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

  factory UserUrls.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserUrls.empty();
    }

    final dataMap = Map<String, String>();
    final profilesMap = Map<String, String>();

    data.forEach((key, value) {
      dataMap[key] = value;

      if (key != "image") {
        profilesMap[key] = value;
      }
    });

    return UserUrls(
      artbooking: data['artbooking'] ?? '',
      artstation: data['artstation'] ?? '',
      behance: data['behance'] ?? '',
      deviantart: data['deviantart'] ?? '',
      discord: data['discord'] ?? '',
      dribbble: data['dribbble'] ?? '',
      facebook: data['facebook'] ?? '',
      github: data['github'] ?? '',
      instagram: data['instagram'] ?? '',
      linkedin: data['linkedin'] ?? '',
      map: dataMap,
      socialMap: profilesMap,
      other: data['other'] ?? '',
      patreon: data['patreon'] ?? '',
      pp: data['pp'] ?? '',
      tiktok: data['tiktok'] ?? '',
      tipeee: data['tipeee'] ?? '',
      tumblr: data['tumblr'] ?? '',
      twitch: data['twitch'] ?? '',
      twitter: data['twitter'] ?? '',
      website: data['website'] ?? '',
      wikipedia: data['wikipedia'] ?? '',
      youtube: data['youtube'] ?? '',
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
    other = copy.other;
    patreon = copy.patreon;
    pp = copy.pp;
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
    return Map.from(socialMap!)..removeWhere((key, value) => value.isEmpty);
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['artbooking'] = artbooking;
    data['artstation'] = artstation;
    data['behance'] = behance;
    data['deviantart'] = deviantart;
    data['discord'] = discord;
    data['dribbble'] = dribbble;
    data['facebook'] = facebook;
    data['github'] = github;
    data['instagram'] = instagram;
    data['other'] = other;
    data['patreon'] = patreon;
    data['pp'] = pp;
    data['tiktok'] = tiktok;
    data['tipeee'] = tipeee;
    data['tumblr'] = tumblr;
    data['twitch'] = twitch;
    data['twitter'] = twitter;
    data['website'] = website;
    data['wikipedia'] = wikipedia;
    data['youtube'] = youtube;

    return data;
  }

  /// Update the URL specified by [key] with the new [value].
  /// This function will propagate update to [map] and [socialMap].
  void setUrl(String key, String value) {
    map![key] = value;
    socialMap![key] = value;

    switch (key) {
      case "artbooking":
        artbooking = value;
        break;
      case "artstation":
        artstation = value;
        break;
      case "behance":
        behance = value;
        break;
      case "deviantart":
        deviantart = value;
        break;
      case "discord":
        discord = value;
        break;
      case "dribbble":
        dribbble = value;
        break;
      case "facebook":
        facebook = value;
        break;
      case "github":
        github = value;
        break;
      case "instagram":
        instagram = value;
        break;
      case "linkedin":
        linkedin = value;
        break;
      case "other":
        other = value;
        break;
      case "patreon":
        patreon = value;
        break;
      case "pp":
        pp = value;
        break;
      case "tiktok":
        tiktok = value;
        break;
      case "tipeee":
        tipeee = value;
        break;
      case "tumblr":
        tumblr = value;
        break;
      case "twitch":
        twitch = value;
        break;
      case "twitter":
        twitter = value;
        break;
      case "website":
        website = value;
        break;
      case "wikipedia":
        wikipedia = value;
        break;
      case "youtube":
        youtube = value;
        break;
      default:
    }
  }
}
