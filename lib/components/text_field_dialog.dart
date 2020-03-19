import 'package:flutter/material.dart';

class TextFieldDialog extends StatelessWidget {
  final _inputController = TextEditingController();

  final String titleText;
  final String labelText;
  final Function(String) onSubmit;

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
            cursorColor: Theme.of(context).textTheme.bodyText2.color,
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
