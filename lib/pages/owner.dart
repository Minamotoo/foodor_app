import 'package:flutter/material.dart';
import 'package:ramon/login.dart';
import 'package:ramon/widgets/owner_finished_orders.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import widget
import 'package:ramon/widgets/owner_orders.dart';
import 'package:ramon/widgets/owner_menu.dart';
import 'package:ramon/widgets/owner_info.dart';

class Owner extends StatefulWidget {
  @override
  _OwnerState createState() => _OwnerState();
}

class _OwnerState extends State<Owner> {
  String name = '';

  //Field
  Widget currentWidget = OwnerOrders();

  //get user who logged in using sharedPreference, this will run along with build()
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
        backgroundColor: Colors.brown,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              accountEmail: Text('Owner'),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/owner.jpg'), fit: BoxFit.cover),
              ),
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu),
              title: Text('Orders'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  currentWidget = OwnerOrders();
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.done_all),
              title: Text('Finished Orders'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  currentWidget = OwnerFinishedOrders();
                });
              },
            ),
            SizedBox(
              height: 5,
              child: Divider(
                color: Colors.black,
              ),
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text('Menu Management'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  currentWidget = OwnerMenu();
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Restaurant Info'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  currentWidget = OwnerInfo();
                });
              },
            ),
            SizedBox(
              height: 5,
              child: Divider(
                color: Colors.black,
              ),
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
      body: currentWidget,
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
                    side: BorderSide(color: Colors.brown),
                  ),
                  color: Colors.brown,
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
                    style: TextStyle(color: Colors.brown),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.brown),
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
