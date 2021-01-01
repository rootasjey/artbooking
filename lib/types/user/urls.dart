class UserUrls {
  String artstation;
  String deviantart;
  String discord;
  String dribbble;
  String facebook;
  String instagram;
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
    this.artstation = '',
    this.deviantart = '',
    this.discord = '',
    this.dribbble = '',
    this.facebook = '',
    this.instagram = '',
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

  factory UserUrls.fromJSON(Map<String, dynamic> data) {
    return UserUrls(
      artstation: data['artstation'],
      deviantart: data['deviantart'],
      discord: data['discord'],
      dribbble: data['dribbble'],
      facebook: data['facebook'],
      instagram: data['instagram'],
      patreon: data['patreon'],
      pp: data['pp'],
      tiktok: data['tiktok'],
      tipeee: data['tipeee'],
      tumblr: data['tumblr'],
      twitch: data['twitch'],
      twitter: data['twitter'],
      website: data['website'],
      wikipedia: data['wikipedia'],
      youtube: data['youtube'],
    );
  }
}
