import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/illustration_card.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/types/book.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class MyBookPage extends StatefulWidget {
  final String bookId;
  final Book book;

  const MyBookPage({
    Key key,
    @required @PathParam() this.bookId,
    this.book,
  }) : super(key: key);
  @override
  _MyBookPageState createState() => _MyBookPageState();
}

class _MyBookPageState extends State<MyBookPage> {
  /// The viewing book.
  Book bookPage;

  bool isLoading;
  bool hasError = false;
  bool hasNext = true;
  bool isFabVisible = false;
  bool isLoadingMore = false;
  bool forceMultiSelect = false;

  final illustrations = <Illustration>[];
  final keyboardFocusNode = FocusNode();

  int limit = 20;
  int startIndex = 0;
  int endIndex = 0;

  Map<String, Illustration> multiSelectedItems = Map();
  Map<int, Illustration> processingIllus = Map();

  ScrollController scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    if (widget.book == null) {
      fetchBookAndIllustrations();
    } else {
      bookPage = widget.book;
      fetchIllustrations();
    }
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
              backgroundColor: stateColors.primary,
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
            fetchMoreIllustrations();
          }

          return false;
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
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

  Widget header() {
    final bookName = bookPage != null ? bookPage.name : 'My book';

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Text(
            bookName,
            style: FontsUtils.title(),
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
              textTitle: "loading_illustrations".tr(),
            ),
          ),
        ]),
      );
    }

    if (hasError) {
      return errorView();
    }

    if (illustrations.isEmpty) {
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
              'multi_select'.tr(),
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
            child: Text('sort'.tr()),
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
                    "book_no_illustrations".tr(),
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

  Widget errorView() {
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
                  "issue_unexpected".tr(),
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
                    "issue_data_retry".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: fetchBookAndIllustrations,
                icon: Icon(UniconsLine.refresh),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "retry".tr(),
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
            final illustration = illustrations.elementAt(index);
            final selected = multiSelectedItems.containsKey(illustration.id);

            return IllustrationCard(
              illustration: illustration,
              selected: selected,
              selectionMode: selectionMode,
              type: IllustrationCardType.book,
              onBeforeDelete: () {
                setState(() {
                  illustrations.removeAt(index);
                });
              },
              onAfterDelete: (response) {
                if (response.success) {
                  return;
                }

                setState(() {
                  illustrations.insert(index, illustration);
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
              onRemove: (_) {
                onRemoveFromBook(
                  index: index,
                  illustration: illustration,
                );
              },
            );
          },
          childCount: illustrations.length,
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
          label: Text('clear_selection'.tr()),
        ),
        TextButton.icon(
          onPressed: () {
            illustrations.forEach((illustration) {
              multiSelectedItems.putIfAbsent(
                  illustration.id, () => illustration);
            });

            setState(() {});
          },
          icon: Icon(Icons.select_all),
          label: Text('select_all'.tr()),
        ),
        TextButton.icon(
          onPressed: confirmDeletion,
          style: TextButton.styleFrom(
            primary: Colors.red,
          ),
          icon: Icon(Icons.delete_outline),
          label: Text('delete'.tr()),
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
                    'confirm'.tr(),
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
                  title: Text('Cancel'.tr()),
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
      illustrations.removeWhere((item) => item.id == multiSelectItem.key);
    });

    final duplicatedItems = multiSelectedItems.values.toList();
    final illustrationIds = multiSelectedItems.keys.toList();

    setState(() {
      multiSelectedItems.clear();
      forceMultiSelect = false;
    });

    final response = await BooksActions.removeIllustrations(
      bookId: bookPage.id,
      illustrationIds: illustrationIds,
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "illustrations_delete_error".tr(),
      );

      illustrations.addAll(duplicatedItems);
    }
  }

  void fetchBookAndIllustrations() async {
    await fetchBook();
    fetchIllustrations();
  }

  Future fetchBook() async {
    setState(() {
      isLoading = true;
    });

    try {
      final bookSnap = await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .get();

      if (!bookSnap.exists) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }

      final bookData = bookSnap.data();
      bookData['id'] = bookSnap.id;

      setState(() {
        bookPage = Book.fromJSON(bookData);
        isLoading = false;
      });
    } catch (error) {
      appLogger.e(error);

      setState(() {
        hasError = true;
        isLoading = true;
      });
    }
  }

  void fetchIllustrations() async {
    if (bookPage == null) {
      return;
    }

    final bpIllustrations = bookPage.illustrations;

    setState(() {
      isLoading = true;
      startIndex = 0;
      endIndex =
          bpIllustrations.length >= limit ? limit : bpIllustrations.length;
    });

    try {
      if (bpIllustrations.isEmpty) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final range = bpIllustrations.getRange(startIndex, endIndex);

      for (var bookIllustration in range) {
        final illustrationSnap = await FirebaseFirestore.instance
            .collection('illustrations')
            .doc(bookIllustration.id)
            .get();

        if (!illustrationSnap.exists) {
          continue;
        }

        final illusData = illustrationSnap.data();
        illusData['id'] = illustrationSnap.id;

        final illustration = Illustration.fromJSON(illusData);
        illustrations.add(illustration);
      }

      setState(() {
        isLoading = false;
        hasNext = endIndex < bookPage.count;
      });
    } catch (error) {
      appLogger.e(error);

      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void fetchMoreIllustrations() async {
    if (!hasNext || bookPage == null) {
      return;
    }

    setState(() {
      startIndex = endIndex;
      endIndex = endIndex + limit;
      isLoadingMore = true;
    });

    try {
      final range = bookPage.illustrations.getRange(startIndex, endIndex);

      for (var bookIllustration in range) {
        final illustrationSnap = await FirebaseFirestore.instance
            .collection('illustrations')
            .doc(bookIllustration.id)
            .get();

        if (!illustrationSnap.exists) {
          continue;
        }

        final illusData = illustrationSnap.data();
        illusData['id'] = illustrationSnap.id;

        final illustration = Illustration.fromJSON(illusData);
        illustrations.add(illustration);
      }

      setState(() {
        isLoadingMore = false;
        hasNext = endIndex < bookPage.count;
      });
    } catch (error) {
      appLogger.e(error);

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void onRemoveFromBook({int index, Illustration illustration}) async {
    processingIllus.putIfAbsent(index, () => illustration);
    illustrations.removeAt(index);

    final response = await BooksActions.removeIllustrations(
      bookId: bookPage.id,
      illustrationIds: [illustration.id],
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "illustrations_remove_error".tr(),
      );

      processingIllus.forEach((pIndex, pIllus) {
        illustrations.insert(index, pIllus);
      });

      setState(() {
        processingIllus.clear();
      });

      return;
    }

    Snack.s(
      context: context,
      message: "illustrations_remove_success".tr(),
    );

    setState(() {
      processingIllus.clear();
    });
  }
}
