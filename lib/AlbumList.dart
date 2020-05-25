import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AlbumListPage extends StatelessWidget {
  final picAlbums;
  AlbumListPage(this.picAlbums);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose...')),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('albums')
            .orderBy('dateChanged')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<DocumentSnapshot> docs = snapshot.data.documents;
            return AlbumList(docs, picAlbums);
          }
        },
      ),
    );
  }
}

class AlbumList extends StatefulWidget {
  final List<DocumentSnapshot> albums;
  final picAlbums;
  AlbumList(this.albums, this.picAlbums);
  @override
  State<StatefulWidget> createState() => _AlbumListState(albums, picAlbums);
}

class _AlbumListState extends State<AlbumList> {
  final List<DocumentSnapshot> albums;
  final picAlbums;
  _AlbumListState(this.albums, this.picAlbums);
  List<bool> albumsIndex;

  void initState() {
    super.initState();
    albumsIndex = new List();
    albums.forEach((album) =>
        picAlbums != null && picAlbums.contains(album.documentID)
            ? albumsIndex.add(true)
            : albumsIndex.add(false));
  }

  @override
  Widget build(BuildContext context) {
    print(albumsIndex);
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, int index) {
              return ListTile(
                onTap: () {
                  setState(() {
                    albumsIndex[index] = !albumsIndex[index];
                  });
                },
                title: Text(albums[index].data['name']),
                leading: Checkbox(
                  activeColor: Colors.grey[900],
                  checkColor: Colors.red,
                  value: albumsIndex[index],
                  onChanged: (_) => setState(() {
                    albumsIndex[index] = !albumsIndex[index];
                  }),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            // width: 150,
            decoration: BoxDecoration(
             color: Colors.red
            ),
            height: 50,
            child: InkWell(
              onTap: () {
                List<String> albumsName = new List();
                List<String> albumsId = new List();
                List<List> albumsReference = new List(2);
                for (var i = 0; i < albums.length; i++) {
                  if (albumsIndex[i]) {
                    albumsName.add(albums[i].data['name']);
                    albumsId.add(albums[i].documentID);
                  }
                }

                albumsReference[0] = albumsId;
                albumsReference[1] = albumsName;
                Navigator.of(context).pop(albumsReference);
              },
              child: Center(
                child: Text(
                  " SELECT ALBUMS",
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w800,
                   
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
