import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String title;
  final Widget page;
  final Function beforePageCreate;

  ListItem({@required this.title, @required this.page, this.beforePageCreate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 65)),
          onTap: () {
            beforePageCreate();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, a1, a2) => page,
              ),
            );
          },
        ),
        const Divider(height: 0.0),
      ],
    );
  }
}
