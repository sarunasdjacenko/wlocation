import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wlocation/services/backend.dart';

/// Database implemented using Cloud Firestore, a NoSQL database
class Database extends Backend {
  static final _firestore = Firestore(app: Backend.firebaseApp);

  static Stream<QuerySnapshot> get accessPoints =>
      _firestore.collection('accessPoints').snapshots();
}
