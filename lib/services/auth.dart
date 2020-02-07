import 'package:firebase_auth/firebase_auth.dart';

export 'package:firebase_auth/firebase_auth.dart';

/// Auth implemented using Firebase Auth.
class Auth {
  /// Sets up Firebase Auth.
  static final _auth = FirebaseAuth.instance;

  /// Gets the currently signed-in [FirebaseUser] or null if there is none.
  static Stream<UserInfo> get currentUser => _auth.onAuthStateChanged;

  /// Signs the user in using Email and Password.
  static void signInWithEmailAndPassword(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  /// Signs the user in using a Custom Firebase Auth Token.
  static void signInWithCustomToken(String token) =>
      _auth.signInWithCustomToken(token: token);

  /// Signs out the current user.
  static void signOut() => _auth.signOut();
}
