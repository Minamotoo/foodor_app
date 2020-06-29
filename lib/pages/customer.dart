import 'package:flutter/material.dart';
import 'package:ramon/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customer extends StatefulWidget {
  @override
  _CustomerState createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  String name = '';

  //get user who logged in using sharedPreference
  @override
  void initState() {
    super.initState();
    findUser();
  }

  Future<void> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      name = preferences.getString('name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name == null ? 'Guest' : 'Welcome, $name'),
        backgroundColor: Colors.black87,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              accountEmail: Text('Customer'),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/customer.jpg'),
                    fit: BoxFit.cover),
              ),
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu),
              title: Text('Most order'),
              onTap: () {
                // Navigator.pop(context);
                // MaterialPageRoute loginRoute =
                //     MaterialPageRoute(builder: (value) => Login());
                // Navigator.push(context, loginRoute);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(
                'Log out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                confirmDialog(context, 'Are you sure to log out?');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logoutThread() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();

    MaterialPageRoute route = MaterialPageRoute(builder: (context) => Login());
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  Future<void> confirmDialog(BuildContext context, String message) async {
    bool confirmLogout;

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(message),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: RaisedButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black),
                  ),
                  color: Colors.black,
                  onPressed: () {
                    confirmLogout = true;
                    if (confirmLogout == true) {
                      logoutThread();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: RaisedButton(
                  child: Text(
                    'Dismiss',
                    style: TextStyle(color: Colors.black),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black),
                  ),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
