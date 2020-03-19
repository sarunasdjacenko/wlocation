import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  Scaffold.of(context).removeCurrentSnackBar();
  Scaffold.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(text),
    ),
  );
}
