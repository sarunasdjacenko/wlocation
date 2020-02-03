import 'package:flutter/material.dart';
import 'package:wlocation/components/user_provider.dart';

class CustomBottomAppBar extends StatelessWidget {
  final bool backButtonEnabled;
  final bool scanButtonEnabled;

  CustomBottomAppBar({
    @required this.backButtonEnabled,
    @required this.scanButtonEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: UserProvider.of(context).isSignedIn() && scanButtonEnabled
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
