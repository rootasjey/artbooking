import 'package:artbooking/components/bezier_painter.dart';
import 'package:artbooking/types/roadmap_item.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';
import 'package:unicons/unicons.dart';

class HomePageRoadmap extends StatefulWidget {
  const HomePageRoadmap({Key? key}) : super(key: key);

  @override
  _HomePageRoadmapState createState() => _HomePageRoadmapState();
}

class _HomePageRoadmapState extends State<HomePageRoadmap> {
  int _processIndex = 0;

  final List<String> _processes = [
    'Profile page',
    'Book layout',
    'Mobile version',
    'Version 1.0',
    'Challenges',
  ];

  final _processItems = [
    RoadmapItemData(
      title: "Profile page",
      iconData: UniconsLine.user,
      deadline: "January 2022",
      summary: "Display an artist information, artworks, and books.",
    ),
    RoadmapItemData(
      title: "Book layout",
      iconData: UniconsLine.book,
      deadline: "January 2022",
      summary: "Customize a book and how illustration are stacked.",
    ),
    RoadmapItemData(
      title: "Mobile version",
      iconData: UniconsLine.mobile_android,
      deadline: "February 2022",
      summary: "Adapt the app to mobile + build.",
    ),
    RoadmapItemData(
      title: "Version 1.0",
      iconData: UniconsLine.rocket,
      deadline: "March 2022",
      summary: "Release the app to the Web & Mobile with core features.",
    ),
    RoadmapItemData(
      title: "Challenges",
      iconData: UniconsLine.dumbbell,
      deadline: "May 2022",
      summary: "Create challenges.",
    ),
  ];

  final completeColor = Color(0xff5e6172);
  final todoColor = Color(0xffd1d2d7);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0),
      child: Column(
        children: [
          title(),
          subtitle(),
          timeLineContainer(),
        ],
      ),
    );
  }

  Widget title() {
    return Text(
      "roadmap".tr(),
      style: Utilities.fonts.title(
        fontSize: 90.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget subtitle() {
    return Opacity(
      opacity: 0.4,
      child: Text(
        "roadmap_description".tr(),
        style: Utilities.fonts.body(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget timeLineContainer() {
    return SizedBox(
      height: 300.0,
      width: MediaQuery.of(context).size.width,
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          direction: Axis.horizontal,
          connectorTheme: ConnectorThemeData(
            space: 30.0,
            thickness: 5.0,
          ),
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemExtentBuilder: (_, __) =>
              MediaQuery.of(context).size.width / _processes.length,
          oppositeContentsBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Icon(
                _processItems[index].iconData,
                color: getColor(index),
              ),
            );
          },
          contentsBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: InkWell(
                onTap: () {
                  _showMyDialog(
                    title: _processItems[index].title,
                    summary: _processItems[index].summary,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _processItems[index].title,
                        style: Utilities.fonts.body(
                          fontWeight: FontWeight.w700,
                          color: getColor(index),
                        ),
                      ),
                      Opacity(
                        opacity: 0.6,
                        child: Text(
                          _processItems[index].deadline,
                          style: Utilities.fonts.body(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: getColor(index),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          indicatorBuilder: (_, index) {
            var color;
            var child;
            if (index == _processIndex) {
              color = Theme.of(context).primaryColor;
              child = Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              );
            } else if (index < _processIndex) {
              color = completeColor;
              child = Icon(
                Icons.check,
                color: Colors.white,
                size: 15.0,
              );
            } else {
              color = todoColor;
            }

            if (index <= _processIndex) {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(30.0, 30.0),
                    painter: BezierPainter(
                      color: color,
                      drawStart: index > 0,
                      drawEnd: index < _processIndex,
                    ),
                  ),
                  DotIndicator(
                    size: 30.0,
                    color: color,
                    child: child,
                  ),
                ],
              );
            } else {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(15.0, 15.0),
                    painter: BezierPainter(
                      color: color,
                      drawEnd: index < _processes.length - 1,
                    ),
                  ),
                  OutlinedDotIndicator(
                    borderWidth: 4.0,
                    color: color,
                  ),
                ],
              );
            }
          },
          connectorBuilder: (_, index, type) {
            if (index > 0) {
              if (index == _processIndex) {
                final prevColor = getColor(index - 1);
                final color = getColor(index);

                List<Color?> maybeGradientColors;

                if (type == ConnectorType.start) {
                  maybeGradientColors = [
                    Color.lerp(prevColor, color, 0.5),
                    color
                  ];
                } else {
                  maybeGradientColors = [
                    prevColor,
                    Color.lerp(prevColor, color, 0.5)
                  ];
                }

                List<Color> gradientColors = [];

                for (var col in maybeGradientColors) {
                  if (col != null) {
                    gradientColors.add(col);
                  }
                }

                return DecoratedLineConnector(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                  ),
                );
              } else {
                return SolidLineConnector(
                  color: getColor(index),
                );
              }
            } else {
              return null;
            }
          },
          itemCount: _processes.length,
        ),
      ),
    );
  }

  Color getColor(int index) {
    if (index == _processIndex) {
      return Theme.of(context).primaryColor;
    } else if (index < _processIndex) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  Future<void> _showMyDialog({
    required String? title,
    required String? summary,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.colors.clairPink,
          title: Opacity(
            opacity: 0.6,
            child: Text(
              title!.toUpperCase(),
            ),
          ),
          titleTextStyle: Utilities.fonts.body(
            fontSize: 14.0,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: Utilities.fonts.body(
            fontSize: 18.0,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          titlePadding: const EdgeInsets.only(
            top: 24.0,
            left: 24.0,
            right: 24.0,
          ),
          contentPadding: const EdgeInsets.only(top: 12.0),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500.0,
            ),
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Divider(
                    thickness: 2.0,
                    color:
                        Theme.of(context).secondaryHeaderColor.withOpacity(0.4),
                    height: 0.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Opacity(
                      opacity: 0.8,
                      child: Text(summary!),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0.0,
                primary: Colors.black,
                textStyle: Utilities.fonts.body(
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Text("close".tr().toUpperCase()),
              ),
              onPressed: Beamer.of(context).popRoute,
            ),
          ],
        );
      },
    );
  }
}
