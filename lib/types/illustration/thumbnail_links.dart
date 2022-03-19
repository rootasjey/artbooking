import 'package:artbooking/types/json_types.dart';

class ThumbnailLinks {
  const ThumbnailLinks({
    this.xl = "",
    this.xxl = "",
    this.l = "",
    this.m = "",
    this.s = "",
    this.xs = "",
  });

  /// Thumbnail with a width of ~1920 pixels.
  final String xl;

  /// Thumbnail with a width of ~2400 pixels.
  final String xxl;

  /// Thumbnail with a width of ~1080 pixels.
  final String l;

  /// Thumbnail with a width of ~720 pixels.
  final String m;

  /// Thumbnail with a width of ~480 pixels.
  final String s;

  /// Thumbnail with a width of ~360 pixels.
  final String xs;

  factory ThumbnailLinks.empty() {
    return ThumbnailLinks(
      xs: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fillustrations%2Fmissing_illustration_360.png?alt=media&token=44664f38-eeb7-4392-8a43-74c05dcb56f4",
      s: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fillustrations%2Fmissing_illustration_480.png?alt=media&token=5471f355-4e25-4783-a5dc-544adc62d34b",
      m: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fillustrations%2Fmissing_illustration_720.png?alt=media&token=295c6b98-ede7-41f9-819d-87b7a59766ea",
      l: "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Fillustrations%2Fmissing_illustration_1024.png?alt=media&token=61775649-95cf-4b68-895f-77476a743d83",
    );
  }

  factory ThumbnailLinks.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return ThumbnailLinks.empty();
    }

    return ThumbnailLinks(
      xl: data["xl"] ?? "",
      xxl: data["xxl"] ?? "",
      l: data["l"] ?? "",
      m: data["m"] ?? "",
      s: data["s"] ?? "",
      xs: data["xs"] ?? "",
    );
  }

  Json toMap() {
    return {
      "xl": xl,
      "xxl": xxl,
      "l": l,
      "m": m,
      "s": s,
      "xs": xs,
    };
  }
}
