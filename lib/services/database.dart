import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wlocation/models/scan_result.dart';
import 'package:wlocation/services/backend.dart';

/// Database implemented using Cloud Firestore, a NoSQL database
class Database extends Backend {
  static final _firestore = Firestore(app: Backend.firebaseApp);

  static String _venue = 'venue';
  static String _location = 'location';

  static CollectionReference get _fingerprints => _firestore
      .collection('venues')
      .document(_venue)
      .collection('locations')
      .document(_location)
      .collection('fingerprints');

  static void addFingerprint(List<ScanResult> dataset, Offset position) {
    dataset.forEach((result) {
      final data = [
        {
          'distance': result.distance,
          'location': {'x': position.dx, 'y': position.dy}
        }
      ];

      _fingerprints
          .where('bssid', isEqualTo: result.bssid)
          .getDocuments()
          .then((querySnapshot) {
        final documents = querySnapshot.documents;
        (documents.isEmpty)
            ? _fingerprints
                .document()
                .setData({'bssid': result.bssid, 'dataset': data})
            : documents.forEach((documentSnapshot) => _fingerprints
                .document(documentSnapshot.documentID)
                .updateData({'dataset': FieldValue.arrayUnion(data)}));
      });
    });
  }
}
