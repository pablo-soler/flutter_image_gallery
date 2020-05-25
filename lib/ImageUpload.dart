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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                  padding: EdgeInsets.only(left: 25, right: 25),
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
                height: 20.0,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Text(
                    'Albums',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Container(
                height: 40.0,
                padding: EdgeInsets.only(left: 20, right: 20),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: albumsName.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text(albumsName[index] + ','),
                      );
                    }),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 1,
                      ),
                    ),
                    height: 35,
                    child: InkWell(
                      onTap: () => callAlbums(),
                      child: Center(
                        child: Text(
                          " SELECT ALBUMS",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
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
        onPressed: sampleImage == null ? getImage : uploadStatusImage,
        tooltip: sampleImage == null ? 'Add image' : 'Upload image',
        child: sampleImage == null ? Icon(Icons.add) : Icon(Icons.check),
      ),
    );
  }
}
