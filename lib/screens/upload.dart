import 'package:artbooking/actions/images.dart';
import 'package:artbooking/components/ImageItem.dart';
import 'package:artbooking/components/sliver_appbar_header.dart';
import 'package:artbooking/components/upload_manager.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration.dart';
import 'package:artbooking/types/upload_task.dart';
import 'package:artbooking/utils/converters.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mime_type/mime_type.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  bool isLoading = false;

  ScrollController _scrollController = ScrollController();
  final uploadTasks = <UploadTask>[];
  final doneTasks = <UploadTask>[];

  final files = <String>[];

  ImageVisibility imageVisibility = ImageVisibility.public;

  @override
  initState() {
    super.initState();
    checkUploadQueue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppHeader(),
          headerAndBody(),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              successImagesText(),
            ]),
          ),
          successImagesGrid(),
          emptyView(),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 200.0),
          ),
        ],
      ),
    );
  }

  Widget headerAndBody() {
    return SliverList(
      delegate: SliverChildListDelegate([
        header(),
        uploadsListProgress(),
      ]),
    );
  }

  Widget emptyView() {
    if (uploadTasks.isNotEmpty || doneTasks.isNotEmpty) {
      return SliverPadding(
        padding: EdgeInsets.zero,
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 80.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nothing to show",
                style: TextStyle(
                  fontSize: 26.0,
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "Try uploading an image file to fill up this space",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 80.0,
        left: 80.0,
        bottom: 100.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                'Illustrations',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 20.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Uploads',
                style: TextStyle(
                  fontSize: 80.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          Wrap(
            spacing: 20.0,
            runSpacing: 20.0,
            children: [
              TextButton.icon(
                  onPressed: pickImage,
                  icon: Icon(Icons.upload_outlined),
                  label: Text('Upload more illustrations')),
              TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.clear_all),
                  label: Text('Clear all')),
            ],
          ),
        ],
      ),
    );
  }

  Widget uploadsListProgress() {
    return Padding(
      padding: const EdgeInsets.only(left: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: uploadTasks.map((uploadTask) {
          return Container(
            padding: const EdgeInsets.all(10.0),
            height: 100.0,
            width: 200.0,
            child: Column(
              children: [
                Text(
                  uploadTask.filename,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                uploadProgress(uploadTask),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget uploadProgress(uploadTask) {
    return StreamBuilder<fb.UploadTaskSnapshot>(
      stream: uploadTask.task.future.asStream(),
      builder: (context, snapshot) {
        Widget progressBar = Padding(padding: EdgeInsets.zero);
        final event = snapshot?.data;

        double progressPercent =
            event != null ? event.bytesTransferred / event.totalBytes * 100 : 0;

        if (snapshot.connectionState == ConnectionState.none) {
          progressPercent = 0;
        }

        print('progressPercent: $progressPercent');

        if (progressPercent == 100) {
        } else if (progressPercent > 0) {
          progressBar = LinearProgressIndicator(
            value: progressPercent,
          );
        }

        return Stack(
          children: <Widget>[
            // uploadText(progressPercent),
            progressBar,
          ],
        );
      },
    );
  }

  Widget successImagesGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 80.0,
        vertical: 60.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final doneTask = doneTasks.elementAt(index);
            final illustration = doneTask.illustration;

            return ImageItem(
              illustration: illustration,
              onBeforeDelete: () {
                setState(() {
                  doneTasks.removeAt(index);
                });
              },
              onAfterDelete: (response) {
                if (response.success) {
                  return;
                }

                setState(() {
                  doneTasks.insert(index, doneTask);
                });
              },
            );
          },
          childCount: doneTasks.length,
        ),
      ),
    );
  }

  Widget successImagesText() {
    if (doneTasks.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 80.0,
        top: 20.0,
        bottom: 10.0,
      ),
      child: Wrap(
        spacing: 10.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(Icons.check, size: 28.0),
          Opacity(
            opacity: 0.6,
            child: Text(
              "You've successfully uploaded ${doneTasks.length} illustrations",
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget metaData() {
    return SizedBox(
      width: 300.0,
      child: Column(
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 300.0,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 40.0,
            ),
            child: TextField(
              maxLines: null,
              autofocus: true,
              // focusNode: nameFocusNode,
              // controller: nameController,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (newValue) {},
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: stateColors.primary,
                  width: 2.0,
                )),
              ),
            ),
          ),
          CheckboxListTile(
            title: Text('is Private?'),
            subtitle: Text(
                'If true, only you will be able to view this illustration'),
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  /// A "select file/folder" window will appear. User will have to choose a file.
  /// This file will be then read, and uploaded to firebase storage;
  void pickImage() async {
    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (pickerResult == null) {
      return;
    }

    uploadImage(pickerResult.files.first);
  }

  /// Upload file to firebase storage
  /// and updates [_uploadTask] to the latest file upload
  void uploadImage(PlatformFile imageFile) async {
    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        throw Exception("User is not authenticated.");
      }

      setState(() {
        isLoading = true;
      });

      final result = await createImageDocument(
        name: imageFile.name,
        visibility: imageVisibility,
      );

      if (!result.success) {
        showSnack(
          context: context,
          message: "There was an issue while uploading your image.",
        );

        setState(() {
          isLoading = false;
        });

        return;
      }

      final filePath = "users/${userAuth.uid}/images/${result.id}" +
          "/original.${imageFile.extension}";

      final storage = fb.storage();
      final fileRef = storage.ref(filePath);

      final task = fileRef.put(
        imageFile.bytes,
        fb.UploadMetadata(
          contentType: mimeFromExtension(imageFile.extension),
          customMetadata: {
            'extension': imageFile.extension,
            'firestoreId': result.id,
            'userId': userAuth.uid,
            'visibility': imageVisibilityToString(imageVisibility),
          },
        ),
      );

      final uploadTask = UploadTask(
        filename: imageFile.name,
        task: task,
      );

      setState(() {
        uploadTasks.add(uploadTask);
      });

      task.future.asStream().listen((uploadTaskSnapshot) {}, onDone: () async {
        final doc = await FirebaseFirestore.instance
            .collection('images')
            .doc(result.id)
            .get();

        final data = doc.data();
        if (data == null) {
          return;
        }

        data['id'] = doc.id;
        uploadTask.illustration = Illustration.fromJSON(data);

        final uri = await task.snapshot.ref.getDownloadURL();
        uploadTask.illustration.urls.original = uri.toString();

        setState(() {
          uploadTasks.remove(uploadTask);
          doneTasks.add(uploadTask);
          isLoading = uploadTasks.isNotEmpty;
        });
      }, onError: (error) {
        debugPrint(error.toString());
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void checkUploadQueue() {
    if (appUploadManager.selectedFiles.isEmpty) {
      return;
    }

    uploadImage(appUploadManager.selectedFiles.first);
  }
}
