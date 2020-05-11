import 'package:cloud_firestore/cloud_firestore.dart';
import "bd.dart";
import 'package:flutter/material.dart';



class AlbumListPage extends StatelessWidget {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose...')),
      body: StreamBuilder<List<Album>>(
        stream: albumsSnapshots(),
        builder: (context, AsyncSnapshot<List<Album>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('ERROR: ${snapshot.error.toString()}'));
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return AlbumList(snapshot.data);
            case ConnectionState.done:
              return Center(child: Text("done??"));
            case ConnectionState.none:
            default:
              return Center(child: Text("no hi ha stream??"));
          }
        },
      ),
    );
  }

  
}



class AlbumList extends StatefulWidget{
  final List<Album> albums;
  AlbumList(this.albums);
@override
  State<StatefulWidget> createState() => _AlbumListState(albums);
}
class _AlbumListState extends State<AlbumList> {
final List<Album> albums;
_AlbumListState(this.albums);
List<bool> albumsIndex;

void initState(){
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
                title: Text(albums[index].name),
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
            List<String> albumsRefenrece = new List();
            for (var i = 0; i < albums.length; i++) { 
              if (albumsIndex[i]) {
                albumsRefenrece.add('albums/${albums[i].id}');
              }
            }
            Navigator.of(context).pop(albumsRefenrece);
          },
        ),
      ],
    );
  
  }
}

