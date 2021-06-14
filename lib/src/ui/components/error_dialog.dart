import 'package:flutter/material.dart';

Future showError(BuildContext context, String s) async {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Row(
              children: [
                Expanded(child: Text("Error")),
                Icon(
                  Icons.error,
                  color: Colors.red,
                )
              ],
            ),
            content: Text(s),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Aceptar"))
            ],
          ));
}
