import 'package:cache_image/cache_image.dart';
import 'package:image_galery/bd.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'ImageUpload.dart';
import 'package:provider/provider.dart';
import 'package:image_galery/AlbumList.dart';

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
                    padding: const EdgeInsets.only(
                        left: 4, right: 4, top: 2, bottom: 2),
                    child: InkWell(
                      onTap: () {
                        Provider.of<ActualAlbum>(context, listen: false)
                            .actualAlbum(docs[i]);
                        Navigator.pop(context);
                      },
                      onLongPress: () {
                        _showDeleteDialog(docs[i].documentID, context);
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
                            image: NetworkImage(docs[i].data['bg'] != ""
                                ? docs[i].data['bg']
                                : "https://748073e22e8db794416a-cc51ef6b37841580002827d4d94d19b6.ssl.cf3.rackcdn.com/not-found.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            docs[i].data['name'],
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
                            ),
                          ),
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
                      onTap: () {
                        _showAddAlbumDialog(context);
                      },
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
          }),
    );
  }

  Future<void> _showDeleteDialog(String id, context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Album'),
          content: SingleChildScrollView(
            child: Text('Would you like to delete this album?'),
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
                deleteAlbum(id);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => App(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddAlbumDialog(context) async {
    TextEditingController myController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Album'),
          content: SingleChildScrollView(
            child: Center(
              child: Container(
                  width: 300,
                  child: TextFormField(
                    controller: myController,
                    decoration: InputDecoration(
                      labelText: 'Album name',
                    ),
                    validator: (value) {
                      return value.isEmpty ? 'Album name is required' : null;
                    },
                  )),
            ),
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
                if (myController.value.text.isEmpty) {
                  myController.text = "Unnamed Album";
                } else {
                  addAlbum(myController.value.text);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => App(),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
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
                    PageController _pageController =
                        PageController(initialPage: index);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PhotoGallery(docs, _pageController),
                      ),
                    );
                  },
                  child: FadeInImage(
                    image: CacheImage(docs[index].data['url']),
                    placeholder: CacheImage(
                        "https://748073e22e8db794416a-cc51ef6b37841580002827d4d94d19b6.ssl.cf3.rackcdn.com/not-found.png"),
                  )),
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

class PhotoGallery extends StatelessWidget {
  final galleryItems;
  final _pageController;
  PhotoGallery(this.galleryItems, this._pageController);

  callAlbums(context, photoId, url, albums) {
    albums.forEach((album) => print(album));
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AlbumListPage(albums),
      ),
    )
        .then((result) {
      if (result[0] != null) {
        addAlbumToImage(photoId, result[0], url);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => App(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.folder),
            onPressed: () {
              callAlbums(
                  context,
                  galleryItems[_pageController.page.round()].documentID,
                  galleryItems[_pageController.page.round()].data['url'],
                  galleryItems[_pageController.page.round()].data['albums']);
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Container(
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(
                galleryItems[index].data['url'],
              ),
              initialScale: PhotoViewComputedScale.contained,
            );
          },
          itemCount: galleryItems.length,
          pageController: _pageController,
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
          _showDeleteDialog(
              galleryItems[_pageController.page.round()].documentID,
              galleryItems[_pageController.page.round()].data['storageId'],
              context);
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
                    builder: (context) => App(),
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
