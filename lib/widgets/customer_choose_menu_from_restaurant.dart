import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ramon/models/menu_model.dart';
import 'package:ramon/models/user_model.dart';
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

  List orderedListID = List();
  List orderedListName = List();
  List orderedListPrice = List();
  List orderedListImageURL = List();

  bool infoLoaded = false;

  double netPrice = 0;
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
            onPressed: () {},
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
                var map = Map();
                var listMap = List();
                orderedListID.forEach((element) {
                  if (!map.containsKey(element)) {
                    map[element] = 1;
                  } else {
                    map[element] += 1;
                  }
                });
                print(map);

                orderedListID.length == 0
                    ? Dialogs().normalDialog(context,
                        'You haven\'t chosen any menu yet!', Colors.black87)
                    : showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Review your order',
                              style: TextStyle(color: Colors.deepOrangeAccent),
                            ),
                            content: ListView.separated(
                              itemCount: orderedListID.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 27,
                                    backgroundColor: Colors.yellow[800],
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage(
                                          orderedListImageURL[index]),
                                    ),
                                  ),
                                  title:
                                      Text(orderedListName[index].toString()),
                                );
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
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  //show content

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
                  icon: Icon(Icons.add),
                  color: Colors.green,
                  onPressed: () {
                    setState(() {
                      countList++;
                      netPrice += double.parse(menuLists[index].price);
                      var menuID = menuLists[index].id;
                      var menuName = menuLists[index].name;
                      var menuPrice = menuLists[index].price; //String
                      var menuImageURL =
                          '${Constants().url}${menuLists[index].foodImageURL}';
                      orderedListID.add(menuID);
                      orderedListName.add(menuName);
                      orderedListPrice.add(menuPrice);
                      orderedListImageURL.add(menuImageURL);
                      print(orderedListID);
                      print(orderedListName);
                      print(orderedListPrice);
                      print(orderedListImageURL);
                      print('-----------');
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.blueGrey,
                  onPressed: () {
                    if (countList > 0 && netPrice > 0) {
                      var thisFoodID = orderedListID.firstWhere(
                          (element) => element == menuLists[index].id,
                          orElse: () => Dialogs().normalDialog(
                              context,
                              'There is no this menu in your order',
                              Colors.black87));
                      if (thisFoodID == menuLists[index].id) {
                        var thisFoodName = orderedListName.firstWhere(
                            (element) => element == menuLists[index].name);
                        var thisFoodPrice = orderedListPrice.firstWhere(
                            (element) => element == menuLists[index].price);
                        var thisFoodImageURL = orderedListImageURL.firstWhere(
                            (element) =>
                                element ==
                                '${Constants().url}${menuLists[index].foodImageURL}');
                        setState(() {
                          countList--;
                          netPrice -= double.parse(menuLists[index].price);
                          orderedListID.remove(thisFoodID);
                          orderedListName.remove(thisFoodName);
                          orderedListPrice.remove(thisFoodPrice);
                          orderedListImageURL.remove(thisFoodImageURL);
                          print(orderedListID);
                          print(orderedListName);
                          print(orderedListPrice);
                          print(orderedListImageURL);
                        });
                      }
                    }
                  },
                ),
                Container(
                  child: Text(''),
                )
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
