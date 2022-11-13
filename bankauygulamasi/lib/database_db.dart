import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataBaseGets {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Map<String, dynamic> data = {};
  List<Map<String, dynamic>> islemler = [];

  Future<Map<String, dynamic>> getData() async {
    await _firestore
        .collection('bankaUygulamasi')
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((value) {
      data.addAll(value.data()!);
    });

    return data;
  }

  Future<List<Map<String, dynamic>>> getIslemler() async {
    await _firestore
        .collection('bankaUygulamasi')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('islemler')
        .orderBy('islem tarihi', descending: true)
        .get()
        .then((qs) {
      for (var i = 0; i < qs.docs.length; i++) {
        islemler.add(qs.docs[i].data());
      }
    });

    return islemler;
  }
}
