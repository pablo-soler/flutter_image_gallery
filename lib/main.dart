import 'package:image_galery/bd.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'ImageUpload.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(App());

class ActualAlbum with ChangeNotifier {
  String _id = "";
  String _name = "All photos";
  List<String> urlBg = List();

  String get id => _id;
  String get name => _name;

  actualAlbum(DocumentSnapshot album) {
    _id = album.documentID;
    _name = album.data['name'];
    notifyListeners();
    print(name);
  }

  allPhotos() {
    _id = '';
    _name = 'All photos';
    notifyListeners();
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ActualAlbum>(
      create: (_) => ActualAlbum(),
      child: MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        accentColor: Colors.red,
        buttonColor: Colors.red,
        fontFamily: 'Nunito',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            Provider.of<ActualAlbum>(context).name,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        drawer: LateralMenu(),
        body: ImageGallery(),
      ),
    );
  }
}

//----------MENU LATERAL ALBUMS -----------------
class LateralMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> list = <Widget>[];

    list.add(
      Container(
        height: 80,
        child: Center(
          child: InkWell(
            onTap: () {
              Provider.of<ActualAlbum>(context, listen: false).allPhotos();
              Navigator.pop(context);
            },
            child: ListTile(
              title: Text(
                "All photos",
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w800,
                  color: Provider.of<ActualAlbum>(context).id == ''
                      ? Colors.red
                      : Colors.white,
                ),
              ),
            ),
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
              Padding(
                padding:
                    const EdgeInsets.only(left: 4, right: 4, top: 2, bottom: 2),
                child: InkWell(
                  onTap: () {
                    Provider.of<ActualAlbum>(context, listen: false)
                        .actualAlbum(docs[i]);
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: docs[i].data['name'] ==
                              Provider.of<ActualAlbum>(context).name
                          ? Border.all(color: Colors.red, width: 2)
                          : null,
                      image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(docs[i].data['name'] ==
                                    Provider.of<ActualAlbum>(context).name
                                ? 0.3
                                : 0.6),
                            BlendMode.dstATop),
                        image: NetworkImage(docs[i].data['bg'] != null
                            ? docs[i].data['bg']
                            : ""),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: ListTile(
                      title: Text(docs[i].data['name'],
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: <Shadow>[
                              Shadow(
                                blurRadius: 100.0,
                                color: Colors.black,
                              ),
                              Shadow(
                                blurRadius: 50.0,
                                color: Colors.black,
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              ),
            );
          }
          list.add(
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 50,
                child: InkWell(
                  onTap: () {},
                  child: Center(
                    child: Text(
                      "ADD NEW ALBUM",
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          return ListView(
            children: list,
          );
        }
      },
    ));
  }
}

//---------GALERIA GENERAL----------------
class ImageGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final album = (Provider.of<ActualAlbum>(context).id);
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

            if (album != "") {
              docs = docs
                  .where((d) =>
                      d.data['albums'] != null &&
                      d.data['albums'].contains(album))
                  .toList();
            }
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

//-----PAGINA DE IMAGEN---------------
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
          _showDeleteDialog(galleryItems[pos].documentID,
              galleryItems[pos].data['storageId'], context);
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
            child: Text('Would you like to delete this image?'),
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
