import 'dart:io';

import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  /// Prevent earky navigation back from this page.
  bool _initialized = false;

  /// Currently tring to navigate back to the previous route.
  bool _isPopping = false;

  /// Show imagE/page controls if true.
  bool _showControls = false;

  /// Minimum allow scale.
  double? _minScale;

  /// Maximum allow scale.
  double? _initScale;

  /// Show imagE/page controls if true.
  PhotoViewController _photoViewController = PhotoViewController();

  @override
  void initState() {
    super.initState();

    _showControls = Utilities.storage.getHeroImageControlsVisible();

    _photoViewController.outputStateStream.listen(
      (PhotoViewControllerValue event) {
        final double scale = event.scale ?? 0.0;
        if (_initScale == null) {
          _initScale = scale;
          _minScale = scale * 0.8;
        }

        final double minScale = _minScale ?? 0;

        if (_initialized && scale < minScale && !_isPopping) {
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
    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Constants.colors.lightBackground,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );
    }

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
      disabled: false,
      child: Stack(
        children: [
          Hero(
            tag: widget.heroTag,
            child: PhotoView(
              minScale: _minScale,
              initialScale: _initScale,
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              controller: _photoViewController,
              imageProvider: widget.imageProvider,
              onTapUp: onTapUpImage,
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

  void onTapUpImage(
    BuildContext context,
    TapUpDetails tapUpDetails,
    PhotoViewControllerValue controller,
  ) {
    final bool newValue = !_showControls;

    setState(() => _showControls = newValue);
    Utilities.storage.setHeroImageControlsVisible(newValue);
  }
}
