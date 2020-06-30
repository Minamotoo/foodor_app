import 'package:flutter/material.dart';

class Dialogs {
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

  Future<void> alertDialog(
      BuildContext context, String title, String message, Color color) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.brown),
                    ),
                    color: Colors.brown,
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ));
  }

  Dialogs();
}
