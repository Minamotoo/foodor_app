import 'package:flutter/material.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:ramon/widgets/owner_add_menu.dart';

class OwnerMenu extends StatefulWidget {
  @override
  _OwnerMenuState createState() => _OwnerMenuState();
}

class _OwnerMenuState extends State<OwnerMenu> {
  //variables
  bool infoLoaded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.brown,
        title: Text('Menu'),
      ),
      body: infoLoaded == false
          ? Loading().showLoading()
          : checkIfInfoAvailable(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => OwnerAddMenu()));
        },
      ),
    );
  }

  //methods
  checkIfInfoAvailable() {}
}
