import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page.dart';
import 'package:artbooking/screens/illustrations/illustration_page_body.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/illustrations/illustration_page_fab.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class IllustrationPage extends ConsumerStatefulWidget {
  /// Illustration's id, used if direct navigation by url.
  final String illustrationId;

  /// True if navigating from dashboard.
  final bool? fromDashboard;

  const IllustrationPage({
    Key? key,
    required this.illustrationId,
    this.fromDashboard = false,
  }) : super(key: key);

  @override
  _IllustrationPageState createState() => _IllustrationPageState();
}

class _IllustrationPageState extends ConsumerState<IllustrationPage> {
  /// True if data is being loaded.
  bool _isLoading = false;
  var _illustration = Illustration.empty();

  @override
  void initState() {
    super.initState();
    final Illustration? illustrationFromNav =
        NavigationStateHelper.illustration;

    if (illustrationFromNav != null &&
        illustrationFromNav.id == widget.illustrationId) {
      _illustration = illustrationFromNav;
    } else {
      fetchIllustration();
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserFirestore? userFirestore =
        ref.watch(AppState.userProvider).firestoreUser;

    final bool isOwner = userFirestore?.id == _illustration.author.id;

    return HeroControllerScope(
      controller: HeroController(),
      child: Scaffold(
        floatingActionButton: IllustrationPageFab(
          isVisible: isOwner,
          onEdit: onEdit,
        ),
        body: Stack(
          children: [
            NotificationListener(
              child: CustomScrollView(
                slivers: [
                  SliverEdgePadding(),
                  ApplicationBar(),
                  IllustrationPageBody(
                    isLoading: _isLoading,
                    illustration: _illustration,
                    onEdit: onEdit,
                    onLike: onLike,
                    onShare: onShare,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fetchIllustration({bool silent = false}) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = !silent;
    });

    try {
      final illusSnap = await FirebaseFirestore.instance
          .collection('illustrations')
          .doc(widget.illustrationId)
          .get();

      final illusData = illusSnap.data();

      if (!illusSnap.exists || illusData == null) {
        context.showErrorBar(
          content: Text(
            "The illustration with the id ${widget.illustrationId} doesn't exist.",
          ),
        );

        return;
      }

      illusData['id'] = illusSnap.id;

      setState(() {
        _illustration = Illustration.fromJSON(illusData);
        _isLoading = false;
      });
    } catch (error) {
      Utilities.logger.e(error);

      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void onEdit() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => EditIllustrationPage(
        illustration: _illustration,
      ),
    );

    fetchIllustration(silent: true);
  }

  void onLike() async {}

  void onShare() async {}
}
