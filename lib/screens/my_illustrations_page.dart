import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/illustration_card.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/screens/illustration_page.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPage extends StatefulWidget {
  @override
  _MyIllustrationsPageState createState() => _MyIllustrationsPageState();
}

class _MyIllustrationsPageState extends State<MyIllustrationsPage> {
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
      floatingActionButton: fab(),
      body: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            SliverEdgePadding(),
            MainAppBar(),
            header(),
            body(),
            SliverPadding(
              padding: const EdgeInsets.only(
                bottom: 100.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fab() {
    if (!isFabVisible) {
      return FloatingActionButton(
        onPressed: fetch,
        backgroundColor: stateColors.primary,
        foregroundColor: Colors.white,
        child: Icon(UniconsLine.refresh),
      );
    }

    return FloatingActionButton(
      onPressed: () {
        scrollController.animateTo(
          0.0,
          duration: 1.seconds,
          curve: Curves.easeOut,
        );
      },
      backgroundColor: stateColors.primary,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }

  Widget header() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 50.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                'illustrations'.tr().toUpperCase(),
                style: FontsUtils.mainStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
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
            child: AnimatedAppIcon(
              textTitle: "illustrations_loading".tr(),
            ),
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

    final buttonColor = Colors.black38;

    final multiSelectColor =
        forceMultiSelect ? stateColors.primary : buttonColor;

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
          icon: Icon(UniconsLine.layers_alt),
          label: Text("multi_select".tr()),
          style: OutlinedButton.styleFrom(
            primary: multiSelectColor,
            shape: RoundedRectangleBorder(),
            textStyle: FontsUtils.mainStyle(
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              width: 2.0,
              color: buttonColor.withOpacity(0.2),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 28.0,
              vertical: 18.0,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(UniconsLine.sort),
          label: Text("sort".tr()),
          style: OutlinedButton.styleFrom(
            primary: Colors.black38,
            shape: RoundedRectangleBorder(),
            textStyle: FontsUtils.mainStyle(
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              width: 2.0,
              color: buttonColor.withOpacity(0.2),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 28.0,
              vertical: 18.0,
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
                  "lonely_there".tr(),
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
                    "illustrations_no_upload".tr(),
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
                    "upload".tr(),
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

            return IllustrationCard(
              illustration: illustration,
              selected: selected,
              selectionMode: selectionMode,
              onTap: () => onTapIllustrationCard(illustration),
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
            "multi_items_selected"
                .tr(args: [multiSelectedItems.length.toString()]),
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
          label: Text("clear_selection".tr()),
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
          label: Text("select_all".tr()),
        ),
        TextButton.icon(
          onPressed: confirmDeletion,
          style: TextButton.styleFrom(
            primary: Colors.red,
          ),
          icon: Icon(Icons.delete_outline),
          label: Text("delete".tr()),
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
                    "confirm".tr(),
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
                  title: Text("cancel".tr()),
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

    final duplicatedItems = multiSelectedItems.values.toList();
    final illustrationIds = multiSelectedItems.keys.toList();

    setState(() {
      multiSelectedItems.clear();
      forceMultiSelect = false;
    });

    final response = await IllustrationsActions.deleteMany(
      illustrationIds: illustrationIds,
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "illustrations_delete_error".tr(),
      );

      illustrationsList.addAll(duplicatedItems);
    }
  }

  void fetch() async {
    setState(() {
      isLoading = true;
      illustrationsList.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('illustrations')
          .where('user.id', isEqualTo: stateUser.userAuth.uid)
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
      appLogger.e(error);

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
      appLogger.e(error);
    }
  }

  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && isFabVisible) {
      setState(() {
        isFabVisible = false;
      });
    } else if (notification.metrics.pixels > 50 && !isFabVisible) {
      setState(() {
        isFabVisible = true;
      });
    }

    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (hasNext && !isLoadingMore) {
      fetchMore();
    }

    return false;
  }

  void onTapIllustrationCard(Illustration illustration) {
    if (multiSelectedItems.isEmpty && !forceMultiSelect) {
      navigateToIllustrationPage(illustration);
      return;
    }

    multiSelectIllustration(illustration);
  }

  void navigateToIllustrationPage(Illustration illustration) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return IllustrationPage(
            illustration: illustration,
            illustrationId: illustration.id,
            fromDashboard: true,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );

    /// NOTE: Use auto router when issue #418 is resolved
    /// https://github.com/Milad-Akarie/auto_route_library/issues/418
    ///
    // context.router.push(
    //   DashIllustrationPage(
    //     illustrationId: illustration.id,
    //     illustration: illustration,
    //   ),
    // );
  }

  void multiSelectIllustration(Illustration illustration) {
    final selected = multiSelectedItems.containsKey(illustration.id);

    if (selected) {
      setState(() {
        multiSelectedItems.remove(illustration.id);
        forceMultiSelect = multiSelectedItems.length > 0;
      });

      return;
    }

    setState(() {
      multiSelectedItems.putIfAbsent(illustration.id, () => illustration);
    });
  }
}
