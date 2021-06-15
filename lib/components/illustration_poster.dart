import 'package:artbooking/types/illustration/illustration.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class IllustrationPoster extends StatefulWidget {
  final Illustration illustration;

  const IllustrationPoster({
    Key key,
    @required this.illustration,
  }) : super(key: key);

  @override
  _IllustrationPosterState createState() => _IllustrationPosterState();
}

class _IllustrationPosterState extends State<IllustrationPoster> {
  double _elevation = 4.0;
  String _networkImageUrl = '';

  @override
  initState() {
    super.initState();
    _networkImageUrl = widget.illustration.getThumbnail();
    delayedFetchHDImage();
  }

  @override
  Widget build(BuildContext context) {
    final illustration = widget.illustration;

    return Hero(
      tag: illustration.id,
      child: Card(
        elevation: _elevation,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Ink.image(
          image: NetworkImage(
            _networkImageUrl,
          ),
          fit: BoxFit.cover,
          child: InkWell(
            onHover: (isHit) {
              if (isHit) {
                setState(() {
                  _elevation = 6.0;
                });

                return;
              }

              setState(() {
                _elevation = 4.0;
              });
            },
            onTap: () {},
          ),
        ),
      ),
    );
  }

  void delayedFetchHDImage() {
    Future.delayed(
      1.seconds,
      () {
        setState(() {
          _networkImageUrl = widget.illustration.getHDThumbnail();
        });
      },
    );
  }
}
