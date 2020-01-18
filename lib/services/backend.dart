import 'package:firebase_core/firebase_core.dart';

/// Backend implemented using Firebase
class Backend {
  /// Defines the Firebase connection
  static FirebaseApp _firebaseApp;
  static FirebaseApp get firebaseApp => _firebaseApp;

  /// Initialises the Firebase connection
  static Future<void> initFirebase() async {
    _firebaseApp = await FirebaseApp.configure(
      name: 'wlocation',
      options: const FirebaseOptions(
        googleAppID: 'N/A',
        apiKey: 'AIzaSyCuuqXG4IUQ1c4pXfFbhyc0k3Vl_85XwTg',
        projectID: 'wlocation',
      ),
    );
  }
}
