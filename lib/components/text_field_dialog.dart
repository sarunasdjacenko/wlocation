import 'package:flutter/material.dart';

class TextFieldDialog extends StatelessWidget {
  /// Input box for the dialog.
  final _inputController = TextEditingController();

  /// The title of the dialog.
  final String titleText;
  /// The label text to display when the input box is empty.
  final String labelText;
  /// The function callback when the done button is tapped.
  final Function(String) onSubmit;

  /// Constructor for the [TextFieldDialog] class
  TextFieldDialog({this.titleText, this.labelText, @required this.onSubmit});

  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(titleText),
      titlePadding: const EdgeInsets.all(20),
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _inputController,
            autofocus: true,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
            ),
            cursorWidth: 1,
            cursorColor: Theme.of(context).textTheme.body2.color,
            textInputAction: TextInputAction.done,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FlatButton(
            child: Text('Done', style: TextStyle(fontSize: 16)),
            onPressed: () {
              final text = _inputController.text;
              if (text.isNotEmpty) {
                onSubmit?.call(_inputController.text);
                Navigator.pop(context);
              }
            },
          ),
        ),
      ],
    );
  }
}
