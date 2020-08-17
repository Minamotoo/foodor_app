import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ramon/models/orders.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/dialogs.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:ramon/widgets/customer_browse_restaurants.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CustomerOrders extends StatefulWidget {
  CustomerOrders() : super();
  @override
  _CustomerOrdersState createState() => _CustomerOrdersState();
}

class _CustomerOrdersState extends State<CustomerOrders> {
  //variables
  GlobalKey<RefreshIndicatorState> refreshKey;

  bool infoLoaded = false;
  var result;
  List<Orders> allOrders = List();

  //init state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrdersInfo();
  }

  Future<void> getOrdersInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String customerID = sharedPreferences.getString('id');
    print('customerID = $customerID');

    String url =
        '${Constants().url}/getOrdersByCustomerID.php?isAdd=true&customerID=$customerID';

    await Dio().get(url).then((value) async {
      result = json.decode(value.data);
    });
    // print(result);
    for (var item in result) {
      Orders orders = Orders.fromJson(item);
      allOrders.add(orders);
    }
    print(allOrders);

    setState(() {
      infoLoaded = true;
    });
  }

  //build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black87,
        title: Text('My orders'),
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          onRefresh();
        },
        child: infoLoaded == false ? Loading().showLoading() : orderedList(),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        alignment: Alignment.center,
        height: 50,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CustomerBrowseRestaurant()),
            );
          },
          child: Text(
            'Order now',
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
      ),
    );
  }

  Widget orderedList() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: allOrders.length,
      itemBuilder: (context, index) {
        return orderRow(context, index);
      },
    );
  }

  Widget orderRow(context, i) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        var orderOwner = allOrders[i].ownerName;
        deleteOrder(i, allOrders[i].id, orderOwner);
      },
      child: allOrders.length == 0
          ? CenterTitle().centerTitle14(context, 'No orders')
          : Card(
              child: ListTile(
                title: ResponsiveContainer(
                  heightPercent: 20,
                  widthPercent: 40,
                  child: ListView.builder(
                    itemCount: allOrders[i].orderDetail.length,
                    itemBuilder: (context, j) {
                      return Text(
                          '${allOrders[i].orderDetail[j].name} ${allOrders[i].orderDetail[j].amount}');
                    },
                  ),
                ),
                subtitle: Text(
                    '${allOrders[i].ownerName} \n ${allOrders[i].ownerPhone}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    var orderOwner = allOrders[i].ownerName;
                    deleteOrder(i, allOrders[i].id, orderOwner);
                  },
                ),
              ),
            ),
      background: removeBG(),
    );
  }

  deleteOrder(index, orderID, orderOwner) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String customerID = sharedPreferences.getString('id');
    print('customerID = $customerID');

    String url =
        '${Constants().url}/getOrdersByCustomerID.php?isAdd=true&customerID=$customerID';

    await Dio().get(url).then((value) async {
      result = json.decode(value.data);
    });
    // print(result);
    for (var item in result) {
      Orders orders = Orders.fromJson(item);
      // allOrders.add(orders);

      if (orders.finishStatus.toString() == '0') {
        String url = '${Constants().url}/deleteOrderByCustomer.php';
        FormData formData = FormData.fromMap({'orderID': '$orderID'});

        var response = await Dio().post(url, data: formData);
        if (response.toString() == '1') {
          showSnackBar(context, orderOwner);
          setState(() {
            allOrders.removeAt(index);
          });
        }
      } else {
        // showSnackBarError(context, cannotDelete);
        Dialogs().alertDialog(
            context,
            'Delete process undone',
            'This order is finished so you can not cancel the order\nPlease contact the restaurant',
            Colors.black87);
        onRefresh();
      }
    }
  }

  Future<Null> onRefresh() async {
    await Future.delayed(
      Duration(seconds: 1),
    );
    refreshOrder();
    return null;
  }

  Future<void> refreshOrder() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String customerID = sharedPreferences.getString('id');
    print('customerID = $customerID');

    String url =
        '${Constants().url}/getOrdersByCustomerID.php?isAdd=true&customerID=$customerID';

    await Dio().get(url).then((value) async {
      result = json.decode(value.data);
    });
    // print(result);
    setState(() {
      allOrders.clear();
    });
    for (var item in result) {
      Orders orders = Orders.fromJson(item);
      allOrders.add(orders);
    }
    print(allOrders);

    setState(() {
      infoLoaded = true;
    });
  }

  Widget removeBG() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.all(20),
      color: Colors.red,
      child: Icon(Icons.delete, color: Colors.white),
    );
  }

  showSnackBar(context, orderOwner) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Order of \'$orderOwner\' is canceled.'),
    ));
  }

  showSnackBarError(context, cannotDelete) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('$cannotDelete'),
    ));
  }
}
