import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ramon/models/menu_model.dart';
import 'package:ramon/models/user_model.dart';
import 'package:ramon/models/ordered_menu_model.dart';
import 'package:ramon/pages/customer.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/dialogs.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:ramon/widgets/customer_orders.dart';

class CustomerChooseMenuFromRestaurant extends StatefulWidget {
  //final and constructor
  final UserModel userModel;
  final customerID, customerName, customerPhone;

  const CustomerChooseMenuFromRestaurant(
      {Key key,
      this.userModel,
      this.customerID,
      this.customerName,
      this.customerPhone})
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
  String customerID;
  String customerName;
  String customerPhone;

  List<OrderedMenuModel> orderedList = List();

  bool infoLoaded = false;
  bool foundDuplicate = false;
  bool noMenu = false;

  int netPrice = 0;
  int countList = 0;

  int netPriceDuplicate = 0;
  int countDuplicate = 0;

  //inistate
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userModel = widget.userModel;
    customerID = widget.customerID;
    customerName = widget.customerName;
    customerPhone = widget.customerPhone;

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
              : noMenu == false ? showMenuOfRestaurant() : showNoMenu()),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 30, right: 15),
        color: Colors.black87,
        alignment: Alignment.center,
        height: 50,
        child: noMenu == true ? Container() : showPrice(context),
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
                  //add
                  icon: Icon(Icons.add),
                  color: Colors.green,
                  onPressed: () {
                    addMenu(index);
                  },
                ),
                IconButton(
                  //delete
                  icon: Icon(Icons.delete),
                  color: Colors.blueGrey,
                  onPressed: () {
                    deleteMenu(index);
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

  void deleteMenu(int index) {
    setState(() {
      if (countList > 0 && netPrice > 0) {
        String thisMenuID = menuLists[index].id;
        String thisMenuName = menuLists[index].name;
        String thisMenuOwnerID = menuLists[index].ownerID;
        double doublePrice = double.parse(menuLists[index].price);
        int thisMenuPrice = doublePrice.toInt();
        int thisMenuAmount = 1;
        String thisFoodImageURL = menuLists[index].foodImageURL;

        OrderedMenuModel om = OrderedMenuModel();

        int priceDuplicate = 0;

        om.id = thisMenuID;
        om.name = thisMenuName;
        om.price = thisMenuPrice;
        om.ownerID = thisMenuOwnerID;
        om.amount = thisMenuAmount;
        om.foodImageURL = thisFoodImageURL;

        for (var ol in orderedList) {
          if (ol.id == om.id) {
            countList--;
            priceDuplicate = ol.price;
            foundDuplicate = true;

            break;
          } else {
            foundDuplicate = false;
          }
        }

        // if (foundDuplicate == false) {
        //   countList--;
        //   netPrice -= om.price;
        // }

        orderedList.removeWhere((element) => element.id == '${om.id}');

        netPrice -= priceDuplicate;
        priceDuplicate = 0;
        // print(countDuplicate); //ได้ค่านับว่ามีซ้ำกันกี่เมนู
        // print(netPriceDuplicate); //ได้ราคาของเมนูที่ซ้ำกัน
      }
    });
  }

  void addMenu(int index) {
    String thisMenuID = menuLists[index].id;
    String thisMenuName = menuLists[index].name;
    String thisMenuOwnerID = menuLists[index].ownerID;
    double doublePrice = double.parse(menuLists[index].price);
    int thisMenuPrice = doublePrice.toInt();
    int thisMenuAmount = 1;
    String thisFoodImageURL = menuLists[index].foodImageURL;

    setState(() {
      if (countList >= 0) {
        if (orderedList.length == 0) {
          OrderedMenuModel om = OrderedMenuModel();

          om.id = thisMenuID;
          om.name = thisMenuName;
          om.price = thisMenuPrice;
          om.ownerID = thisMenuOwnerID;
          om.amount = thisMenuAmount;
          om.foodImageURL = thisFoodImageURL;

          countList++;
          netPrice += thisMenuPrice;

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
              netPriceDuplicate = om.price;

              ++countDuplicate;
              netPriceDuplicate += om.price;

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
            countList++;
            netPrice += om.price;
            orderedList.add(toAdd);
          } else {
            netPrice += om.price;
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

        foundDuplicate = false;
      }
    });
  }

  Widget showNoMenu() => Container(
        child: Center(
          child: CenterTitle()
              .centerTitle(context, 'There is no any menu available yet'),
        ),
      );

  Row showPrice(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        InkWell(
          onTap: () {
            orderedList.length == 0
                ? Dialogs().normalDialog(context,
                    'You haven\'t chosen any menu yet!', Colors.black87)
                : reviewOrders(context);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Menu chosen: $countList',
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
            orderedList.length == 0
                ? Dialogs().normalDialog(context,
                    'You haven\'t chosen any menu yet!', Colors.black87)
                : reviewOrders(context);
          },
        ),
      ],
    );
  }

  Future reviewOrders(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Review your orders',
            style: TextStyle(color: Colors.deepOrangeAccent),
          ),
          content: Container(
            height: 800,
            width: 300,
            child: ListView.separated(
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
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 4,
                  color: Colors.grey,
                );
              },
            ),
          ),
          actions: <Widget>[
            RaisedButton(
                child: Text(
                  'C O N F I R M',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                onPressed: () {
                  onConfirmOrder(orderedList);
                })
          ],
        );
      },
    );
  }

  void showRestaurantInfo() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                height: 200,
                width: 150,
                child: userModel.imageURL == null || userModel.imageURL.isEmpty
                    ? Center(
                        child: CenterTitle().centerTitle14(context, 'No image'),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          '${Constants().url}${userModel.imageURL}',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    Text(
                      '${userModel.restaurantAddress}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey),
                    ),
                    Container(
                        alignment: Alignment.center,
                        height: 170,
                        width: 250,
                        child: userModel.lat == null ||
                                userModel.lng == null ||
                                userModel.lat.isEmpty ||
                                userModel.lng.isEmpty
                            ? CenterTitle()
                                .centerTitle14(context, 'No location info')
                            : showMap()),
                  ],
                ),
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
      if (allMenu == '0') {
        setState(() {
          infoLoaded = true;
          noMenu = true;
        });
        showNoMenu();
      } else {
        // print('111111');
        for (var menu in allMenu) {
          MenuModel menuModel = MenuModel.fromJson(menu);

          setState(() {
            menuLists.add(menuModel);
            infoLoaded = true;
          });
        }
      }
    });
  }

  showMap() {
    double lat = double.tryParse(userModel.lat);
    double lng = double.tryParse(userModel.lng);
    CameraPosition cameraPosition =
        CameraPosition(target: LatLng(lat, lng), zoom: 16);

    return GoogleMap(
      initialCameraPosition: cameraPosition,
      mapType: MapType.normal,
      onMapCreated: (controller) {},
      markers: marker(),
    );
  }

  Set<Marker> marker() {
    double lat = double.tryParse(userModel.lat);
    double lng = double.tryParse(userModel.lng);
    return <Marker>[
      Marker(
        markerId: MarkerId('myMarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
            title: userModel.restaurantName.isEmpty ||
                    userModel.restaurantName == null
                ? 'They\'re here!'
                : userModel.restaurantName.toString(),
            snippet: '$lat, $lng'),
      )
    ].toSet();
  }

  void onConfirmOrder(List<OrderedMenuModel> orderedList) async {
    var orderedJSON = jsonEncode(orderedList.map((e) => e.toJson()).toList());

    FormData formData = FormData.fromMap({
      'customerID': '$customerID',
      'customerName': '$customerName',
      'customerPhone': '$customerPhone',
      'ownerID': '${userModel.id}',
      'paymentStatus': '1',
      'orderDetail': '$orderedJSON',
      'finishStatus': '0',
    });

    // print(orderedJSON);
    String url = '${Constants().url}/addOrders.php';

    var response = await Dio().post(url, data: formData);
    if (response.toString() == '1') {
      FormData formData = FormData.fromMap({
        'ownerID': '${userModel.id}',
        // 'customerID': '$customerID',
      });
      String notiUrl = '${Constants().url}/addNoti.php';

      await Dio().post(notiUrl, data: formData);
      // var responseNoti = await Dio().post(notiUrl, data: formData);
      // print(responseNoti.toString());
    }

    // await Dio().post(url, data: formData).then((value) async {
    //   Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(builder: (context) => Customer()),
    //       (route) => false);
    // });
  }
}
