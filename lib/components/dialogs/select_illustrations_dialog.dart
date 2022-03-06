import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:unicons/unicons.dart';

class SelectIllustrationsDialog extends StatefulWidget {
  const SelectIllustrationsDialog({
    Key? key,
    required this.userId,
    this.autoFocus = false,
    this.onValidate,
    this.maxPick = 6,
  }) : super(key: key);

  /// Maximum number of illustrations someone can choose.
  final int maxPick;

  /// If true, this widget will request focus on load.
  final bool autoFocus;

  /// User's id illustrations.
  final String userId;

  /// Callback containing selected illustration ids.
  final void Function(List<String>)? onValidate;

  @override
  _SelectIllustrationsDialogState createState() =>
      _SelectIllustrationsDialogState();
}

class _SelectIllustrationsDialogState extends State<SelectIllustrationsDialog> {
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasNext = true;

  final List<Illustration> _illustrations = [];
  final Map<String, bool> _selectedIllustrationIds = Map();

  final int _limit = 20;
  DocumentSnapshot? _lastDocument;

  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchPublicIllustrations();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _illustrations.clear();
    _selectedIllustrationIds.clear();
    _lastDocument = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Function()? _onValidate =
        _loading || _selectedIllustrationIds.isEmpty ? null : onValidate;

    return ThemedDialog(
      autofocus: widget.autoFocus,
      useRawDialog: true,
      title: Column(
        children: [
          Opacity(
            opacity: 0.8,
            child: Text(
              "illustrations".tr().toUpperCase(),
              style: Utilities.fonts.style(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Opacity(
              opacity: 0.4,
              child: Text(
                "illustrations_choose_count".plural(
                  widget.maxPick,
                  args: ["${widget.maxPick}"],
                ),
                textAlign: TextAlign.center,
                style: Utilities.fonts.style(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: body(),
      textButtonValidation: "illustrations_select_count".plural(
        _selectedIllustrationIds.length,
      ),
      footer: footer(),
      onCancel: Beamer.of(context).popRoute,
      onValidate: _onValidate,
    );
  }

  Widget body() {
    if (_loading) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  "loading".tr(),
                  style: Utilities.fonts.style(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              LinearProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (_illustrations.isEmpty) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            children: [
              Icon(
                UniconsLine.wind,
                color: Colors.amber.shade600,
                size: 32.0,
              ),
              Opacity(
                opacity: 0.8,
                child: Text(
                  "illustrations_my_empty".tr(),
                  style: Utilities.fonts.style(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Opacity(
                opacity: 0.4,
                child: Text(
                  "illustrations_my_empty_subtitle".tr(),
                  style: Utilities.fonts.style(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 420.0,
        maxWidth: 400.0,
      ),
      child: ImprovedScrolling(
        scrollController: _scrollController,
        enableKeyboardScrolling: true,
        onScroll: onScroll,
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(right: 12.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120.0,
                    mainAxisSpacing: 6.0,
                    crossAxisSpacing: 6.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final illustration = _illustrations.elementAt(index);
                      final selected = _selectedIllustrationIds.containsKey(
                        illustration.id,
                      );

                      return IllustrationCard(
                        heroTag: "",
                        illustration: illustration,
                        index: index,
                        size: 120.0,
                        onTap: () => onTapIllustrationCard(illustration),
                        selected: selected,
                      );
                    },
                    childCount: _illustrations.length,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget footer() {
    final bool selectedEmpty = _selectedIllustrationIds.isEmpty;
    final Function()? _onValidate =
        _loading || selectedEmpty ? null : onValidate;

    Widget child = Container();

    if (_illustrations.isEmpty) {
      child = Padding(
        padding: EdgeInsets.all(12.0),
        child: DarkElevatedButton.large(
          onPressed: Beamer.of(context).popRoute,
          child: Text("close".tr()),
        ),
      );
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: DarkElevatedButton.large(
              onPressed: _onValidate,
              child: Text(
                "illustrations_select_count".plural(
                  _selectedIllustrationIds.length,
                ),
              ),
            ),
          ),
          Tooltip(
            message: "clear_selection".tr(),
            child: DarkElevatedButton.iconOnly(
              color: Theme.of(context).secondaryHeaderColor.withOpacity(0.8),
              onPressed: selectedEmpty ? null : clearSelected,
              child: Icon(UniconsLine.ban),
            ),
          ),
        ],
      );
    }

    return Material(
      color: Constants.colors.clairPink,
      child: child,
    );
  }

  void clearSelected() {
    setState(() {
      _selectedIllustrationIds.clear();
    });
  }

  void onTapIllustrationCard(Illustration illustration) {
    if (_selectedIllustrationIds.length >= widget.maxPick) {
      _selectedIllustrationIds.remove(_selectedIllustrationIds.keys.last);
    }

    if (_selectedIllustrationIds.containsKey(illustration.id)) {
      setState(() {
        _selectedIllustrationIds.remove(illustration.id);
      });
      return;
    }

    setState(() {
      _selectedIllustrationIds.putIfAbsent(illustration.id, () => true);
    });
  }

  void onValidate() {
    List<String> illustrationIds = _selectedIllustrationIds.keys.toList();

    if (illustrationIds.length > widget.maxPick) {
      illustrationIds = illustrationIds.sublist(0, widget.maxPick);
    }

    widget.onValidate?.call(illustrationIds);
    Beamer.of(context).popRoute();
  }

  void fetchPublicIllustrations() async {
    setState(() {
      _loading = true;
      _selectedIllustrationIds.clear();
      _illustrations.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: widget.userId)
          .where("visibility", isEqualTo: "public")
          .orderBy("user_custom_index", descending: true)
          .limit(_limit)
          .get();

      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (var document in snapshot.docs) {
        final data = document.data();
        data["id"] = document.id;
        _illustrations.add(Illustration.fromMap(data));
      }

      _hasNext = snapshot.size == _limit;
      _lastDocument = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  void fetchMorePublicIllustrations() async {
    final lastDocument = _lastDocument;
    if (lastDocument == null || _loadingMore || !_hasNext) {
      return;
    }

    _loadingMore = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: widget.userId)
          .where("visibility", isEqualTo: "public")
          .orderBy("user_custom_index", descending: true)
          .limit(_limit)
          .startAfterDocument(lastDocument)
          .get();

      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (var document in snapshot.docs) {
        final data = document.data();
        data["id"] = document.id;
        _illustrations.add(Illustration.fromMap(data));
      }

      _hasNext = snapshot.size == _limit;
      _lastDocument = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  /// Callback when the page scrolls up and down.
  void onScroll(double scrollOffset) {
    if (_scrollController.position.atEdge &&
        scrollOffset > 50 &&
        _hasNext &&
        !_loadingMore) {
      fetchMorePublicIllustrations();
    }
  }
}
