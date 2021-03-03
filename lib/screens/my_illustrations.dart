import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/default_app_bar.dart';
import 'package:artbooking/components/image_item.dart';
import 'package:artbooking/components/full_page_loading.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/screens/signin.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class MyIllustrations extends StatefulWidget {
  @override
  _MyIllustrationsState createState() => _MyIllustrationsState();
}

class _MyIllustrationsState extends State<MyIllustrations> {
  bool isLoading;
  bool descending = true;
  bool hasNext = true;
  bool isFabVisible = false;
  bool isLoadingMore = false;
  bool forceMultiSelect = false;

  DocumentSnapshot lastDoc;

  final illustrationsList = <Illustration>[];
  final keyboardFocusNode = FocusNode();

  int limit = 20;

  Map<String, Illustration> multiSelectedItems = Map();

  ScrollController scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                scrollController.animateTo(
                  0.0,
                  duration: 1.seconds,
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: stateColors.accent,
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          // FAB visibility
          if (scrollNotification.metrics.pixels < 50 && isFabVisible) {
            setState(() {
              isFabVisible = false;
            });
          } else if (scrollNotification.metrics.pixels > 50 && !isFabVisible) {
            setState(() {
              isFabVisible = true;
            });
          }

          if (scrollNotification.metrics.pixels <
              scrollNotification.metrics.maxScrollExtent) {
            return false;
          }

          if (hasNext && !isLoadingMore) {
            fetchMore();
          }

          return false;
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            DefaultAppBar(),
            header(),
            body(),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Text(
            'Illustrations',
            style: FontsUtils.boldTitleStyle(),
          ),
          defaultActionsToolbar(),
          multiSelectToolbar(),
        ]),
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: FullPageLoading(),
          ),
        ]),
      );
    }

    if (illustrationsList.isEmpty) {
      return emptyView();
    }

    return gridView();
  }

  Widget defaultActionsToolbar() {
    if (multiSelectedItems.isNotEmpty) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              forceMultiSelect = !forceMultiSelect;
            });
          },
          icon: Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Icon(UniconsLine.layers_alt),
          ),
          label: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Multi-select',
            ),
          ),
          style: forceMultiSelect
              ? TextButton.styleFrom(primary: Colors.lightGreen)
              : TextButton.styleFrom(),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Icon(UniconsLine.sort),
          ),
          label: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Sort',
            ),
          ),
        ),
      ],
    );
  }

  Widget emptyView() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  "It's lonely there",
                  style: TextStyle(
                    fontSize: 32.0,
                    color: stateColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  // top: 24.0,
                ),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "You haven't upload any illustration yet.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  appUploadManager.pickImage(context);
                },
                icon: Icon(UniconsLine.upload),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Upload",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget gridView() {
    final selectionMode = forceMultiSelect || multiSelectedItems.isNotEmpty;

    return SliverPadding(
      padding: const EdgeInsets.all(40.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final illustration = illustrationsList.elementAt(index);
            final selected = multiSelectedItems.containsKey(illustration.id);

            return ImageItem(
              illustration: illustration,
              selected: selected,
              selectionMode: selectionMode,
              onBeforeDelete: () {
                setState(() {
                  illustrationsList.removeAt(index);
                });
              },
              onAfterDelete: (response) {
                if (response.success) {
                  return;
                }

                setState(() {
                  illustrationsList.insert(index, illustration);
                });
              },
              onBeforePressed: () {
                if (multiSelectedItems.isEmpty && !forceMultiSelect) {
                  return false;
                }

                if (selected) {
                  setState(() {
                    multiSelectedItems.remove(illustration.id);
                    forceMultiSelect = multiSelectedItems.length > 0;
                  });
                } else {
                  setState(() {
                    multiSelectedItems.putIfAbsent(
                        illustration.id, () => illustration);
                  });
                }

                return true;
              },
              onLongPress: (selected) {
                if (selected) {
                  setState(() {
                    multiSelectedItems.remove(illustration.id);
                  });
                  return;
                }

                setState(() {
                  multiSelectedItems.putIfAbsent(
                      illustration.id, () => illustration);
                });
              },
            );
          },
          childCount: illustrationsList.length,
        ),
      ),
    );
  }

  Widget multiSelectToolbar() {
    if (multiSelectedItems.isEmpty) {
      return Container();
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Opacity(
          opacity: 0.6,
          child: Text(
            "${multiSelectedItems.length} selected",
            style: TextStyle(
              fontSize: 30.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 25.0,
            width: 2.0,
            color: Colors.black12,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            setState(() {
              multiSelectedItems.clear();
            });
          },
          icon: Icon(Icons.border_clear),
          label: Text(
            'Clear selection',
          ),
        ),
        TextButton.icon(
          onPressed: () {
            illustrationsList.forEach((illustration) {
              multiSelectedItems.putIfAbsent(
                  illustration.id, () => illustration);
            });

            setState(() {});
          },
          icon: Icon(Icons.select_all),
          label: Text(
            'Select all',
          ),
        ),
        TextButton.icon(
          onPressed: confirmDeletion,
          style: TextButton.styleFrom(
            primary: Colors.red,
          ),
          icon: Icon(Icons.delete_outline),
          label: Text(
            'Delete',
          ),
        ),
      ],
    );
  }

  void confirmDeletion() async {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  tileColor: Color(0xfff55c5c),
                  onTap: () {
                    Navigator.of(context).pop();
                    deleteSelection();
                  },
                ),
                ListTile(
                  title: Text('Cancel'),
                  trailing: Icon(Icons.close),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return RawKeyboardListener(
          autofocus: true,
          focusNode: keyboardFocusNode,
          onKey: (keyEvent) {
            if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter)) {
              Navigator.of(context).pop();
              deleteSelection();
            }
          },
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 500.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 40.0,
                  ),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void deleteSelection() async {
    multiSelectedItems.entries.forEach((multiSelectItem) {
      illustrationsList.removeWhere((item) => item.id == multiSelectItem.key);
    });

    final copyItems = multiSelectedItems.values.toList();
    final imagesIds = multiSelectedItems.keys.toList();

    setState(() {
      multiSelectedItems.clear();
      forceMultiSelect = false;
    });

    final response = await IllustrationsActions.deleteDocs(
      imagesIds: imagesIds,
    );

    if (!response.success) {
      Snack.e(
        context: context,
        message: "Sorry, there was an issue while deleting your illustrations. "
            "Try again or contact us if the issue persists.",
      );

      illustrationsList.addAll(copyItems);
    }
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        debugPrint("User is not authenticated.");

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => Signin()),
          );
        });

        setState(() {
          isLoading = false;
        });
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('illustrations')
          .where('user.id', isEqualTo: userAuth.uid)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
          hasNext = false;
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
        lastDoc = snapshot.docs.last;
        hasNext = snapshot.docs.length == limit;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchMore() async {
    if (!hasNext || lastDoc == null) {
      return;
    }

    isLoadingMore = true;

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        throw Exception("User is not authenticated.");
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('illustrations')
          .where('user.id', isEqualTo: userAuth.uid)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .startAfterDocument(lastDoc)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
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
        lastDoc = snapshot.docs.last;
        hasNext = snapshot.docs.length == limit;
        isLoadingMore = false;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
