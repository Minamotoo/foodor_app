import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramon/models/ordered_detail_model.dart';
import 'package:ramon/models/detail.dart';

import 'dart:convert';

class OwnerOrders extends StatefulWidget {
  @override
  _OwnerOrdersState createState() => _OwnerOrdersState();
}

class _OwnerOrdersState extends State<OwnerOrders> {
  //variables
  bool infoLoaded = false;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  List<Message> messages;

  List<String> detailList;

  String strMessage;

  String customerName;
  String customerPhone;
  String order;
  String amount;

  List<Detail> orderDetailList = List();

  //method
  Future<void> getOrdersInfo() async {
    getToken();
    configureFirebaseListener();
    setState(() {
      infoLoaded = true;
    });
  }

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
    // setDetail(m);
  }

  setDetail(Message m) {
    print(m.message);
    // setState(() {
    //   strMessage = m.message.toString();
    //   strMessage = strMessage.replaceAll(strMessage[0], '');
    //   strMessage = strMessage.replaceAll(
    //       strMessage.substring(strMessage.length - 1), '');
    //   OrdersDetailModel ordersDetailModel =
    //       OrdersDetailModel.fromJson(jsonDecode(strMessage));
    //   // customerName = ordersDetailModel.customerName;
    //   // customerPhone = ordersDetailModel.customerPhone;

    //   // print('customerName $customerName');
    //   // print('customerPhone $customerPhone');

    //   var detail = ordersDetailModel.orderDetail;

    //   // detail = detail.replaceAll(detail[0], '[{');
    //   // detail = detail.replaceAll(detail.substring(detail.length - 1), '}]');

    //   Detail details = Detail.fromJson(jsonDecode(detail));

    //   setState(() {
    //     customerName = ordersDetailModel.customerName;
    //     customerPhone = ordersDetailModel.customerPhone;
    //     order = details.name;
    //     amount = details.amount.toString();
    //   });
    // clear();
    // });
  }

  // clear() {
  //   messages.clear();
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrdersInfo();
    // getToken();
    // configureFirebaseListener();
    messages = List<Message>();
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
          backgroundColor: Colors.brown,
          title: Text('Customers\'s orders'),
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: infoLoaded == false
              ? Loading().showLoading()
              : ListView.builder(
                  itemCount: messages == null ? 0 : messages.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Container(
                          height: 300,
                          child: ListView.separated(
                            itemCount: orderDetailList.length,
                            itemBuilder: (context, index) {
                              return Text(
                                '${orderDetailList[index].name}   ${orderDetailList[index].amount}',
                                style: TextStyle(fontSize: 18),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                child: Divider(
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        subtitle: Text('$customerName \n $customerPhone'),
                        trailing: FlatButton(
                          child: Text(
                            'DONE',
                            style: TextStyle(fontSize: 18, color: Colors.green),
                          ),
                          padding: EdgeInsets.all(10),
                          // color: Colors.green,
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                ),
          // : Card(
          //     child: Text(
          //         'Customer : $customerName \nPhone : $customerPhone \n$orderDetailList -- $amount'),
          //   ),
        ),
      ),
    );
  }
}

class Message {
  String title, body, message;

  Message({this.title, this.body, this.message});
}
