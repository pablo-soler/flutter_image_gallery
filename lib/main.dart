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
      home: Scaffold(
        appBar: AppBar(
          title: Text(Provider.of<ActualAlbum>(context).name),
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
    list.add(FlatButton(
      child: Text("NEW ALBUM"),
      color: Colors.amberAccent,
      onPressed: () {
        _showAddAlbumDialog(context);
      },
    ));
    list.add(
      Container(
        child: InkWell(
          onTap: () {
            Provider.of<ActualAlbum>(context, listen: false).allPhotos();
            Navigator.pop(context);
          },
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
                onTap: () {
                  Provider.of<ActualAlbum>(context, listen: false)
                      .actualAlbum(docs[i]);
                  Navigator.pop(context);
                },
                onLongPress: (){_showDeleteDialog(docs[i].documentID, context);},
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(docs[i].data['bg'] != ""
                          ? docs[i].data['bg']
                          : "https://748073e22e8db794416a-cc51ef6b37841580002827d4d94d19b6.ssl.cf3.rackcdn.com/not-found.png"),
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
                      builder: (context) => PhotoGallery(docs, _pageController),
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

class PhotoGallery extends StatelessWidget {
  final galleryItems;
  final _pageController;
  PhotoGallery(this.galleryItems, this._pageController);

  callAlbums(context, photoId, url, albums) {
    albums.forEach((album)=>print(album));
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AlbumListPage(albums),
      ),
    )
        .then((result) {
      if (result[0] != null) {
            addAlbumToImage(photoId, result[0], url);
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
                    builder: (context) =>  App(),
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
