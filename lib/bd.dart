import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Album {
  String id;
  String name;
  String bg = "";
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
    "albums": [],
    'storageId': photo.storageId
  });
  addAlbumToImage(key, photo.albums, photo.url);
  //aqui se tendría que enviar la referencia de esta imagen al album
}

deletePhoto(Photo photo) {
  Firestore.instance.document('imgs/${photo.id}').delete();
  FirebaseStorage.instance
      .ref()
      .child("Post Images")
      .child(photo.storageId)
      .delete();
}

deletePhotoById(String id, String storageId) {
  FirebaseStorage.instance.ref().child("Post Images").child(storageId).delete();
  Firestore.instance.document('imgs/$id').delete();
}

///////////////ALBUMS//////////////

addAlbum(String name) {
  Firestore.instance.collection('albums').add({
    'bg': '',
    'name': name,
    'dateChanged': Timestamp.fromDate(DateTime.now()),
  });
}

deleteAlbum(Album album) {
  Firestore.instance.document('albums/${album.id}').delete();
}

addAlbumToImage(String idPhoto, albums, String urlPhoto) {
  //HE INCLUIDO ESTO AQUI PARA QUE CUANDO SE SUBA UNA IMAGEN SE ACTUALIZE EL VALOR bg DEL ALBUM
  //ENTIENDO QUE AQUÍ SE ENTRA AL SUBIR LA IMAGEN
  albums.forEach((album) => {
        Firestore.instance.document('albums/$album').updateData({
          'bg': urlPhoto,
          'dateChanged': Timestamp.fromDate(DateTime.now())
        }),
        print(album)
      });

  Firestore.instance.collection('imgs').document(idPhoto).updateData({
    "albums": albums,
  });
}
