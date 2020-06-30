import 'package:flutter/material.dart';

class Loading {
  Widget showLoading() {
    return Center(
        child: Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: 50),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(child: CircularProgressIndicator()),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                'L O A D I N G',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ]),
    ));
  }

  Widget showSaving() {
    return Center(
        child: Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: 50),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(child: CircularProgressIndicator()),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                'P R O C E S S I N G',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ]),
    ));
  }

  Widget showProcess() {
    return Center(
        child: Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: 50),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(child: CircularProgressIndicator()),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                'P R O C E S S I N G',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ]),
    ));
  }

  Loading();
}
