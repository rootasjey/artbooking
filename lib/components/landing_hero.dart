import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LandingHero extends StatefulWidget {
  @override
  _LandingHeroState createState() => _LandingHeroState();
}

class _LandingHeroState extends State<LandingHero> {
  Map<int, String> imagesUrls = {
    0: "https://images.unsplash.com/photo-1515261439133-0f6cfb098e04?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80",
    1: "https://images.unsplash.com/photo-1553356084-58ef4a67b2a7?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80",
    2: "https://images.unsplash.com/photo-1529641484336-ef35148bab06?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80",
    3: "https://images.unsplash.com/photo-1477414348463-c0eb7f1359b6?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80",
    4: "https://images.unsplash.com/photo-1521133573892-e44906baee46?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80",
    5: "https://images.unsplash.com/photo-1554189097-ffe88e998a2b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NDl8fGNvbG9yc3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 120.0,
        left: 60.0,
        right: 60.0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          children: [
            title(),
            subtitle(),
            // infoCard(),
            horizontalList(),
            bottomArrow(),
          ],
        ),
      ),
    );
  }

  Widget title() {
    return Text(
      "ArtBooking",
      style: FontsUtils.title(
        fontSize: 90.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget subtitle() {
    return Opacity(
      opacity: 0.6,
      child: Text(
        "Take a deep breath of inspiration",
        style: FontsUtils.mainStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget bottomArrow() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: IconButton(
        onPressed: () {},
        icon: Icon(UniconsLine.arrow_down),
      ),
    );
  }

  Widget infoCard() {
    return Container(
      width: 300.0,
      padding: const EdgeInsets.only(top: 70.0),
      child: Card(
        elevation: 0.0,
        color: Constants.colors.clairPink,
        child: ListTile(
          leading: Icon(UniconsLine.info),
          title: Opacity(
            opacity: 0.6,
            child: Text(
              "We're still in beta",
              style: FontsUtils.mainStyle(),
            ),
          ),
        ),
      ),
    );
  }

  Widget itemCard({
    double width = 120.0,
    height = 120.0,
    Color color = const Color(0xFF3544393),
    String? imageUrl,
  }) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: width,
        height: height,
        color: color,
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
              )
            : Container(),
      ),
    );
  }

  Widget horizontalList() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Wrap(
        spacing: 12.0,
        children: [
          itemCard(imageUrl: imagesUrls[0]),
          itemCard(imageUrl: imagesUrls[1]),
          itemCard(imageUrl: imagesUrls[2]),
          itemCard(imageUrl: imagesUrls[3]),
        ],
      ),
    );
  }
}
