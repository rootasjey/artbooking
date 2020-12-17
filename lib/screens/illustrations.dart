import 'package:artbooking/components/sliver_appbar_header.dart';
import 'package:artbooking/types/illustration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Illustrations extends StatefulWidget {
  @override
  _IllustrationsState createState() => _IllustrationsState();
}

class _IllustrationsState extends State<Illustrations> {
  bool isLoading;
  final illustrationsList = <Illustration>[];

  @override
  initState() {
    super.initState();

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppHeader(),

          SliverGrid.extent(
            maxCrossAxisExtent: 300.0,
          ),

          SliverPadding(
            padding: const EdgeInsets.all(40.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300.0,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final illu = illustrationsList.elementAt(index);

                  return SizedBox(
                    width: 350.0,
                    height: 350.0,
                    child: Card(
                      elevation: 4.0,
                      child: Ink.image(
                        image: NetworkImage(illu.urls.original),
                        fit: BoxFit.cover,
                        child: InkWell(
                          onTap: () {},
                        ),
                      ),
                    ),
                  );
                },
                childCount: illustrationsList.length,
              ),
            ),
          ),

          // GridView.builder(
          //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          //     maxCrossAxisExtent: 300.0,
          //   ),
          //   itemBuilder: (context, index) {
          //     final illu = illustrationsList.elementAt(index);

          //     return SizedBox(
          //       width: 300.0,
          //       height: 300.0,
          //       child: Card(
          //         child: Ink.image(
          //           image: NetworkImage(illu.urls.original),
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //     );
          //   },
          //   itemCount: illustrationsList.length,
          // ),
        ],
      ),
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        throw Exception("User is not authenticated.");
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('illustrations')
          .where('author.id', isEqualTo: userAuth.uid)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        illustrationsList.add(Illustration.fromJSON(data));
      });

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }
}
