import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBottomAppBar extends StatelessWidget {
  final bool backButtonEnabled;
  final bool scanButtonEnabled;

  CustomBottomAppBar({
    @required this.backButtonEnabled,
    @required this.scanButtonEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserInfo>(context);
    return BottomAppBar(
      shape: user != null && scanButtonEnabled
          ? const CircularNotchedRectangle()
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          if (backButtonEnabled)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
        ],
      ),
    );
  }
}
