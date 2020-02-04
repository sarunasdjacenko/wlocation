import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wlocation/models/scan_result.dart';
import 'package:wlocation/services/backend.dart';

/// Database implemented using Cloud Firestore, a NoSQL database
class Database extends Backend {
  static final _firestore = Firestore(app: Backend.firebaseApp);

  static String _venue;
  static String _location;

  static void setVenue(String venue) => _venue = venue;

  static void setLocation(String location) => _location = location;

  static CollectionReference get _venues => _firestore.collection('venues');

  static CollectionReference get _locations =>
      _venues.document(_venue).collection('locations');

  static CollectionReference get _fingerprints =>
      _locations.document(_location).collection('fingerprints');

  static Future<List<Map>> getVenues() async {
    final querySnapshot = await _venues.getDocuments();
    return querySnapshot.documents
        .map((documentSnapshot) => {
              'name': documentSnapshot.data['name'],
              'id': documentSnapshot.documentID,
            })
        .toList();
  }

  static Future<List> getLocations() async {
    final querySnapshot = await _locations.getDocuments();
    return querySnapshot.documents
        .map((documentSnapshot) => {
              'name': documentSnapshot.data['name'],
              'id': documentSnapshot.documentID,
            })
        .toList();
  }

  /// Get the fingerprints that match the BSSIDs scanned
  static Future<Map> getFingerprints(Iterable bssids) async {
    // Split BSSIDs into groups of upto 10, to reduce the number of queries
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
          final result = {'bssid': bssid, 'distance': data['distance']};
          (fingerprints[location] ??= []).add(ScanResult(result: result));
        });
      }),
    );
    return fingerprints;
  }

  /// Add the fingerprints for each scan result
  static void addFingerprints(Map scanResults, Offset position) {
    final location = {'x': position.dx, 'y': position.dy};
    scanResults.forEach((bssid, distance) {
      final data = [
        {'distance': distance, 'location': location}
      ];
      _fingerprints.where('bssid', isEqualTo: bssid).getDocuments().then(
          (querySnapshot) => (querySnapshot.documents.isEmpty)
              ? _fingerprints
                  .document()
                  .setData({'bssid': bssid, 'dataset': data})
              : querySnapshot.documents.forEach((documentSnapshot) =>
                  _fingerprints
                      .document(documentSnapshot.documentID)
                      .updateData({'dataset': FieldValue.arrayUnion(data)})));
    });
  }
}
