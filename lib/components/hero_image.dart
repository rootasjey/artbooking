import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/utilities.dart';
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
  /// Currently tring to navigate back to the previous route.
  bool _isPopping = false;

  /// Show imagE/page controls if true.
  bool _showControls = false;
  bool _initialized = false;

  final double _minScale = 0.3;

  PhotoViewController _photoViewController = PhotoViewController();

  @override
  void initState() {
    super.initState();

    _showControls = Utilities.storage.getHeroImageControlsVisible();

    _photoViewController.outputStateStream.listen(
      (PhotoViewControllerValue event) {
        final double scale = event.scale ?? 0.0;

        if (_initialized && scale < _minScale && !_isPopping) {
          _isPopping = true;
          Navigator.of(context).pop();
        }
      },
    );

    Future.delayed(Duration(milliseconds: 500), () {
      _initialized = true;
    });
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
                final bool newValue = !_showControls;
                setState(() => _showControls = newValue);
                Utilities.storage.setHeroImageControlsVisible(newValue);
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
