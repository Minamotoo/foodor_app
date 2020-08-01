import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerOrders extends StatefulWidget {
  @override
  _OwnerOrdersState createState() => _OwnerOrdersState();
}

class _OwnerOrdersState extends State<OwnerOrders> {
  //variables
  bool infoLoaded = false;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  List<Message> messages;

  //method
  Future<void> getOrdersInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    String ownerID = sharedPreferences.getString('id');
    print('ownerID = $ownerID');
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
        print('onMessage: $message');
        setMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        setMessage(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
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

    setState(() {
      Message m = Message(title: title, body: body, message: mMessage);
      messages.add(m);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrdersInfo();
    getToken();
    configureFirebaseListener();
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
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Text(
                          messages[index].message,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class Message {
  String title, body, message;

  Message({this.title, this.body, this.message});
}
