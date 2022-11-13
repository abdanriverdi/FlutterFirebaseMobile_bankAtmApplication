import 'package:flutter/material.dart';

class CustomSnackBar {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackbar(
      BuildContext context, String msg, int duration) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Color.fromARGB(255, 132, 7, 250),
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        duration: Duration(seconds: duration),
      ),
    );
  }
}
