import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class LandingCurated extends StatefulWidget {
  const LandingCurated({Key? key}) : super(key: key);

  @override
  _LandingCuratedState createState() => _LandingCuratedState();
}

class _LandingCuratedState extends State<LandingCurated> {
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
    return Column(
      children: [
        Text(
          "Curated",
          style: FontsUtils.title(
            fontSize: 80.0,
            height: 1.0,
          ),
        ),
        Opacity(
          opacity: 0.6,
          child: Text(
            "Lastest handpicked illustrations.",
            style: FontsUtils.mainStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 1400.0,
          width: 800.0,
          padding: const EdgeInsets.only(
            top: 60.0,
          ),
          child: WaterfallFlow.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            children: [
              itemCard(imageUrl: imagesUrls[0]),
              itemCard(height: 600.0, imageUrl: imagesUrls[1]),
              itemCard(height: 600.0, imageUrl: imagesUrls[2]),
              itemCard(imageUrl: imagesUrls[3]),
              itemCard(imageUrl: imagesUrls[4]),
              itemCard(imageUrl: imagesUrls[5]),
            ],
          ),
        ),
      ],
    );
  }

  Widget itemCard({
    double width = 300.0,
    height = 300.0,
    Color color = const Color(0xFF3544393),
    String? imageUrl,
  }) {
    return Card(
      elevation: 0.0,
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
}
