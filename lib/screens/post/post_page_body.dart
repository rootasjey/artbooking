import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/types/post.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class PostPageBody extends StatelessWidget {
  const PostPageBody({
    Key? key,
    required this.document,
    required this.documentEditor,
    required this.post,
    this.canManagePosts = false,
    this.isMobileSize = false,
    this.loading = false,
  }) : super(key: key);

  /// The current authenticated user can edit & delete this post if true.
  final bool canManagePosts;

  /// True if this post is being loaded.
  final bool loading;

  /// The UI adapts to small screen size if true.
  final bool isMobileSize;

  /// Post's content.
  final Document document;

  /// Visible if the authenticated user has the right to edit this post.
  final DocumentEditor documentEditor;

  /// Main data of this page.
  /// A post about a subject.
  final Post post;

  @override
  Widget build(BuildContext context) {
    if (post.content.isEmpty) {
      return SliverToBoxAdapter();
    }

    if (loading) {
      return LoadingView(
        title: Text(
          "loading".tr(),
        ),
      );
    }

    if (!canManagePosts) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isMobileSize ? 0.0 : 56.0,
            horizontal: isMobileSize ? 12.0 : 24.0,
          ),
          child: SingleColumnDocumentLayout(
            presenter: SingleColumnLayoutPresenter(
              document: document,
              componentBuilders: defaultComponentBuilders,
              pipeline: [
                SingleColumnStylesheetStyler(stylesheet: defaultStylesheet),
              ],
            ),
            componentBuilders: defaultComponentBuilders,
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SuperEditor(
        editor: documentEditor,
        stylesheet: defaultStylesheet.copyWith(
          documentPadding: EdgeInsets.symmetric(
            vertical: isMobileSize ? 0.0 : 56.0,
            horizontal: isMobileSize ? 0.0 : 24.0,
          ),
        ),
      ),
    );
  }
}
