import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wlocation/services/auth.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserInfo>(context);
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.pinkAccent),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                user?.email ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Account'),
            onTap: () => user != null
                ? Auth.signOut()
                : Auth.signInWithEmailAndPassword('email', 'password'),
          ),
        ],
      ),
    );
  }
}
