import 'package:flutter/material.dart';
import 'package:wlocation/components/user_provider.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final Function onPressed;

  CustomFloatingActionButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: UserProvider.of(context).isSignedIn(),
      child: FloatingActionButton(
        elevation: 3.0,
        child: const Icon(Icons.wifi, size: 35),
        onPressed: onPressed,
      ),
    );
  }
}
