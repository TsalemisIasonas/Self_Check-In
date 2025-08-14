import 'package:flutter/material.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final Color? color;

  const MyAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: color,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500),),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
