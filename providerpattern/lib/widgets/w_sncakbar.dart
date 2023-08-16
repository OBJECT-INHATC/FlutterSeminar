import 'package:flutter/material.dart';

/// showSnackbar 함수
void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        textColor: Colors.white,
      ),
    ),
  );
}