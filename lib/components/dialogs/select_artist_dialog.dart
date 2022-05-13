import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// Select one or more artist(s).
class SelectArtistDialog extends StatefulWidget {
  SelectArtistDialog({
    this.autoFocus = false,
    this.onComplete,
    required this.userId,
    this.onValidate,
    this.maxPick = 6,
    this.admin = false,
  });

  final bool autoFocus;

  /// If true, show all approved books in dialog.
  final bool admin;

  /// When the operation complete (illustrations has been added to books).
  final void Function()? onComplete;

  /// Callback containing selected book ids.
  final void Function(List<String>)? onValidate;

  /// Maximum number of illustrations that can be choosen.
  final int maxPick;
  final String userId;

  @override
  _SelectArtistDialogState createState() => _SelectArtistDialogState();
}

class _SelectArtistDialogState extends State<SelectArtistDialog> {
  bool _loading = false;
  bool _hasNext = false;
  bool _loadingMore = false;
  bool _descending = false;

  DocumentSnapshot? _lastDocument;

  final int _limit = 20;
  List<UserFirestore> _artists = [];
  final Map<String, bool> _selectedArtistIds = Map();

  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchArtists();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lastDocument = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _onValidate =
        _loading || _selectedArtistIds.isEmpty ? null : onValidate;

    return ThemedDialog(
      autofocus: widget.autoFocus,
      useRawDialog: true,
      title: Column(
        children: [
          Opacity(
            opacity: 0.8,
            child: Text(
              "artists".tr().toUpperCase(),
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
                "artists_choose_featured".tr(),
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
      textButtonValidation: "artist_select".plural(_selectedArtistIds.length),
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

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 430.0,
        maxWidth: 400.0,
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 24.0),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final artist = _artists.elementAt(index);
                    return artistAvatar(artist);
                  },
                  childCount: _artists.length,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 130.0,
                  mainAxisSpacing: 12.0,
                  crossAxisSpacing: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget artistAvatar(UserFirestore artist) {
    final bool selected = _selectedArtistIds.containsKey(artist.id);
    final size = 80.0;

    return Column(
      children: [
        Material(
          elevation: 4.0,
          clipBehavior: Clip.antiAlias,
          shape: CircleBorder(
            side: BorderSide(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 3.0,
            ),
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Ink.image(
              image: NetworkImage(artist.getProfilePicture()),
              width: size,
              height: size,
              fit: BoxFit.cover,
              child: InkWell(
                onTap: () => onTapArtist(artist),
                child: selected
                    ? Container(
                        color: Constants.colors.tertiary,
                        child: Icon(UniconsLine.check),
                      )
                    : Container(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: InkWell(
            onTap: () => onTapArtist(artist),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Opacity(
                opacity: 0.8,
                child: Text(
                  artist.name,
                  overflow: TextOverflow.ellipsis,
                  style: Utilities.fonts.style(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget footer() {
    final bool selectedEmpty = _selectedArtistIds.isEmpty;
    final Function()? _onValidate =
        _loading || selectedEmpty ? null : onValidate;

    Widget child = Container();

    if (_artists.isEmpty) {
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
                "artist_select_count".plural(
                  _selectedArtistIds.length,
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
      _selectedArtistIds.clear();
    });
  }

  Future fetchArtists() async {
    _artists.clear();
    setState(() => _loading = true);

    try {
      final query = FirebaseFirestore.instance
          .collectionGroup("user_public_fields")
          .where("type", isEqualTo: "base")
          .orderBy("name", descending: _descending)
          .limit(_limit);

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (QueryDocSnapMap document in snapshot.docs) {
        final Json map = document.data();
        final artist = UserFirestore.fromMap(map);
        _artists.add(artist);
      }

      _lastDocument = snapshot.docs.last;
      _hasNext = snapshot.docs.length == _limit;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text("books_fetch_error".tr()));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future fetchMoreArtists() async {
    final lastDocument = _lastDocument;
    if (lastDocument == null || !_hasNext || _loadingMore) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final query = FirebaseFirestore.instance
          .collectionGroup("user_public_fields")
          .where("type", isEqualTo: "base")
          .orderBy("name", descending: _descending)
          .limit(_limit)
          .startAfterDocument(lastDocument);

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (QueryDocSnapMap document in snapshot.docs) {
        final Json map = document.data();
        final artist = UserFirestore.fromMap(map);
        _artists.add(artist);
      }

      _lastDocument = snapshot.docs.last;
      _hasNext = snapshot.docs.length == _limit;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text("books_fetch_more_error".tr()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  bool onScrollNotification(ScrollNotification scrollNotif) {
    if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_loadingMore) {
      fetchMoreArtists();
    }

    return false;
  }

  void onTapArtist(UserFirestore artist) {
    if (_selectedArtistIds.containsKey(artist.id)) {
      _selectedArtistIds.remove(artist.id);
    } else {
      _selectedArtistIds.putIfAbsent(artist.id, () => true);
    }

    setState(() {});
  }

  void onValidate() {
    List<String> artistIds = _selectedArtistIds.keys.toList();

    if (artistIds.length > widget.maxPick) {
      artistIds = artistIds.sublist(0, widget.maxPick);
    }

    widget.onValidate?.call(artistIds);
    Beamer.of(context).popRoute();
  }
}
