import 'package:cloud_firestore/cloud_firestore.dart';

class Album {
  String id;
  String name;
  String bg = ""; //He usado reference de la img para definirlo pero si siempre se usará url para definir una imagen, será mas sencillo que sea String url
  DateTime dateChanged;

  Album(this.name);
Album.fromFirestore(DocumentSnapshot doc) {
    id = doc.documentID;
    name = doc.data['name'];
    dateChanged = (doc.data['dateChanged'] as Timestamp).toDate(); 
  }

}


class Photo{
String id;
String url; 
String description;
/*String date; ?
String time; ?
Yo propongo que sea DateTime, es más sencillo 
*/
DateTime date;
List<String> albums = List();

Photo(this.url, [this.description="", this.albums]);
Photo.fromFirestore(DocumentSnapshot doc) {
    id = doc.documentID;
    url = doc.data['url'];
    
//date no está en las fotos que hay dentro ahora
    date = (doc.data['date'] as Timestamp).toDate(); 
  }

}

Stream<List<Photo>> photoSnapshots() {
  return Firestore.instance
      .collection('imgs')
      .orderBy('date')
      .snapshots()
      .map((QuerySnapshot query) {
    final List<DocumentSnapshot> docs = query.documents;
    return docs.map((doc) => Photo.fromFirestore(doc)).toList();
  });
}

addPhoto(String url, String description, List<String> albums){
  Firestore.instance.collection('imgs').add({
    'url': url,
    'description': description,
    'date': Timestamp.fromDate(DateTime.now()),
  });
  //aqui se tendría que enviar la referencia de esta imagen al album
}

deletePhoto(Photo photo){
   Firestore.instance.document('imgs/${photo.id}').delete();
}


///////////////ALBUMS//////////////
Stream<List<Album>> albumsSnapshots() {
  return Firestore.instance
      .collection('albums')
      .orderBy('dateChanged')
      .snapshots()
      .map((QuerySnapshot query) {
    final List<DocumentSnapshot> docs = query.documents;
    return docs.map((doc) => Album.fromFirestore(doc)).toList();
  });
}

addAlbum(String name){
  Firestore.instance.collection('albums').add({
    'name': name,
    'dateChanged': Timestamp.fromDate(DateTime.now()),
  });
}

deleteAlbum(Album album){
   Firestore.instance.document('albums/${album.id}').delete();
}

