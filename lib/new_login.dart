import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ramon/pages/customer.dart';
import 'package:ramon/pages/owner.dart';
import 'package:ramon/register.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/dialogs.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_model.dart';

class NewLogin extends StatefulWidget {
  @override
  _NewLoginState createState() => _NewLoginState();
}

class _NewLoginState extends State<NewLogin> {
  String username, password;
  bool backFromRegister = false;

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
          title: Text('ramon'),
        ),
        body: backFromRegister == true
            ? Loading().showLoading()
            : Container(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                      child: Column(
                        children: <Widget>[
                          Material(
                            child: TextField(
                              onChanged: (value) => username = value.trim(),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.account_box),
                                  labelText: 'Username'),
                            ),
                          ),
                          Material(
                            child: TextField(
                              onChanged: (value) => password = value.trim(),
                              obscureText: true,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.vpn_key),
                                  labelText: 'Password'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 250,
                            child: RaisedButton(
                              child: Text(
                                'L O G I N',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              onPressed: () {
                                if (username == null ||
                                    password == null ||
                                    username.isEmpty ||
                                    password.isEmpty) {
                                  Dialogs().alertDialog(
                                      context,
                                      'Input validation!',
                                      'Please fill all input!',
                                      Colors.blue);
                                } else {
                                  login();
                                }
                              },
                            ),
                          ),
                          SizedBox(
                              height: 30,
                              child: Divider(
                                color: Colors.black,
                              )),
                          Container(
                            width: 250,
                            child: RaisedButton(
                              child: Text(
                                'R E G I S T E R',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              onPressed: () {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Register()))
                                    .then((value) {
                                  setState(() {
                                    backFromRegister = false;
                                  });

                                  Dialogs().alertDialog(context, 'Success!',
                                      'Register success!', Colors.blue);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> login() async {
    String url =
        '${Constants().url}/getUserWhereUser.php?isAdd=true&username=$username&password=$password';

    try {
      Response response = await Dio().get(url);
      //to decode
      var result = json.decode(response.data);
      if (result == null) {
        Dialogs().alertDialog(context, 'Cautions!',
            'Invalid credentials, please check again', Colors.blue);
      } else {
        for (var map in result) {
          UserModel userModel = UserModel.fromJson(map);

          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString('id', userModel.id);
          sharedPreferences.setString('name', userModel.name);
          sharedPreferences.setString('userType', userModel.userType);

          if (sharedPreferences != null) {
            if (username == userModel.username &&
                password == userModel.password) {
              //process next
              String userType = userModel.userType;
              if (userType == 'customer') {
                // routeNext(Customer(), userModel);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Customer()),
                    (route) => false);
              } else if (userType == 'owner') {
                // routeNext(Owner(), userModel);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Owner()),
                    (route) => false);
              } else {
                Dialogs().alertDialog(context, 'Error!',
                    'Something\' wrong, please try again later', Colors.blue);
              }
            } else {
              Dialogs().alertDialog(context, 'Input validation!',
                  'Please check your username or password again', Colors.blue);
            }
          } else {
            Dialogs().alertDialog(context, 'Error!',
                'Can\'t save user\'s data, try again.', Colors.red);
          }
        }
      }
    } catch (e) {}
  }

  // Future<void> routeNext(Widget widget, UserModel userModel) async {
  //   //shared preference, save logged in
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   preferences.setString('id', userModel.id);
  //   preferences.setString('name', userModel.name);
  //   preferences.setString('userType', userModel.userType);

  //   normalDialog(context, '${userModel.userType}', Colors.brown);

  //   MaterialPageRoute route = MaterialPageRoute(builder: (context) => widget);
  //   Navigator.pushAndRemoveUntil(context, route, (route) => false);
  // }
}
