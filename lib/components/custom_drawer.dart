import 'package:flutter/material.dart';
import 'package:wlocation/components/user_provider.dart';
import 'package:wlocation/services/auth.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.pinkAccent),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                UserProvider.of(context).email ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Account'),
            onTap: () => UserProvider.of(context).isSignedIn()
                ? Auth.signOut(
                    callback: (user) => UserProvider.of(context).setUser(user))
                : Auth.signInWithEmailAndPassword(
                    email: 'email',
                    password: 'password',
                    callback: (user) => UserProvider.of(context).setUser(user)),
          ),
        ],
      ),
    );
  }
}
