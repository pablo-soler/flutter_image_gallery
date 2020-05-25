import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_galery/AlbumList.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'bd.dart';

class UploadPhotoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UploadPhotoPageState();
  }
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  File sampleImage;
  Photo photo = Photo.empty();
  List<String> albumsName = new List();

  final formKey = GlobalKey<FormState>();

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 800, maxWidth: 800);
    setState(() {
      sampleImage = tempImage;
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void uploadStatusImage() async {
    if (validateAndSave()) {
      final StorageReference postImageRef =
          FirebaseStorage.instance.ref().child("Post Images");
      var timeKey = DateTime.now();
      final StorageUploadTask uploadTask =
          postImageRef.child(timeKey.toString()).putFile(sampleImage);
      photo.storageId = timeKey.toString();
      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      photo.url = imageUrl.toString();
      goToHome();
      saveToDatabase();
    }
  }

  void saveToDatabase() {
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat('MMM d, yyyy');
    var formatTime = DateFormat('EEEE, hh:mm aaa');

    photo.date = formatDate.format(dbTimeKey);
    photo.time = formatTime.format(dbTimeKey);

    addPhoto(photo, dbTimeKey.toString());
  }

  void goToHome() {
    Navigator.pop(context);
  }

  callAlbums() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AlbumListPage([]),
      ),
    )
        .then((result) {
      if (result[0] != null) {
        setState(() {
          photo.albums = result[0];
          albumsName = result[1];
        });
      }
    });
  }

  Widget enableUpload() {
    return SingleChildScrollView(
      child: Container(
        child: Form(
          key: formKey,
          child: Column(children: <Widget>[
            Image.file(
              sampleImage,
            ),
            SizedBox(
              height: 15.0,
            ),
            Center(
              child: Container(
                width: 300,
                child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                    validator: (value) {
                      return value.isEmpty ? 'Description is required' : null;
                    },
                    onSaved: (value) {
                      photo.description = value;
                    }),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            RaisedButton(
              padding: EdgeInsets.all(5.0),
              child: Text('ADD ALBUMS'),
              onPressed: () => callAlbums(),
            ),
            Container(
              height: 30.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                    itemCount: albumsName.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text(albumsName[index]),
                      );
                    }),
              ),
            ),
            RaisedButton(
              child: Text("Upload Image"),
              elevation: 10.0,
              textColor: Colors.white,
              color: Colors.green,
              onPressed: uploadStatusImage,
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Upload Image"),
      ),
      body: Center(
        child: sampleImage == null ? Text("Select an Image") : enableUpload(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add image',
        child: Icon(Icons.add),
      ),
    );
  }
}
