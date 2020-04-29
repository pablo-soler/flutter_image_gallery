import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Image Gallery"),
        ),
        body: ImageGallery(),
      ),
    );
  }
}

class ImageGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: Firestore.instance.collection('imgs').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<DocumentSnapshot> docs = snapshot.data.documents;
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImagePage(docs[index].data['url']),
                    ),
                  );
                },
                child: Image.network(
                  docs[index].data['url'],
                ),
              ),
              itemCount: docs.length,
            );
          }
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {},
        child: new Icon(Icons.add_a_photo),
        tooltip: 'Add Image',
      ),
    );
  }
}

class ImagePage extends StatelessWidget {
  final String url;

  ImagePage(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Image.network(
            url,
          ),
        ));
  }
}
