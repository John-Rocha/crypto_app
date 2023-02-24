import 'package:cloud_firestore/cloud_firestore.dart';

class DbFirestore {
  DbFirestore._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final DbFirestore _instance = DbFirestore._();

  static FirebaseFirestore get() {
    return DbFirestore._instance._firestore;
  }
}
