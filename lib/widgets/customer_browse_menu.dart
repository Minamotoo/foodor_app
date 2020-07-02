import 'package:flutter/material.dart';
import 'package:ramon/utilities/loading.dart';

class CustomerBrowseMenu extends StatefulWidget {
  @override
  _CustomerBrowseMenuState createState() => _CustomerBrowseMenuState();
}

class _CustomerBrowseMenuState extends State<CustomerBrowseMenu> {
  //variables
  bool infoLoaded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black87,
          title: Text('Browse menu'),
        ),
        body: Container(margin: EdgeInsets.all(20), child: showAllRestaurant()

            //TODO: do here
            // infoLoaded == false
            //     ? Loading().showLoading()
            //     : showAllRestaurant()),
            ));
  }

  showAllRestaurant() {
    return Center(
      child: Text('Menu show here'),
    );
  }
}
