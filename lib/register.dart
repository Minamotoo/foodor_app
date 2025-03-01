import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/dialogs.dart';
import 'package:ramon/utilities/loading.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String name, username, password, userType, phone;
  bool notLoading = true;

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
            backgroundColor: Colors.purple,
            title: Text('Register'),
          ),
          body: notLoading == true
              ? showContent(context)
              : Loading().showLoading()),
    );
  }

  ListView showContent(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(30),
      children: <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              Container(
                child: Image.asset('images/logo.png'),
                width: 150,
              ),
              Material(
                child: TextFormField(
                  onChanged: (value) => name = value.trim(),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_circle,
                        color: Colors.black87,
                      ),
                      labelText: 'Full Name'),
                ),
              ),
              Material(
                child: TextFormField(
                  onChanged: (value) => username = value.trim(),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_box,
                        color: Colors.black87,
                      ),
                      labelText: 'Username'),
                ),
              ),
              Material(
                child: TextFormField(
                  onChanged: (value) => password = value.trim(),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.vpn_key,
                        color: Colors.black87,
                      ),
                      labelText: 'Password'),
                ),
              ),
              Material(
                child: TextFormField(
                  onChanged: (value) => phone = value.trim(),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.black87,
                      ),
                      labelText: 'Phone number'),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Radio(
                            value: 'customer',
                            groupValue: userType,
                            onChanged: (value) {
                              setState(() {
                                userType = value;
                              });
                            },
                          ),
                          Text(
                            'Customer',
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio(
                            value: 'owner',
                            groupValue: userType,
                            onChanged: (value) {
                              setState(() {
                                userType = value;
                              });
                            },
                          ),
                          Text(
                            'Restaurant Owner',
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
              Container(
                width: 250,
                child: RaisedButton(
                  onPressed: () {
                    if (name == null ||
                        username == null ||
                        password == null ||
                        phone == null ||
                        name.isEmpty ||
                        username.isEmpty ||
                        password.isEmpty ||
                        phone.isEmpty) {
                      Dialogs().alertDialog(context, 'Input validation!',
                          'Please fill all input', Colors.purple);
                    } else if (userType == null || userType.isEmpty) {
                      Dialogs().alertDialog(context, 'Input validation!',
                          'Please select user type', Colors.purple);
                    } else {
                      checkDuplicateUser();
                    }
                  },
                  child: Text(
                    'J O I N',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> checkDuplicateUser() async {
    setState(() {
      notLoading = false;
    });
    String url =
        '${Constants().url}/getUserWhereUser.php?isAdd=true&username=$username';

    try {
      Response response = await Dio().get(url);

      if (response.toString() == 'null') {
        register();
      } else {
        Dialogs().alertDialog(context, 'Duplicate user!',
            'The username \'$username\' is already exist!', Colors.purple);
      }
    } catch (e) {}
  }

  Future<void> register() async {
    String url =
        '${Constants().url}/addUser.php?isAdd=true&name=$name&username=$username&password=$password&userType=$userType&phone=$phone';

    try {
      Response response = await Dio().get(url);

      if (response.toString() == 'true') {
        Navigator.pop(context);
      } else {
        setState(() {
          notLoading = true;
        });
        Dialogs().alertDialog(context, 'Error!',
            'Something\'s wrong, try again later.', Colors.purple);
      }
    } catch (e) {
      print(e);
    }
  }
}
