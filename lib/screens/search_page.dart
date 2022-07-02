import 'dart:async';

import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/globals/utilities/search_utilities.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isFabVisible = false;
  bool _isSearchingPosts = false;
  bool _isSearchingProjects = false;

  final _illustrationsSuggestions = <Illustration>[];

  int _limit = 30;

  FocusNode? _searchFocusNode;
  ScrollController? _scrollController;

  String _searchInputValue = '';

  TextEditingController? _searchInputController;

  Timer? _searchTimer;

  @override
  initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchInputController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  dispose() {
    _searchFocusNode!.dispose();
    _scrollController!.dispose();
    _searchInputController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                _scrollController!.animateTo(
                  0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: body(),
    );
  }

  Widget body() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollNotif) {
        // FAB visibility
        if (scrollNotif.metrics.pixels < 50 && _isFabVisible) {
          setState(() {
            _isFabVisible = false;
          });
        } else if (scrollNotif.metrics.pixels > 50 && !_isFabVisible) {
          setState(() {
            _isFabVisible = true;
          });
        }

        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          ApplicationBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 100.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                searchHeader(),
                illustrationsSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget illustrationsSection() {
    if (_searchInputValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final dataView =
        _illustrationsSuggestions.isEmpty ? emptyView('posts') : postsColumn();

    return Padding(
      padding: const EdgeInsets.only(
        top: 40.0,
        bottom: 28.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection(
            text: '${_illustrationsSuggestions.length} posts',
          ),
          dataView,
        ],
      ),
    );
  }

  Widget postsColumn() {
    return Column(
      children: _illustrationsSuggestions.mapIndexed((index, illustration) {
        return IllustrationCard(
          borderRadius: BorderRadius.circular(16.0),
          index: index,
          heroTag: illustration.id,
          illustration: illustration,
        );
      }).toList(),
    );
  }

  Widget titleSection({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 26.0,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget emptyView(String subject) {
    return Opacity(
      opacity: 0.6,
      child: Text(
        'No $subject found for "$_searchInputValue"',
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget errorView(String subject) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Opacity(
          opacity: 0.6,
          child: Text(
            'There was an issue while searching $subject '
            'for "$_searchInputValue". You can try again.',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: searchIllustrations,
          icon: Icon(UniconsLine.refresh),
          label: Text("retry".tr()),
        ),
      ]),
    );
  }

  Widget searchActions() {
    return Wrap(spacing: 20.0, runSpacing: 20.0, children: [
      OutlinedButton.icon(
        onPressed: () {
          _searchInputValue = '';
          _searchInputController!.clear();
          _searchFocusNode!.requestFocus();

          setState(() {});
        },
        icon: Opacity(opacity: 0.6, child: Icon(Icons.clear)),
        label: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Opacity(
            opacity: 0.6,
            child: Text("clear_content".tr()),
          ),
        ),
      ),
    ]);
  }

  Widget searchHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 100.0,
        bottom: 50.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchInput(),
          searchActions(),
          searchResultsData(),
        ],
      ),
    );
  }

  Widget searchInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        children: [
          TextField(
            maxLines: null,
            autofocus: true,
            focusNode: _searchFocusNode,
            controller: _searchInputController,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (newValue) {
              final refresh = _searchInputValue != newValue && newValue.isEmpty;

              _searchInputValue = newValue;

              if (newValue.isEmpty) {
                if (refresh) {
                  setState(() {});
                }
                return;
              }

              if (_searchTimer != null) {
                _searchTimer!.cancel();
              }

              _searchTimer = Timer(
                500.milliseconds,
                () => search(),
              );
            },
            style: TextStyle(
              fontSize: 36.0,
            ),
            decoration: InputDecoration(
              icon: Icon(Icons.search),
              hintText: "search_hint_text".tr(),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
          if (_isSearchingPosts || _isSearchingProjects)
            LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget searchResultsData() {
    if (_searchInputValue.isEmpty) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Opacity(
        opacity: 0.6,
        child: Column(
          children: <Widget>[
            Text(
              "${_illustrationsSuggestions.length} results in total",
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),
            SizedBox(
              width: 200.0,
              child: Divider(
                thickness: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future search() async {
    searchIllustrations();
  }

  void searchIllustrations() async {
    setState(() {
      _isSearchingPosts = true;
      _illustrationsSuggestions.clear();
    });

    try {
      final query = SearchUtilities.algolia
          .index("illustrations")
          .query(_searchInputValue)
          .setHitsPerPage(_limit)
          .setPage(0);

      final snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() => _isSearchingPosts = false);
        return;
      }

      for (final hit in snapshot.hits) {
        final data = hit.data;
        data['id'] = hit.objectID;

        final post = Illustration.fromMap(data);
        _illustrationsSuggestions.add(post);
      }

      setState(() => _isSearchingPosts = false);
    } catch (error) {
      Utilities.logger.e(error);
      setState(() => _isSearchingPosts = false);
    }
  }

  void copyLink(Illustration illustration) async {
    final url = '${Constants.links.baseIllustrationLink}{illustration.id}';

    await Clipboard.setData(ClipboardData(text: url));
    context.showSuccessBar(content: Text("copy_link_success".tr()));
  }

  void sharePost(Illustration illustration) {
    if (kIsWeb) {
      sharePostWeb(illustration);
      return;
    }

    sharePostMobile(illustration);
  }

  void sharePostWeb(Illustration illustration) async {
    String? sharingText = illustration.name;
    final url = '${Constants.links.baseIllustrationLink}${illustration.id}';
    final hashtags = '&hashtags=artbooking';

    await launchUrl(
      Uri.parse(
          "${Constants.links.baseTwitterShareLink}$sharingText$hashtags&url=$url"),
    );
  }

  void sharePostMobile(Illustration illustration) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    String sharingText = illustration.name;
    final url = '${Constants.links.baseIllustrationLink}${illustration.id}';

    sharingText += ' - URL: $url';

    Share.share(
      sharingText,
      subject: 'rootasjey',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }
}
