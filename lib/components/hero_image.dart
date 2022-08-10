import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unicons/unicons.dart';

class HeroImage extends StatefulWidget {
  const HeroImage({
    required this.imageProvider,
    this.heroTag = "",
  });

  /// Image to display.
  final ImageProvider imageProvider;

  /// Hero tag to animate image.
  final String heroTag;

  @override
  _HeroImageState createState() => _HeroImageState();
}

class _HeroImageState extends State<HeroImage> {
  ///
  bool _isPopping = false;
  bool _showControls = false;

  final double _minScale = 0.3;

  PhotoViewController _photoViewController = PhotoViewController();

  @override
  void initState() {
    super.initState();

    _photoViewController.outputStateStream.listen(
      (PhotoViewControllerValue event) {
        if (event.scale! < _minScale && !_isPopping) {
          _isPopping = true;
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      // Note that scrollable widget inside DismissiblePage might limit the functionality
      // If scroll direction matches DismissiblePage direction
      direction: DismissiblePageDismissDirection.down,
      isFullScreen: false,
      child: Stack(
        children: [
          Hero(
            tag: widget.heroTag,
            child: PhotoView(
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              controller: _photoViewController,
              imageProvider: widget.imageProvider,
              onTapUp: (
                BuildContext context,
                TapUpDetails tapUpDetails,
                PhotoViewControllerValue controller,
              ) {
                setState(() => _showControls = !_showControls);
              },
              scaleStateChangedCallback: (PhotoViewScaleState state) {},
            ),
          ),
          if (_showControls)
            Positioned(
              top: 24.0,
              right: 12.0,
              child: CircleButton(
                backgroundColor: Colors.white60,
                icon: Icon(
                  UniconsLine.times,
                  color: Colors.black,
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }
}
