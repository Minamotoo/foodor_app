import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ramon/models/ordered_menu_model.dart';
import 'package:ramon/models/orders.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramon/models/ordered_detail_model.dart';
import 'package:ramon/models/detail.dart';
import 'package:responsive_container/responsive_container.dart';

import 'dart:convert';

class OwnerFinishedOrders extends StatefulWidget {
  @override
  _OwnerFinishedOrdersState createState() => _OwnerFinishedOrdersState();
}

class _OwnerFinishedOrdersState extends State<OwnerFinishedOrders> {
  //var---------------------------------------------------------
  GlobalKey<RefreshIndicatorState> refreshKey;
  bool infoLoaded = false;

  var result;
  var counterInList;

  List<OrdersDetailModel> orders = List();
  List<Detail> orderDetailList = List();
  List<List<Detail>> orderDetailList2 = List();

  List<Orders> allOrders = List();

  String customerName;
  String customerPhone;
  String tmpCustomerName = '';

  //-----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    getOrdersInfo();
    refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  //build------------------------------------------------------
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
        var orderCustomer = allOrders[i].customerName.toString();
        cancelOrder(i, allOrders[i].id, orderCustomer);
        // showSnackBar(context, orderCustomer);
      },
      background: removeBG(),
      child: allOrders.length == 0
          ? CenterTitle().centerTitle14(context, 'No orders')
          : Card(
              child: ListTile(
                title: ResponsiveContainer(
                  heightPercent: 20,
                  widthPercent: 50,
                  child: ListView.builder(
                    itemCount: allOrders[i].orderDetail.length,
                    itemBuilder: (context, j) {
                      return Text(
                          '${allOrders[i].orderDetail[j].name} ${allOrders[i].orderDetail[j].amount}');
                    },
                  ),
                ),
                subtitle: Text(
                    '${allOrders[i].customerName} \n ${allOrders[i].customerPhone}'),
              ),
            ),
    );
  }

  Widget removeBG() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.all(20),
      color: Colors.red,
      child: Icon(Icons.close, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.brown,
        title: Text('Finished orders'),
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          onRefresh();
        },
        child: infoLoaded == false
            ? Loading().showLoading()
            // : allOrders.length == 0
            // ? CenterTitle().centerTitle14(context, 'No orders')
            : orderedList(),
        // child: Text('A')
      ),
    );
  }

  //------------------------------------------------------------

  //method---------------------------------------------------------
  Future<Null> onRefresh() async {
    await Future.delayed(
      Duration(seconds: 1),
    );
    refreshOrder();
    return null;
  }

  Future<void> getOrdersInfo() async {
    // getToken();
    // configureFirebaseListener();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String ownerID = sharedPreferences.getString('id');

    String url =
        '${Constants().url}/getFinishedOrders.php?isAdd=true&ownerID=$ownerID';

    await Dio().get(url).then((value) async {
      result = json.decode(value.data);
    });
    // print('res4314141 $result');
    // print(result);
    for (var item in result) {
      Orders orders = Orders.fromJson(item);
      allOrders.add(orders);
    }

    setState(() {
      infoLoaded = true;
    });
  }

  Future<void> refreshOrder() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String ownerID = sharedPreferences.getString('id');

    String url =
        '${Constants().url}/getFinishedOrders.php?isAdd=true&ownerID=$ownerID';

    await Dio().get(url).then((value) async {
      result = json.decode(value.data);
    });
    setState(() {
      allOrders.clear();
    });
    for (var item in result) {
      Orders orders = Orders.fromJson(item);
      allOrders.add(orders);
      // print(allOrders[])
    }

    setState(() {
      infoLoaded = true;
    });
  }

  cancelOrder(index, orderID, orderCustomer) async {
    String url = '${Constants().url}/finishAndCancelOrderByOwner.php';
    FormData formData = FormData.fromMap({'orderID': '$orderID'});

    var response = await Dio().post(url, data: formData);
    if (response.toString() == '1') {
      showSnackBar(context, orderCustomer);
      setState(() {
        allOrders.removeAt(index);
      });
    }
  }

  showSnackBar(context, orderCustomer) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('$orderCustomer\'s orders is canceled.'),
    ));
  }

  //-----------------------------------------------------------
}
