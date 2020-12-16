import 'dart:html';

import 'package:artbooking/components/sliver_appbar_header.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user_state.dart';
import 'package:artbooking/types/uploaded_item.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mobx/mobx.dart';

class OnlineItem {
  String name;
  double size;
  fb.StorageReference element;
  bool isExpanded;
  Uri imageUrl;

  OnlineItem({
    this.element,
    this.imageUrl,
    this.isExpanded = false,
    this.name,
    this.size,
  });
}

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  ScrollController _scrollController = ScrollController();
  final uploadTasks = <UploadedItem>[];

  bool isUploading = false;
  bool isUploadCompleted = false;
  final files = <String>[];

  final onlineItems = <OnlineItem>[];

  @override
  initState() {
    super.initState();
    // fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppHeader(),
          bodyListContent(),
        ],
      ),
    );
  }

  Widget bodyListContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(padding: const EdgeInsets.only(top: 180.0)),
        Center(
          child: uploadContainer(),
        ),
        Container(
          padding: const EdgeInsets.only(
            top: 100.0,
            left: 240.0,
            right: 240.0,
          ),
          width: 300.0,
          child: uploadedFilesList(),
        ),
        Container(
          padding: const EdgeInsets.only(
            top: 100.0,
            left: 240.0,
            right: 240.0,
          ),
          width: 300.0,
          child: onlineFilesList(),
        ),
        Padding(padding: const EdgeInsets.only(top: 200.0)),
      ]),
    );
  }

  Widget uploadContainer() {
    return SizedBox(
      width: 600.0,
      height: 180.0,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        child: InkWell(
          onTap: () {
            uploadImage();
          },
          child: uploadProgress(),
        ),
      ),
    );
  }

  Widget uploadProgress() {
    return StreamBuilder<fb.UploadTaskSnapshot>(
      stream:
          uploadTasks.length > 0 ? uploadTasks.first.task.onStateChanged : null,
      builder: (context, snapshot) {
        Widget progressBar = Padding(padding: EdgeInsets.zero);

        final event = snapshot?.data;

        double progressPercent =
            event != null ? event.bytesTransferred / event.totalBytes * 100 : 0;

        if (snapshot.connectionState == ConnectionState.none) {
          progressPercent = 0;
        }

        if (progressPercent == 100) {
          isUploadCompleted = true;
          isUploading = false;
        } else if (progressPercent > 0) {
          progressBar = Positioned(
            bottom: 20.0,
            left: 0.0,
            width: 600.0,
            child: LinearProgressIndicator(
              value: progressPercent,
            ),
          );
        }

        return Stack(
          children: <Widget>[
            uploadText(progressPercent),
            progressBar,
          ],
        );
      },
    );
  }

  Widget uploadedFilesList() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        final item = uploadTasks.elementAt(index);

        setState(() {
          item.isExpanded = !isExpanded;
        });

        if (item.isExpanded && item.imageUrl == null) {
          item.task.snapshot.ref.getDownloadURL().then((uri) {
            setState(() {
              item.imageUrl = uri;
            });
          });
        }
      },
      children: uploadTasks.map<ExpansionPanel>((uploadedItem) {
        final snapshot = uploadedItem.task.snapshot;

        return ExpansionPanel(
          isExpanded: uploadedItem.isExpanded,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              onTap: () {
                setState(() {
                  uploadedItem.isExpanded = !uploadedItem.isExpanded;
                });

                if (uploadedItem.isExpanded && uploadedItem.imageUrl == null) {
                  uploadedItem.task.snapshot.ref.getDownloadURL().then((uri) {
                    setState(() {
                      uploadedItem.imageUrl = uri;
                    });
                  });
                }
              },
              title: Text(
                snapshot.ref.name,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${snapshot.totalBytes / 1000} Ko',
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete,
                ),
                onPressed: () async {
                  try {
                    await uploadedItem.task.snapshot.ref.delete();
                    setState(() {
                      uploadTasks.remove(uploadedItem);
                    });
                  } catch (error) {
                    debugPrint(error);
                  }
                },
              ),
            );
          },
          body: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: SizedBox(
                    width: 300.0,
                    height: 300.0,
                    child: Card(
                      elevation: 2.0,
                      child: Image.network(
                        uploadedItem.imageUrl != null
                            ? uploadedItem.imageUrl.toString()
                            : '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                metaData(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget onlineFilesList() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        final item = onlineItems.elementAt(index);

        setState(() {
          item.isExpanded = !isExpanded;
        });

        if (item.isExpanded && item.imageUrl == null) {
          item.element.getDownloadURL().then((uri) {
            setState(() {
              item.imageUrl = uri;
            });
          });
        }
      },
      children: onlineItems.map<ExpansionPanel>((onlineItem) {
        return ExpansionPanel(
          isExpanded: onlineItem.isExpanded,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              onTap: () {
                setState(() {
                  onlineItem.isExpanded = !onlineItem.isExpanded;
                });

                if (onlineItem.isExpanded && onlineItem.imageUrl == null) {
                  onlineItem.element.getDownloadURL().then((uri) {
                    setState(() {
                      onlineItem.imageUrl = uri;
                    });
                  });
                }
              },
              title: Text(
                onlineItem.name,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${onlineItem.size} Ko',
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete,
                ),
                onPressed: () async {
                  try {
                    // await onlineItem.task.snapshot.ref.delete();
                    // setState(() {
                    //   uploadTasks.remove(onlineItem);
                    // });

                  } catch (error) {
                    debugPrint(error);
                  }
                },
              ),
            );
          },
          body: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: SizedBox(
                    width: 300.0,
                    height: 300.0,
                    child: Card(
                      elevation: 2.0,
                      child: Image.network(
                        onlineItem.imageUrl != null
                            ? onlineItem.imageUrl.toString()
                            : '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                metaData(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget uploadText(double progressPercent) {
    if (progressPercent == 0) {
      return Positioned.fill(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.add,
              size: 40.0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Opacity(
                opacity: .7,
                child: Text(
                  'Upload new illustrations',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (progressPercent > 0 && progressPercent < 100) {
      return Positioned.fill(
        child: Column(
          children: <Widget>[
            Text(
              uploadTasks.length > 1
                  ? 'Uploading ${uploadTasks.length} files'
                  : 'Uploading ${uploadTasks.first.task.snapshot.ref.name}',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      );
    }

    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            uploadTasks.length > 1
                ? 'Uploaded ${uploadTasks.length} files'
                : 'Uploaded ${uploadTasks.first.task.snapshot.ref.name}',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Icon(
              Icons.check_circle_outline,
              color: stateColors.primary,
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

  void fetch() {
    // print('fetch?');
    autorun((reaction) async {
      final username = userState.username;
      // print('username: $username');

      if (username == null || username.isEmpty) {
        return;
      }

      try {
        // print('try...');
        final storage = fb.storage();
        final illustrationsRef = storage.ref('users/$username/illustrations/');
        final paths = await illustrationsRef.listAll();
        // print('paths.items.length: ${paths.items.length}');

        paths.items.forEach((element) async {
          // print(element.name);
          final metadata = await element.getMetadata();

          onlineItems.add(OnlineItem(
            name: element.name,
            size: metadata.size / 1000,
            element: element,
          ));
        });
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }

  /// A "select file/folder" window will appear. User will have to choose a file.
  /// This file will be then read, and uploaded to firebase storage;
  uploadImage() async {
    // HTML input element
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen(
      (changeEvent) {
        final file = uploadInput.files.first;

        if (!file.name.contains(
            RegExp(r'^([a-zA-Z0-9\s_\.\-\(\):])*.(?:jpg|jpeg|png|gif)$'))) {
          showSnack(
            context: context,
            message:
                'Please provide an image extension to your file before uploading.',
            type: SnackType.error,
          );

          return;
        }

        final reader = FileReader();
        // The FileReader object lets web applications asynchronously read the
        // contents of files (or raw data buffers) stored on the user's computer,
        // using File or Blob objects to specify the file or data to read.
        // Source: https://developer.mozilla.org/en-US/docs/Web/API/FileReader

        reader.readAsDataUrl(file);
        // The readAsDataURL method is used to read the contents of the specified Blob or File.
        //  When the read operation is finished, the readyState becomes DONE, and the loadend is
        // triggered. At that time, the result attribute contains the data as a data: URL representing
        // the file's data as a base64 encoded string.
        // Source: https://developer.mozilla.org/en-US/docs/Web/API/FileReader/readAsDataURL

        reader.onLoadEnd.listen(
          // After file finiesh reading and loading, it will be uploaded to firebase storage
          (loadEndEvent) async {
            uploadToFirebase(file);
          },
        );
      },
    );
  }

  /// Upload file to firebase storage and updates [_uploadTask] to the latest
  /// file upload
  uploadToFirebase(File imageFile) async {
    final fileName = '${imageFile.name}';
    final username = userState.username;
    final filePath = 'users/$username/illustrations/$fileName';

    try {
      final newDoc =
          await FirebaseFirestore.instance.collection('illustrations').add({
        'author': {
          'id': userState.uid,
        },
        'createdAt': DateTime.now(),
        'description': '',
        'private': false,
        'name': imageFile.name,
        'updatedAt': DateTime.now(),
        'urls': {
          'original': '',
          'storage': filePath,
          'share': {
            'read': '',
            'write': '',
          },
          'thumbnail': {
            's1024': '',
            's128': '',
            's512': '',
            's64': '',
          },
        },
      });

      final storage = fb.storage();
      final fileRef = storage.ref(filePath);
      final task = fileRef.put(imageFile);

      task.future.then((snapshot) async {
        try {
          final uri = await task.snapshot.ref.getDownloadURL();

          await newDoc.set(
            {
              'urls': {
                'original': uri.toString(),
              },
            },
            SetOptions(merge: true),
          );
        } catch (error) {
          debugPrint(error.toString());
        }
      });

      uploadTasks.add(
        UploadedItem(
          doc: newDoc,
          task: task,
        ),
      );

      setState(() {
        isUploading = true;
      });
    } catch (error) {
      debugPrint(error.toString());
      setState(() {
        isUploading = false;
      });
    }
  }
}
