import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

class Photo {
  String id;
  String storageId;
  String url;
  String description;
  String date;
  String time;
  List<String> albums = List();

  Photo(this.url, [this.description = "", this.albums]);
  Photo.empty();
  Photo.fromFirestore(DocumentSnapshot doc) {
    id = doc.documentID;
    url = doc.data['url'];
  }
}


// Stream<List<Photo>> photoSnapshots() {
//   return Firestore.instance
//       .collection('imgs')
//       .orderBy('date')
//       .snapshots()
//       .map((QuerySnapshot query) {
//     final List<DocumentSnapshot> docs = query.documents;
//     return docs.map((doc) => Photo.fromFirestore(doc)).toList();
//   });
// }

addPhoto(Photo photo, String key) {
  Firestore.instance.collection('imgs').document(key).setData({
    'url': photo.url,
    'description': photo.description,
    'date': photo.date,
    'time': photo.time,
    "albums": photo.albums,
    'storageId': photo.storageId

  });
    photo.albums.map((albumReference)=> addAlbumToImage(key, albumReference));
  //aqui se tendría que enviar la referencia de esta imagen al album
}

deletePhoto(Photo photo) {
  Firestore.instance.document('imgs/${photo.id}').delete();
  FirebaseStorage.instance.ref().child("Post Images").child(photo.storageId).delete();
}

deletePhotoById(String id, String storageId) {
  FirebaseStorage.instance.ref().child("Post Images").child(storageId).delete();
  Firestore.instance.document('imgs/$id').delete();

}


///////////////ALBUMS//////////////

addAlbum(String name){
  Firestore.instance.collection('albums').add({
    'name': name,
    'dateChanged': Timestamp.fromDate(DateTime.now()),
  });
}

deleteAlbum(Album album){
   Firestore.instance.document('albums/${album.id}').delete();
}


addAlbumToImage(String idPhoto, String idAlbum){

  Firestore.instance.document('imgs/$idPhoto').updateData({
              //"albums":firebase.firestore.FieldValue.arrayUnion($idAlbum)
            });

  
}
