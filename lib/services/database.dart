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

  /// Get the fingerprints that match the BSSIDs scanned
  static Future<Map> getFingerprints(List<ScanResult> scanResults) async {
    final bssids = scanResults.map((result) => result.bssid);
    // Split BSSIDs into groups of 10, to reduce the number of queries
    final bssidGroups = [];
    for (var i = 0; i < bssids.length; i += 10)
      bssidGroups.add(bssids.skip(i).take(10).toList());
    // Get the fingerprints that match the BSSID groups
    final futures = <Future<QuerySnapshot>>[];
    for (var group in bssidGroups)
      futures.add(_fingerprints.where('bssid', whereIn: group).getDocuments());
    final querySnapshots = await Future.wait(futures);
    // Format the data
    final fingerprints = {};
    querySnapshots.forEach(
      (querySnapshot) => querySnapshot.documents.forEach((documentSnapshot) {
        final bssid = documentSnapshot.data['bssid'];
        documentSnapshot.data['dataset'].forEach((data) {
          final location = Offset(data['location']['x'], data['location']['y']);
          final fingerprint = {'bssid': bssid, 'distance': data['distance']};
          (fingerprints[location] ??= []).add(fingerprint);
        });
      }),
    );
    return fingerprints;
  }

  /// Add the fingerprints for each BSSID scanned
  static void addFingerprints(List<ScanResult> scanResults, Offset position) {
    final location = {'x': position.dx, 'y': position.dy};
    scanResults.forEach((result) {
      final data = [
        {'distance': result.distance, 'location': location}
      ];
      _fingerprints.where('bssid', isEqualTo: result.bssid).getDocuments().then(
          (querySnapshot) => (querySnapshot.documents.isEmpty)
              ? _fingerprints
                  .document()
                  .setData({'bssid': result.bssid, 'dataset': data})
              : querySnapshot.documents.forEach((documentSnapshot) =>
                  _fingerprints
                      .document(documentSnapshot.documentID)
                      .updateData({'dataset': FieldValue.arrayUnion(data)})));
    });
  }
}
