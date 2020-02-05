import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wlocation/services/auth.dart';

class UserProvider extends StatefulWidget {
  final Widget child;

  const UserProvider({this.child});

  static _UserData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UserData>();

  @override
  _UserProviderState createState() => _UserProviderState();
}

class _UserProviderState extends State<UserProvider> {
  FirebaseUser _user;

  Future<void> _initUser() async {
    final user = await Auth.currentUser;
    setUser(user);
  }

  void setUser(FirebaseUser user) => setState(() => _user = user);

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  @override
  Widget build(BuildContext context) {
    return _UserData(
      _user,
      setUser: setUser,
      child: widget.child,
    );
  }
}

class _UserData extends InheritedWidget {
  final FirebaseUser _user;
  final ValueChanged<FirebaseUser> setUser;

  _UserData(this._user, {@required Widget child, this.setUser})
      : super(child: child);

  String get email => _user?.email;

  bool isSignedIn() => _user != null;

  @override
  bool updateShouldNotify(_UserData old) => _user != old._user;
}
