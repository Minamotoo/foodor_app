import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ramon/models/menu_model.dart';
import 'package:ramon/models/user_model.dart';
import 'package:ramon/models/ordered_menu_model.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/dialogs.dart';
import 'package:ramon/utilities/loading.dart';

class CustomerChooseMenuFromRestaurant extends StatefulWidget {
  //final and constructor
  final UserModel userModel;

  const CustomerChooseMenuFromRestaurant({Key key, this.userModel})
      : super(key: key);

  @override
  _CustomerChooseMenuFromRestaurantState createState() =>
      _CustomerChooseMenuFromRestaurantState();
}

class _CustomerChooseMenuFromRestaurantState
    extends State<CustomerChooseMenuFromRestaurant> {
  //variables
  UserModel userModel;
  List<MenuModel> menuLists = List();

  List<OrderedMenuModel> orderedList = List();

  bool infoLoaded = false;
  bool foundDuplicate = false;

  int netPrice = 0;
  int countList = 0;

  //inistate
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userModel = widget.userModel;
    getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${userModel.restaurantName}'),
        backgroundColor: Colors.black87,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.white,
            onPressed: () {
              showRestaurantInfo();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: infoLoaded == false
            ? Loading().showLoading()
            : showMenuOfRestaurant(),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 30, right: 15),
        color: Colors.black87,
        alignment: Alignment.center,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              onTap: () {
                orderedList.length == 0
                    ? Dialogs().normalDialog(context,
                        'You haven\'t chosen any menu yet!', Colors.black87)
                    : showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Review your orders',
                              style: TextStyle(color: Colors.deepOrangeAccent),
                            ),
                            content: ListView.separated(
                              itemCount: orderedList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                    leading: CircleAvatar(
                                      radius: 27,
                                      backgroundColor: Colors.deepOrangeAccent,
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(
                                            '${Constants().url}${orderedList[index].foodImageURL}'),
                                      ),
                                    ),
                                    title: Text('${orderedList[index].name}'),
                                    trailing: orderedList[index].amount > 1
                                        ? Text('${orderedList[index].amount}')
                                        : Text(''));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(
                                  height: 4,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          );
                        });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Items chosen: $countList',
                    style: TextStyle(
                        color: Colors.yellow[200],
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Net Price: $netPrice',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              alignment: Alignment.center,
              icon: Icon(Icons.shopping_cart),
              color: Colors.deepOrangeAccent,
              iconSize: 30,
              onPressed: () {
                //process to buy
              },
            ),
          ],
        ),
      ),
    );
  }

  //show content
  Widget showReviewDialog() => ListView.separated(
        itemCount: orderedList.length,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepOrangeAccent,
            radius: 30,
            child: CircleAvatar(
                // backgroundImage: NetworkImage('${}'),//////////////////////////////////////////////////////////////////////////////////////////
                ),
          ),
        ),
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 4,
            color: Colors.grey,
          );
        },
      );
  Widget showMenuOfRestaurant() => ListView.separated(
        itemCount: menuLists.length,
        itemBuilder: (context, index) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //image
            Container(
              padding: EdgeInsets.all(10),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepOrange,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(
                      '${Constants().url}${menuLists[index].foodImageURL}'),
                ),
              ),
            ),

            //info
            Flexible(
              flex: 4,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Text(
                      '${menuLists[index].name}',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${menuLists[index].price} THB.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      child: Text(
                        '${menuLists[index].description}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      child: menuLists[index].promotionStatus == '0'
                          ? SizedBox()
                          : Column(
                              children: <Widget>[
                                Divider(
                                  color: Colors.grey,
                                ),
                                Text(
                                  '${menuLists[index].promotionDetail}',
                                  style: TextStyle(color: Colors.yellow[800]),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),

            //add, delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  //add
                  icon: Icon(Icons.add),
                  color: Colors.green,
                  onPressed: () {
                    String thisMenuID = menuLists[index].id;
                    String thisMenuName = menuLists[index].name;
                    String thisMenuOwnerID = menuLists[index].ownerID;
                    double doublePrice = double.parse(menuLists[index].price);
                    int thisMenuPrice = doublePrice.toInt();
                    int thisMenuAmount = 1;
                    String thisFoodImageURL = menuLists[index].foodImageURL;

                    setState(() {
                      countList++;
                      netPrice += thisMenuPrice;

                      if (countList > 0) {
                        if (orderedList.length == 0) {
                          OrderedMenuModel om = OrderedMenuModel();

                          om.id = thisMenuID;
                          om.name = thisMenuName;
                          om.price = thisMenuPrice;
                          om.ownerID = thisMenuOwnerID;
                          om.amount = thisMenuAmount;
                          om.foodImageURL = thisFoodImageURL;

                          orderedList.add(om);
                          om = null;
                        } else {
                          OrderedMenuModel om = OrderedMenuModel();
                          OrderedMenuModel toAdd = OrderedMenuModel();

                          om.id = thisMenuID;
                          om.name = thisMenuName;
                          om.price = thisMenuPrice;
                          om.ownerID = thisMenuOwnerID;
                          om.amount = thisMenuAmount;
                          om.foodImageURL = thisFoodImageURL;

                          for (var ol in orderedList) {
                            if (ol.id == om.id) {
                              ol.amount += thisMenuAmount;
                              ol.price += thisMenuPrice;
                              foundDuplicate = true;
                            } else {
                              toAdd.id = om.id;
                              toAdd.name = om.name;
                              toAdd.ownerID = om.ownerID;
                              toAdd.price = om.price;
                              toAdd.amount = om.amount;
                              toAdd.foodImageURL = om.foodImageURL;
                              foundDuplicate = false;
                            }
                            if (foundDuplicate == true) {
                              break;
                            }
                          }
                          if (foundDuplicate == false) {
                            orderedList.add(toAdd);
                          }
                          om = null;
                          toAdd = null;
                        }

                        thisMenuID = null;
                        thisMenuName = null;
                        thisMenuPrice = null;
                        thisMenuOwnerID = null;
                        thisMenuAmount = null;
                        thisFoodImageURL = null;
                      }
                    });
                    print(orderedList);
                  },
                ),
                IconButton(
                  //delete
                  icon: Icon(Icons.delete),
                  color: Colors.blueGrey,
                  onPressed: () {
                    if (countList > 0 && netPrice > 0) {}
                  },
                ),
              ],
            )
          ],
        ),
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 4,
            color: Colors.grey,
          );
        },
      );

  void showRestaurantInfo() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                height: 150,
                width: 150,
                child: userModel.imageURL == null || userModel.imageURL.isEmpty
                    ? Center(
                        child: CenterTitle().centerTitle14(context, 'No image'),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          '${Constants().url}${userModel.imageURL}',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${userModel.restaurantName}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue[800]),
                  ),
                  Text(
                    '${userModel.restaurantPhone}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue[800]),
                  ),
                ],
              ),
            ],
          );
        });
  }

  //methods
  Future<void> getMenu() async {
    // print(userModel.id);
    String urlGetFoodWhereOwnerID =
        '${Constants().url}/getFoodWhereOwnerID.php?isAdd=true&ownerID=${userModel.id}';

    await Dio().get(urlGetFoodWhereOwnerID).then((value) {
      var allMenu = json.decode(value.data);

      for (var menu in allMenu) {
        MenuModel menuModel = MenuModel.fromJson(menu);

        setState(() {
          menuLists.add(menuModel);
          infoLoaded = true;
        });
      }
    });
  }
}
