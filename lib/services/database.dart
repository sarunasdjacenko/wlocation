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

  /// Reference to venues in [Firestore].
  static CollectionReference venues() => _firestore.collection('venues');

  /// Reference to locations in [Firestore].
  static CollectionReference locations(String venueId) =>
      venues().document(venueId).collection('locations');

  /// Reference to fingerprints in [Firestore].
  static CollectionReference fingerprints(String venueId, String locationId) =>
      locations(venueId).document(locationId).collection('fingerprints');

  /// Reference to images in [FirebaseStorage].
  static StorageReference _images(String venueId, String locationId) =>
      _storage.ref().child('images/$venueId/$locationId/');

  /// Reference to a full-sized map in [FirebaseStorage].
  static StorageReference mapFull(String venueId, String locationId) =>
      _images(venueId, locationId).child('map.jpg');

  /// Reference to a thumbnail-sized map in [FirebaseStorage].
  static StorageReference mapThumbnail(String venueId, String locationId) =>
      _images(venueId, locationId).child('map_200x200.jpg');
}

/// Database implemented using Cloud Firestore, a NoSQL database
class Database {
  /// Returns a [Stream] of the venues [QuerySnapshot].
  static Stream<QuerySnapshot> venues() =>
      _FirebaseReferences.venues().orderBy('name').snapshots();

  /// Adds a new venue.
  static void addVenue(String venueName) =>
      _FirebaseReferences.venues().add({'name': venueName});

  /// Returns a [Stream] of the locations [QuerySnapshot].
  static Stream<QuerySnapshot> locations(String venueId) =>
      _FirebaseReferences.locations(venueId).orderBy('name').snapshots();

  /// Adds a new location.
  static void addLocation(String venueId, String locationName) =>
      _FirebaseReferences.locations(venueId).add({'name': locationName});

  /// Returns an authenticated URL of the full-sized map image.
  static Future<String> getMapUrl(String venueId, String locationId) =>
      _FirebaseReferences.mapFull(venueId, locationId)
          .getDownloadURL()
          .then((url) => url as String);

  /// Returns an authenticated URL of the thumbnail-sized map image.
  static Future<String> getMapThumbnailUrl(String venueId, String locationId) =>
      _FirebaseReferences.mapThumbnail(venueId, locationId)
          .getDownloadURL()
          .then((url) => url as String);

  /// Uploads an image to [FirebaseStorage].
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
          final geopoint = data['geopoint'];
          final geoOffset = Offset(geopoint.longitude, geopoint.latitude);
          final scanData = ScanData(bssid, data['distance']);
          (fingerprints[geoOffset] ??= []).add(scanData);
        });
      }),
    );
    return fingerprints;
  }

  /// Add the fingerprints for each scan result
  static void addFingerprints({
    String venueId,
    String locationId,
    Map scanResults,
    Offset geoOffset,
  }) {
    getMapCalibration(venueId: venueId, locationId: locationId).then(
      (calibration) {
        final geopoint = GeoPoint(geoOffset.dy, geoOffset.dx);
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

  /// Gets the calibration equation, used to convert pixels to geolocation.
  static Future<Map> getMapCalibration({
    String venueId,
    String locationId,
  }) async {
    final location =
        await _FirebaseReferences.locations(venueId).document(locationId).get();
    return location.data['calibration'];
  }

  /// Sets the calibration scale, used to convert pixels to geolocation.
  static void setMapCalibration({
    String venueId,
    String locationId,
    Map lineOfBestFit,
  }) {
    _FirebaseReferences.locations(venueId)
        .document(locationId)
        .updateData({'calibration': lineOfBestFit});
  }
}
