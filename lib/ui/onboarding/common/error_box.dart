import 'package:chat_app/constants//theme.dart';
import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  const ErrorBox({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: colorScheme.surface,
            border: Border.all(
              width: 2.0,
              color: colorScheme.error,
            ),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.error,
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
