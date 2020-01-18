import 'package:firebase_auth/firebase_auth.dart';
import 'package:wlocation/services/backend.dart';

/// Auth implemented using Firebase Auth
class Auth extends Backend {
  static final _auth = FirebaseAuth.fromApp(Backend.firebaseApp);

  static void signIn({String email, String password}) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  static void signOut() => _auth.signOut();
}