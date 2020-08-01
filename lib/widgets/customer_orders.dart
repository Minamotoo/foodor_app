import 'package:flutter/material.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CustomerOrders extends StatefulWidget {
  CustomerOrders() : super();
  @override
  _CustomerOrdersState createState() => _CustomerOrdersState();
}

class _CustomerOrdersState extends State<CustomerOrders> {
  //variables
  bool infoLoaded = false;

  //init state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrdersInfo();
  }

  Future<void> getOrdersInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    String customerID = sharedPreferences.getString('id');
    print('customerID = $customerID');
    setState(() {
      infoLoaded = true;
    });
  }

  //build
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black87,
          title: Text('My orders'),
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: infoLoaded == false ? Loading().showLoading() : Text('AAA'),
        ),
      ),
    );
  }
}
