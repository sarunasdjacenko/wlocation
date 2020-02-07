import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final Function onPressed;

  CustomFloatingActionButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<UserInfo>(context);
    return Visibility(
      // visible: user != null,
      visible: true,
      child: FloatingActionButton(
        elevation: 3.0,
        child: const Icon(Icons.wifi, size: 35),
        onPressed: onPressed,
      ),
    );
  }
}
