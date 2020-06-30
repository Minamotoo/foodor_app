import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ramon/models/user_models.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/loading.dart';

class CustomerBrowseRestaurant extends StatefulWidget {
  @override
  _CustomerBrowseRestaurantState createState() =>
      _CustomerBrowseRestaurantState();
}

// seems like this one will be see restaurant

class _CustomerBrowseRestaurantState extends State<CustomerBrowseRestaurant> {
  //variables
  bool infoLoaded = false;
  List<UserModel> restaurantLists = List();

  @override
  void initState() {
    super.initState();
    getAllRestaurant();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black87,
        title: Text('Browse restaurant'),
      ),
      body: Container(
          margin: EdgeInsets.all(20),
          child:
              infoLoaded == false ? Loading().showLoading() : showRestaurant()),
    );
  }

  Future<void> getAllRestaurant() async {
    String url =
        '${Constants().url}/getUserWhereUserIsOwner.php?isAdd=true&userType=owner';

    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      for (var item in result) {
        UserModel model = UserModel.fromJson(item);
        String restaurantName = model.restaurantName;
        // String restaurantPhone = model.restaurantPhone;
        // String restaurantAddress = model.restaurantAddress;
        if (restaurantName.isNotEmpty) {
          setState(() {
            restaurantLists.add(model);
            infoLoaded = true;
          });
        }
      }
    });
  }

  //create content
  Widget showRestaurant() => ListView.builder(
      itemCount: restaurantLists.length,
      itemBuilder: (contxt, index) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //image
              Container(
                padding: EdgeInsets.all(10),
                width: 170,
                height: 170,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    '${Constants().url}${restaurantLists[index].imageURL}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              //info
              Flexible(
                child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${restaurantLists[index].restaurantName}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: CupertinoColors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${restaurantLists[index].restaurantPhone}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          ));
}
