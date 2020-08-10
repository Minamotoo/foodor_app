import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ramon/models/ordered_menu_model.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramon/models/ordered_detail_model.dart';
import 'package:ramon/models/detail.dart';
import 'package:responsive_container/responsive_container.dart';

import 'dart:convert';

class OwnerOrders extends StatefulWidget {
  @override
  _OwnerOrdersState createState() => _OwnerOrdersState();
}

class _OwnerOrdersState extends State<OwnerOrders> {
  //variables
  bool infoLoaded = false;

  //อันเก่าที่ไม่ใช้แล้ว
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  List<Message> messages;
  List<String> detailList;
  String strMessage;

  String order;
  String amount;

  ///////////////////////////////////////////////////////////////////////////////////////
  GlobalKey<RefreshIndicatorState> refreshKey;

  var result;
  var counterInList;

  List<OrdersDetailModel> orders = List();
  List<Detail> orderDetailList = List();
  List<List<Detail>> orderDetailList2 = List();

  String customerName;
  String customerPhone;
  String tmpCustomerName = '';

  ///////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    getOrdersInfo();
    refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  Future<void> getOrdersInfo() async {
    getToken();
    // configureFirebaseListener();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String ownerID = sharedPreferences.getString('id');

    String url = '${Constants().url}/getOrders.php?isAdd=true&ownerID=$ownerID';

    await Dio().get(url).then((value) async {
      result = json.decode(value.data);
    });
    for (var item in result) {
      OrdersDetailModel ordersDetailModel = OrdersDetailModel.fromJson(item);
      setState(() {
        orders.add(ordersDetailModel);
        customerName = ordersDetailModel.customerName;
        customerPhone = ordersDetailModel.customerPhone;

        var res2 = json.decode(ordersDetailModel.orderDetail);
        for (var item2 in res2) {
          Detail detail = Detail.fromJson(item2);

          orderDetailList.add(detail);
        }

        List<Detail> tmpList = [];
        orderDetailList.forEach((element) => tmpList.add(element));
        orderDetailList2.add(tmpList);

        if (tmpCustomerName != customerName) {
          orderDetailList.clear();
          // print('after $orderDetailList2');
        }
        tmpCustomerName = customerName;
      });
    }

    // String strAllOrders = orderDetailList2.toString();
    // print(strAllOrders[0]);
    // print(strAllOrders.substring(strAllOrders.length - 1));
    // strAllOrders.substring(1, strAllOrders.length - 1);
    // print(strAllOrders);
    // for (int i = 0; i < orderDetailList2.length; i++) {
    //   for (var item in json.decode(orderDetailList2[i].toString())) {
    //     String str = orderDetailList2[i].toString();
    //     String first = str[0];
    //     String last = str.substring(str.length - 1);
    //     str.replaceAll(first, '');
    //     str.replaceAll(last, '');
    //     item = str.toString();
    //     print(item);
    //   }
    // }
    for (int i = 0; i < orderDetailList2.length; i++) {
      for (int j = 0; j < orderDetailList2[i].length; j++) {
        print(orderDetailList2[i][j].name);
        // var j = json.decode(orderDetailList2[i][j]);
        // for (var item in json.decode(orderDetailList2[i][j].toString())) {
        //   Detail detail = Detail.fromJson(item);
        //   print(detail);
        // }
      }
    }

    setState(() {
      infoLoaded = true;
    });
  }

  Future<Null> onRefresh() async {
    await Future.delayed(
      Duration(seconds: 1),
    );
    //refresh new
    return null;
  }

  Widget orderedList() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return orderRow(context, index);
      },
    );
  }

  Widget orderRow(context, index) {
    return Dismissible(
      key: Key(orders[index].toString()),
      onDismissed: (direction) {},
      background: removeBG(),
      child: orders.length == 0
          ? CenterTitle().centerTitle14(context, 'No orders')
          : Card(
              child: ListTile(
                title: ResponsiveContainer(
                  heightPercent: 20,
                  widthPercent: 80,
                  child: ListView.builder(
                      itemCount: orderDetailList.length,
                      itemBuilder: (context, index) {
                        return Text(
                            '${orderDetailList[index].name} ${orderDetailList[index].amount}');
                      }),
                ),
                subtitle: Text('${orders[index].customerName}'),
              ),
            ),
    );
  }

  Widget removeBG() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.all(20),
      color: Colors.green,
      child: Icon(Icons.check, color: Colors.white),
    );
  }

  //build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.brown,
        title: Text('Customers\'s orders'),
      ),
      body: RefreshIndicator(
          key: refreshKey,
          onRefresh: () async {
            onRefresh();
          },
          child: infoLoaded == false ? Loading().showLoading() : orderedList()),
    );
  }

  //////////////////////////////////////////////////////////////////////////
  getToken() {
    firebaseMessaging.getToken().then((deviceToken) {
      print('token: $deviceToken');
    });
  }

  configureFirebaseListener() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // print('onMessage: $message');
        setMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        // print('onLaunch: $message');
        setMessage(message);
      },
      onResume: (Map<String, dynamic> message) async {
        // print('onResume: $message');
        setMessage(message);
      },
    );
  }

  setMessage(Map<String, dynamic> message) {
    final notification = message['notification'];
    final data = message['data'];
    final String title = notification['title'];
    final String body = notification['body'];
    final String mMessage = data['message'];

    Message m = Message(title: title, body: body, message: mMessage);
    var res = json.decode(m.message);
    // print(res);
    for (var item in res) {
      OrdersDetailModel ordersDetailModel = OrdersDetailModel.fromJson(item);
      print(ordersDetailModel.customerName);
      // print(ordersDetailModel.orderDetail);

      var res2 = json.decode(ordersDetailModel.orderDetail);
      for (var item2 in res2) {
        Detail detail = Detail.fromJson(item2);
        print(detail.name);
        print(detail.amount);

        setState(() {
          customerName = ordersDetailModel.customerName;
          customerPhone = ordersDetailModel.customerPhone;
          order = detail.name;
          amount = detail.amount.toString();

          orderDetailList.add(detail);
        });
      }
    }
    setState(() {
      messages.add(m);
    });
  }

  //////////////////////////////////////////////////////////////////////////
}

class Message {
  String title, body, message;

  Message({this.title, this.body, this.message});
}
