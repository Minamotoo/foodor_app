import 'package:flutter/material.dart';

Future<void> normalDialog(
    BuildContext context, String message, Color color) async {
  showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            title: Text(message),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'O K',
                        style: TextStyle(color: Colors.black),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: color),
                      ),
                      color: Colors.white,
                    ),
                  )
                ],
              )
            ],
          ));
}
