import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  CollectionReference noteCollection =
      FirebaseFirestore.instance.collection("notes");

  Future createNewNote(String baslik, String not) async {
    return await noteCollection.add({
      "title": baslik,
      "note": not,
      "createdDate": DateTime.now(),
      "editedDate": DateTime.now(),
      "userID": FirebaseAuth.instance.currentUser!.uid,
    });
  }
}
