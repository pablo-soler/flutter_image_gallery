import 'package:image_galery/bd.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'ImageUpload.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Image Gallery"),
        ),
        drawer: LateralMenu(),
        body: ImageGallery(),
      ),
    );
  }
}

class LateralMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> list = <Widget>[];
    list.add(FlatButton(
      child: Text("NEW ALBUM"),
      color: Colors.amberAccent,
      onPressed: () {},
    ));
    list.add(
      Container(
        child: InkWell(
          onTap: () => {},
          child: ListTile(
            title: Text("ALL PHOTOS"),
          ),
        ),
      ),
    );

    return Drawer(
        child: StreamBuilder(
      stream: Firestore.instance.collection('albums').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          List<DocumentSnapshot> docs = snapshot.data.documents;
          for (var i = 0; i < docs.length; i++) {
            list.add(
              InkWell(
                onTap: () => {},
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          "https://homepages.cae.wisc.edu/~ece533/images/cat.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ListTile(
                    title: Text(docs[i].data['name']),
                  ),
                ),
              ),
            );
          }
          return ListView(
            children: list,
          );
        }
      },
    ));
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
                      builder: (context) => PhotoGallery(docs, index),
                    ),
                  );
                },
                child: FadeInImage.memoryNetwork(
                  image: docs[index].data['url'],
                  placeholder: kTransparentImage,
                ),
              ),
              itemCount: docs.length,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return UploadPhotoPage();
          }));
        },
        child: Icon(Icons.add_a_photo),
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
        child: PhotoView(
          imageProvider: NetworkImage(
            url,
          ),
        ),
      ),
    );
  }
}

class PhotoGallery extends StatelessWidget {
  final galleryItems;
  final int initialPos;
  int pos;
  bool first = true;
  PhotoGallery(this.galleryItems, this.initialPos);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Container(
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            if (first) {
              index = initialPos;
              first = false;
            }
            pos = index;

            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(
                galleryItems[index].data['url'],
              ),
              initialScale: PhotoViewComputedScale.contained,
            );
          },
          itemCount: galleryItems.length,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(galleryItems[pos].documentID);
          print(galleryItems[pos].data['storageId']);
          _showDeleteDialog(galleryItems[pos].documentID, galleryItems[pos].data['storageId'], context);
        },
        child: new Icon(Icons.delete),
        tooltip: 'Delete Image',
      ),
    );
  }

  Future<void> _showDeleteDialog(String id, String storageId, context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Image'),
        content: SingleChildScrollView(
          child:
              Text('Would you like to delete this image?'),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Accept'),
            onPressed: () {
              deletePhotoById(id, storageId);
              Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageGallery(),
                    ),
                  );
            },
          ),
        ],
      );
    },
  );
}
}
