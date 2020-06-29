import 'package:flutter/material.dart';

class OwnerAddMenu extends StatefulWidget {
  @override
  _OwnerAddMenuState createState() => _OwnerAddMenuState();
}

class _OwnerAddMenuState extends State<OwnerAddMenu> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.brown,
          centerTitle: true,
          title: Text('Add menu'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'SAVE',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
