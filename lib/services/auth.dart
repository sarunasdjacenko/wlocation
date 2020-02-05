import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wlocation/services/backend.dart';

/// Auth implemented using Firebase Auth.
class Auth extends Backend {
  /// Sets up Firebase Auth.
  static final _auth = FirebaseAuth.fromApp(Backend.firebaseApp);

  /// Gets the currently signed-in [FirebaseUser] or null if there is none.
  static Future<FirebaseUser> get currentUser async =>
      await _auth.currentUser();

  /// Signs the user in using Email and Password.
  static void signInWithEmailAndPassword(
          {@required String email,
          @required String password,
          Function onAuthChanged}) =>
      _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((authResult) => onAuthChanged?.call(authResult.user));

  /// Signs the user in using a Custom Firebase Auth Token.
  static void signInWithCustomToken(
          {@required String token, Function onAuthChanged}) =>
      _auth
          .signInWithCustomToken(token: token)
          .then((authResult) => onAuthChanged?.call(authResult.user));

  /// Signs out the current user.
  static void signOut({Function onAuthChanged}) =>
      _auth.signOut().then((_) => onAuthChanged?.call(null));
}
