import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SettingsPageEmpty extends StatelessWidget {
  const SettingsPageEmpty({
    Key? key,
    this.scrollController,
  }) : super(key: key);

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Icon(
                    UniconsLine.trees,
                    size: 54.0,
                  ),
                  Text("Nothing to show here."),
                  Text("Since you're not connected, we have no settings "
                      "to show to you at the moment."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
