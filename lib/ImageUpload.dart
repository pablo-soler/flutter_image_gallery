import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadPhotoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UploadPhotoPageState();
  }
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  File sampleImage;
  String _myValue;
  String url;
  final formKey = new GlobalKey<FormState>();

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
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
  void uploadStatusImage() async{
    if(validateAndSave()){
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Post Images");
      var timeKey = DateTime.now();
      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);
      var imageUrl =  await (await uploadTask.onComplete).ref.getDownloadURL();
      url=imageUrl.toString();
      goToHome();
      saveToDatabase();
    }
  }

  void saveToDatabase(){
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat('MMM d, yyyy');
    var formatTime = DateFormat('EEEE, hh:mm aaa');

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

   Firestore.instance.collection('imgs').document(dbTimeKey.toString()).setData({
      "url": url,
      "description": _myValue,
      "date": date,
      "time":time,
      "albums":null,
    });

  }

  void goToHome(){
    Navigator.pop(context);

  }

  Widget enableUpload() {
    return SingleChildScrollView(
      child:
        Container(
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
                      decoration: new InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) {
                        return value.isEmpty ? 'Description is required' : null;
                      },
                      onSaved: (value) {
                        _myValue = value;
                      }),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //AlbumDropdown(),
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

class AlbumDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: Firestore.instance.collection('albums').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<DocumentSnapshot> docs = snapshot.data.documents;
            return new DropdownButton<String>(
              items: docs.map((DocumentSnapshot album) {
                return new DropdownMenuItem<String>(
                  value: album.documentID,
                  child:  Text(album['name']),
                );
              }).toList(),
              onChanged: (_) {},
            );
          }
        },
      ),
    );
  }
}
