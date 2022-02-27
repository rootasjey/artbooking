import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:flutter/material.dart';

class ProfilePageError extends StatelessWidget {
  const ProfilePageError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              ApplicationBar(),
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Text(
                    "We're sorry. There was an error while loading this profile page."
                    " Please try reloading.",
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
