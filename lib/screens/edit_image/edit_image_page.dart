import 'dart:typed_data';

import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/buttons/elevated_list_tile.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/edit_image/edit_image_page_header.dart';
import 'package:artbooking/types/button_data.dart';
import 'package:artbooking/types/illustration/dimensions.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

/// A widget to edit an image (crop, resize, flip, rotate).
class EditImagePage extends ConsumerStatefulWidget {
  const EditImagePage({
    Key? key,
    required this.dimensions,
    required this.imageToEdit,
    this.onSave,
    this.useNativeLib = false,
    this.heroTag = '',
    this.goToEditIllustrationMetada,
  }) : super(key: key);

  /// Image object. Should be defined is navigating from another page.
  /// It's null when reloading the page for example.
  final ImageProvider<Object> imageToEdit;
  final void Function(Uint8List?)? onSave;
  final bool useNativeLib;
  final Dimensions dimensions;
  final Object heroTag;
  final void Function()? goToEditIllustrationMetada;

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends ConsumerState<EditImagePage> {
  /// If true, the image is being
  bool _isProcessing = false;

  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();

  final List<ButtonData> _actionsDataList = [];

  @override
  void initState() {
    super.initState();

    _actionsDataList.addAll([
      ButtonData(
        textValue: "rotate_left".tr(),
        icon: Icon(UniconsLine.crop_alt_rotate_left),
        onTap: () {
          _editorKey.currentState?.rotate(right: false);
        },
      ),
      ButtonData(
        textValue: "rotate_right".tr(),
        icon: Icon(UniconsLine.crop_alt_rotate_right),
        onTap: () {
          _editorKey.currentState?.rotate(right: true);
        },
      ),
      ButtonData(
        textValue: "flip_h".tr(),
        icon: Icon(UniconsLine.flip_v),
        onTap: () {
          _editorKey.currentState?.flip();
        },
      ),
      ButtonData(
        textValue: "reset".tr(),
        icon: Icon(UniconsLine.history),
        onTap: () {
          _editorKey.currentState?.reset();
        },
      ),
    ]);
  }

  @override
  void dispose() {
    _editorKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      floatingActionButton: fab(isMobileSize: isMobileSize),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, left: 24.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleButton.outlined(
                    onTap: () => Navigator.pop(context),
                    child: Icon(UniconsLine.times),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 200.0),
            sliver: SliverToBoxAdapter(
              child: isMobileSize ? mobileBody(isMobileSize) : desktopBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget desktopBody() {
    final double height = MediaQuery.of(context).size.height;
    final double relativeHeight = height * 60 / 100;
    final double imageWidth = widget.dimensions.getRelativeWidth(
      relativeHeight,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              EditImagePageHeader(
                isProcessing: _isProcessing,
                goToEditIllustrationMetada: widget.goToEditIllustrationMetada,
              ),
              Hero(
                tag: widget.heroTag,
                child: ExtendedImage(
                  width: imageWidth,
                  height: relativeHeight,
                  image: widget.imageToEdit,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.editor,
                  extendedImageEditorKey: _editorKey,
                  initEditorConfigHandler: (state) {
                    return EditorConfig(
                      maxScale: 8.0,
                      cropRectPadding: const EdgeInsets.all(20.0),
                      hitTestSize: 20.0,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: height,
            maxHeight: height,
            maxWidth: 300.0,
          ),
          child: Material(
            elevation: 6.0,
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                        "panel_edit".tr().toUpperCase(),
                        style: Utilities.fonts.body(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(
                  thickness: 2.0,
                  height: 0.0,
                ),
                SizedBox(
                  width: 300.0,
                  height: height - 100.0,
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final buttonData = _actionsDataList.elementAt(index);

                      return ElevatedListTile(
                        onTap: buttonData.onTap,
                        leading: buttonData.icon,
                        titleValue: buttonData.textValue,
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: _actionsDataList.length,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget fab({bool isMobileSize = false}) {
    final Color backgroundColor =
        _isProcessing ? Colors.grey : Theme.of(context).primaryColor;

    if (isMobileSize) {
      return FloatingActionButton(
        onPressed: _isProcessing ? null : validateEdit,
        child: Icon(UniconsLine.save),
        backgroundColor: backgroundColor,
      );
    }

    return FloatingActionButton.extended(
      onPressed: _isProcessing ? null : validateEdit,
      label: Text("save".tr()),
      extendedTextStyle: Utilities.fonts.body(
        fontWeight: FontWeight.w700,
      ),
      icon: Icon(UniconsLine.save),
      backgroundColor: backgroundColor,
      extendedPadding: EdgeInsetsDirectional.all(38.0),
    );
  }

  Widget mobileBody(bool isMobileSize) {
    final double percent = isMobileSize ? 0.5 : 0.6;
    final double height = MediaQuery.of(context).size.height;
    final double relativeHeight = height * percent;
    final double imageWidth = widget.dimensions.getRelativeWidth(
      relativeHeight,
    );

    return Column(
      children: [
        EditImagePageHeader(
          isMobileSize: isMobileSize,
          isProcessing: _isProcessing,
          goToEditIllustrationMetada: widget.goToEditIllustrationMetada,
        ),
        Hero(
          tag: widget.heroTag,
          child: ExtendedImage(
            width: imageWidth,
            height: relativeHeight,
            image: widget.imageToEdit,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.editor,
            extendedImageEditorKey: _editorKey,
            initEditorConfigHandler: (state) {
              return EditorConfig(
                maxScale: 8.0,
                cropRectPadding: const EdgeInsets.all(20.0),
                hitTestSize: 20.0,
              );
            },
          ),
        ),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: _actionsDataList.map((final ButtonData buttonData) {
            return IconButton(
              tooltip: buttonData.textValue,
              onPressed: buttonData.onTap,
              icon: buttonData.icon,
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> validateEdit() async {
    final ExtendedImageEditorState? extendedImageEditorState =
        _editorKey.currentState;

    if (extendedImageEditorState == null) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      Uint8List? fileData;

      if (widget.useNativeLib) {
        fileData = await Utilities.cropEditor.cropImageDataWithNativeLibrary(
          state: extendedImageEditorState,
        );
      } else {
        // Due to cropImageDataWithDartLibrary is time consuming
        // on main thread, it will block showBusyingDialog.
        // Use compute/isolate to avoid blocking UI, but it costs more time.
        // await Future.delayed(Duration(milliseconds: 200));

        // If you don't want to block ui, use compute/isolate, but it costs more time.
        fileData = await Utilities.cropEditor.cropImageDataWithDartLibrary(
          state: extendedImageEditorState,
        );
      }

      // uploadPicture(imageData: fileData!);
      widget.onSave?.call(fileData);
      Beamer.of(context).popRoute();
    } catch (error) {
      Utilities.logger.e(error);
    }
  }
}
