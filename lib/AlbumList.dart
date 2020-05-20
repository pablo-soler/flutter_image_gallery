import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AlbumListPage extends StatelessWidget {
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
            return AlbumList(docs);
          }
        },
      ),
    );
  }
}

class AlbumList extends StatefulWidget {
  final List<DocumentSnapshot> albums;
  AlbumList(this.albums);
  @override
  State<StatefulWidget> createState() => _AlbumListState(albums);
}

class _AlbumListState extends State<AlbumList> {
  final List<DocumentSnapshot> albums;
  _AlbumListState(this.albums);
  List<bool> albumsIndex;

  void initState() {
    super.initState();
    albumsIndex = new List();
    for (var i = 0; i < albums.length; i++) {
      albumsIndex.add(false);
    }
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
                  value: albumsIndex[index],
                  onChanged: (_) => setState(() {
                    albumsIndex[index] = !albumsIndex[index];
                  }),
                ),
              );
            },
          ),
        ),
        RaisedButton(
          child: Text('Save'),
          onPressed: () {
            List<String> albumsName = new List();
            List<String> albumsId = new List();
            List<List> albumsReference =  new List(2); 
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
        ),
      ],
    );
  }
}
