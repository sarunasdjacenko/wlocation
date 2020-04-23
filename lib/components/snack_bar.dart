import 'package:flutter/material.dart';

/// Removes the current snackbar, if any, and replaces it with the given text.
void showSnackBar(BuildContext context, String text) {
  Scaffold.of(context).removeCurrentSnackBar();
  Scaffold.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(text),
    ),
  );
}
