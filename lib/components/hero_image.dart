import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class HeroImage extends StatefulWidget {
  const HeroImage({
    required this.imageProvider,
    this.backgroundDecoration,
    this.minScale = 0.3,
    this.maxScale = 2.0,
  });

  final ImageProvider imageProvider;
  final Decoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  _HeroImageState createState() => _HeroImageState();
}

class _HeroImageState extends State<HeroImage> {
  PhotoViewController photoViewController = PhotoViewController();
  bool isPop = false;

  @override
  void initState() {
    super.initState();

    photoViewController.outputStateStream.listen((event) {
      if (event.scale! < widget.minScale && !isPop) {
        isPop = true;
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    photoViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: PhotoView(
        imageProvider: widget.imageProvider,
        backgroundDecoration: widget.backgroundDecoration as BoxDecoration?,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        controller: photoViewController,
        heroAttributes: const PhotoViewHeroAttributes(tag: "image_hero"),
        onTapUp: (context, tapUpDetails, controller) {
          Navigator.of(context).pop();
        },
        scaleStateChangedCallback: (state) {},
      ),
    );
  }
}
