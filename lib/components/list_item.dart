import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String title;
  final Widget child;

  ListItem({@required this.title, @required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 65)),
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(pageBuilder: (context, a1, a2) => child),
          ),
        ),
        const Divider(height: 0.0),
      ],
    );
  }
}
