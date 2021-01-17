import 'dart:ui';

import 'package:flutter/material.dart';

class AlertDialogWidget extends StatelessWidget {
  final String contentText;
  final Function confirmFunction;
  final Function declineFunction;
  final String contentTitle;

  AlertDialogWidget({
    this.contentText,
    this.confirmFunction,
    this.declineFunction,
    this.contentTitle
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Text(
        contentTitle,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        contentText,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      actions: [
        FlatButton(
          onPressed: declineFunction,
          child: Text("No"),
        ),
        FlatButton(
          onPressed: confirmFunction,
          child: Text("Yes"),
        ),
      ],
    );
  }
}
