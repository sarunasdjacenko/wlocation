import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'models.dart';

export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';

/// Holds various references to Cloud Firestore and Firebase Storage.
class _FirebaseReferences {
  static final _firestore = Firestore.instance;
  static final _storage = FirebaseStorage.instance;

  static CollectionReference venues() => _firestore.collection('venues');

  static CollectionReference locations(String venueId) =>
      venues().document(venueId).collection('locations');

  static CollectionReference fingerprints(String venueId, String locationId) =>
      locations(venueId).document(locationId).collection('fingerprints');

  static StorageReference _images(String venueId, String locationId) =>
      _storage.ref().child('images/$venueId/$locationId/');

  static StorageReference mapFull(String venueId, String locationId) =>
      _images(venueId, locationId).child('map.jpg');

  static StorageReference mapThumbnail(String venueId, String locationId) =>
      _images(venueId, locationId).child('map_200x200.jpg');
}

/// Database implemented using Cloud Firestore, a NoSQL database
class Database {
  static Stream<QuerySnapshot> venues() =>
      _FirebaseReferences.venues().orderBy('name').snapshots();

  static void addVenue(String venueName) =>
      _FirebaseReferences.venues().add({'name': venueName});

  static Stream<QuerySnapshot> locations(String venueId) =>
      _FirebaseReferences.locations(venueId).orderBy('name').snapshots();

  static void addLocation(String venueId, String locationName) =>
      _FirebaseReferences.locations(venueId).add({'name': locationName});

  static Future<String> getMapUrl(String venueId, String locationId) =>
      _FirebaseReferences.mapFull(venueId, locationId)
          .getDownloadURL()
          .then((url) => url as String);

  static Future<String> getMapThumbnailUrl(String venueId, String locationId) =>
      _FirebaseReferences.mapThumbnail(venueId, locationId)
          .getDownloadURL()
          .then((url) => url as String);

  static Stream<StorageTaskEvent> addMapImage(
    String venueId,
    String locationId,
    File image,
  ) {
    final uploadTask =
        _FirebaseReferences.mapFull(venueId, locationId).putFile(image);
    return uploadTask.events;
  }

  /// Get the fingerprints that match the BSSIDs scanned.
  static Future<Map> getFingerprints({
    String venueId,
    String locationId,
    Iterable bssids,
  }) async {
    final location =
        await _FirebaseReferences.locations(venueId).document(locationId).get();
    final calibration = location.data['calibration'];

    final fingerprintsRef =
        _FirebaseReferences.fingerprints(venueId, locationId);
    // Split BSSIDs into groups of upto 10, to reduce the number of queries.
    final bssidGroups = [];
    for (var i = 0; i < bssids.length; i += 10)
      bssidGroups.add(bssids.skip(i).take(10).toList());
    // Get the fingerprints that match the BSSID groups
    final futures = bssidGroups.map((group) =>
        fingerprintsRef.where('bssid', whereIn: group).getDocuments());
    final querySnapshots = await Future.wait(futures);
    // Format the data
    final fingerprints = {};
    querySnapshots.forEach(
      (querySnapshot) => querySnapshot.documents.forEach((documentSnapshot) {
        final bssid = documentSnapshot.data['bssid'];
        documentSnapshot.data['dataset'].forEach((data) {
          final position = _calculatePosition(data['geopoint'], calibration);
          final scanData = ScanData(bssid, data['distance']);
          (fingerprints[position] ??= []).add(scanData);
        });
      }),
    );
    return fingerprints;
  }

  static Offset _calculatePosition(GeoPoint geopoint, Map calibration) {
    double calculatePoint(double coordinate, Map equation) {
      final gradient = equation['gradient'];
      final intercept = equation['intercept'];
      return (coordinate - intercept) / gradient;
    }

    final x = calculatePoint(geopoint.longitude, calibration['longitude']);
    final y = calculatePoint(geopoint.latitude, calibration['latitude']);
    return Offset(x, y);
  }

  static GeoPoint _calculateGeoPoint(Offset position, Map calibration) {
    double calculatePoint(double coordinate, Map equation) {
      final gradient = equation['gradient'];
      final intercept = equation['intercept'];
      return coordinate * gradient + intercept;
    }

    final longitude = calculatePoint(position.dx, calibration['longitude']);
    final latitude = calculatePoint(position.dy, calibration['latitude']);
    return GeoPoint(latitude, longitude);
  }

  /// Add the fingerprints for each scan result
  static void addFingerprints({
    String venueId,
    String locationId,
    Map scanResults,
    Offset markerOffsetOnImage,
  }) {
    _FirebaseReferences.locations(venueId).document(locationId).get().then(
      (location) {
        final geopoint = _calculateGeoPoint(
          markerOffsetOnImage,
          location.data['calibration'],
        );
        final fingerprintsRef =
            _FirebaseReferences.fingerprints(venueId, locationId);
        scanResults.forEach((bssid, distance) {
          final data = [
            {'distance': distance, 'geopoint': geopoint}
          ];
          fingerprintsRef.where('bssid', isEqualTo: bssid).getDocuments().then(
              (querySnapshot) => (querySnapshot.documents.isEmpty)
                  ? fingerprintsRef
                      .document()
                      .setData({'bssid': bssid, 'dataset': data})
                  : querySnapshot.documents.forEach((documentSnapshot) =>
                      fingerprintsRef
                          .document(documentSnapshot.documentID)
                          .updateData(
                              {'dataset': FieldValue.arrayUnion(data)})));
        });
      },
    );
  }

  /// Sets the calibration scale, used to convert pixels to geolocation.
  static void setCalibration({
    String venueId,
    String locationId,
    Map lineOfBestFit,
  }) {
    _FirebaseReferences.locations(venueId)
        .document(locationId)
        .updateData({'calibration': lineOfBestFit});
  }
}
