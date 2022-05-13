import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class ProfilePageEmpty extends StatelessWidget {
  const ProfilePageEmpty({
    Key? key,
    required this.username,
    this.onCreateProfilePage,
  }) : super(key: key);

  final String username;
  final void Function()? onCreateProfilePage;

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
                  Padding(
                    padding: const EdgeInsets.only(top: 160.0, bottom: 200.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: CircleAvatar(
                            backgroundColor: Constants.colors.clairPink,
                            radius: 80.0,
                            foregroundImage: NetworkImage(
                                "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatars%2Favatar_man_0.png?alt=media&token=2c8edef3-5e6f-4b84-a52b-2c9034951e20"),
                          ),
                        ),
                        Opacity(
                          opacity: 0.6,
                          child: Text.rich(
                            TextSpan(
                              text: "${username} ",
                              style: Utilities.fonts.body(
                                color: Theme.of(context).primaryColor,
                                fontSize: 34.0,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                    text: "has no profile page.",
                                    style: Utilities.fonts.body(
                                      fontSize: 34.0,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.color,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: DarkElevatedButton(
                            onPressed: onCreateProfilePage,
                            child: Text("Create profile page"),
                          ),
                        ),
                      ],
                    ),
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
