import 'package:flutter/material.dart';
import 'package:ramon/utilities/loading.dart';

class CustomerSeeRestaurant extends StatefulWidget {
  @override
  _CustomerSeeRestaurantState createState() => _CustomerSeeRestaurantState();
}

class _CustomerSeeRestaurantState extends State<CustomerSeeRestaurant> {
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
      body: Container(
          margin: EdgeInsets.all(20),
          child: infoLoaded == false
              ? Loading().showLoading()
              : showAllRestaurant()),
    );
  }

  showAllRestaurant() => showAllRestaurant();
}
