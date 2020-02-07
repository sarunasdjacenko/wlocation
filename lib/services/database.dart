import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wlocation/models/scan_result.dart';

/// Database implemented using Cloud Firestore, a NoSQL database
class Database {
  static final _firestore = Firestore.instance;

  static CollectionReference _venues() => _firestore.collection('venues');

  static CollectionReference _locations(String venue) =>
      _venues().document(venue).collection('locations');

  static CollectionReference _fingerprints(String venue, String location) =>
      _locations(venue).document(location).collection('fingerprints');

  static Future<List<Map>> getVenues() async {
    final querySnapshot = await _venues().getDocuments();
    return querySnapshot.documents
        .map((documentSnapshot) => {
              'name': documentSnapshot.data['name'],
              'id': documentSnapshot.documentID,
            })
        .toList();
  }

  static Future<List> getLocations({
    String venue,
  }) async {
    final querySnapshot = await _locations(venue).getDocuments();
    return querySnapshot.documents
        .map((documentSnapshot) => {
              'name': documentSnapshot.data['name'],
              'id': documentSnapshot.documentID,
            })
        .toList();
  }

  /// Get the fingerprints that match the BSSIDs scanned
  static Future<Map> getFingerprints({
    String venue,
    String location,
    Iterable bssids,
  }) async {
    final fingerprintsColReference = _fingerprints(venue, location);
    // Split BSSIDs into groups of upto 10, to reduce the number of queries
    final bssidGroups = [];
    for (var i = 0; i < bssids.length; i += 10)
      bssidGroups.add(bssids.skip(i).take(10).toList());
    // Get the fingerprints that match the BSSID groups
    final futures = <Future<QuerySnapshot>>[];
    for (var group in bssidGroups)
      futures.add(fingerprintsColReference
          .where('bssid', whereIn: group)
          .getDocuments());
    final querySnapshots = await Future.wait(futures);
    // Format the data
    final fingerprints = {};
    querySnapshots.forEach(
      (querySnapshot) => querySnapshot.documents.forEach((documentSnapshot) {
        final bssid = documentSnapshot.data['bssid'];
        documentSnapshot.data['dataset'].forEach((data) {
          final position = Offset(data['position']['x'], data['position']['y']);
          final result = {'bssid': bssid, 'distance': data['distance']};
          (fingerprints[position] ??= []).add(ScanResult(result: result));
        });
      }),
    );
    return fingerprints;
  }

  /// Add the fingerprints for each scan result
  static void addFingerprints({
    String venue,
    String location,
    Map scanResults,
    Offset markerOffsetOnImage,
  }) {
    final fingerprintsColReference = _fingerprints(venue, location);
    final position = {'x': markerOffsetOnImage.dx, 'y': markerOffsetOnImage.dy};
    scanResults.forEach((bssid, distance) {
      final data = [
        {'distance': distance, 'position': position}
      ];
      fingerprintsColReference
          .where('bssid', isEqualTo: bssid)
          .getDocuments()
          .then((querySnapshot) => (querySnapshot.documents.isEmpty)
              ? fingerprintsColReference
                  .document()
                  .setData({'bssid': bssid, 'dataset': data})
              : querySnapshot.documents.forEach((documentSnapshot) =>
                  fingerprintsColReference
                      .document(documentSnapshot.documentID)
                      .updateData({'dataset': FieldValue.arrayUnion(data)})));
    });
  }
}
