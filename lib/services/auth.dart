import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

export 'package:firebase_auth/firebase_auth.dart';

/// Authentication implemented using Firebase Auth.
class Auth {
  /// Sets up Cloud Functions.
  static final _functions = CloudFunctions(region: 'europe-west2');

  /// Sets up Firebase Auth.
  static final _auth = FirebaseAuth.instance;

  /// Gets the currently signed in [User].
  static Stream<User> get currentUser =>
      _auth.onAuthStateChanged.asyncMap((firebaseUser) async {
        final idToken = await firebaseUser?.getIdToken(refresh: true);
        return User(idToken?.claims);
      });

  static Future<String> signUp(String email, String password) => _functions
      .getHttpsCallable(functionName: 'signUp')
      .call({'email': email, 'password': password})
      .then((result) => Future<String>.value(null))
      .catchError((error) => error.details['message']);

  /// Returns true if the user signs in successfully.
  static Future<String> signIn(String email, String password) => _auth
      .signInWithEmailAndPassword(email: email, password: password)
      .then((value) => Future<String>.value(null))
      .catchError((error) => 'The email or password you entered is incorrect.');

  /// Signs out the current user.
  static void signOut() => _auth.signOut();
}

class User {
  final String email;
  final bool isAdmin;

  User._(this.email, this.isAdmin);

  factory User(Map claims) {
    final email = (claims != null) ? claims['email'] : null;
    final isAdmin = (claims != null) ? claims['admin'] : null;
    return User._(email, isAdmin ?? false);
  }
}
