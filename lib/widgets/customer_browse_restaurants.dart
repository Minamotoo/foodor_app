import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ramon/models/menu_model.dart';
import 'package:ramon/models/user_model.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:ramon/widgets/customer_choose_menu_from_restaurant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerBrowseRestaurant extends StatefulWidget {
  @override
  _CustomerBrowseRestaurantState createState() =>
      _CustomerBrowseRestaurantState();
}

class _CustomerBrowseRestaurantState extends State<CustomerBrowseRestaurant> {
  //variables
  bool infoLoaded = false;
  List<UserModel> restaurantLists = List();
  List<List<String>> foodPromotionStatus = List();

  var listOfAllFood;
  @override
  void initState() {
    super.initState();
    getAllRestaurant();
  }

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
          backgroundColor: Colors.black87,
          title: Text('Browse restaurants'),
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: infoLoaded == false
              ? Loading().showLoading()
              // : showRestaurant()),
              : showRestaurant(),
        ),
      ),
    );
  }

  //method----------------------------------------------------------
  Future<void> getAllRestaurant() async {
    String url =
        '${Constants().url}/getUserWhereUserIsOwner.php?isAdd=true&userType=owner';

    await Dio().get(url).then((value) async {
      var result = json.decode(value.data);

      for (var item in result) {
        UserModel userModel = UserModel.fromJson(item);
        String restaurantName = userModel.restaurantName;

        //--------------------------------------------------------------------------///
        //get food of this owner
        String urlGetFoodWhereOwnerID =
            '${Constants().url}/getFoodWhereOwnerID.php?isAdd=true&ownerID=${userModel.id}';
        //--------------------------------------------------------------------------///

        //set for show content of all restaurant
        if (restaurantName.isNotEmpty) {
          setState(() {
            restaurantLists.add(userModel);
            infoLoaded = true;
          });
        }
      }
    });
  }

  Widget showRestaurant() => ListView.separated(
        itemCount: restaurantLists.length,
        itemBuilder: (contxt, index) => Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //image
                Material(
                  child: InkWell(
                    onTap: () async {
                      SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      String customerID = sharedPreferences.getString('id');
                      String customerName = sharedPreferences.getString('name');
                      String customerPhone =
                          sharedPreferences.getString('phone');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomerChooseMenuFromRestaurant(
                            customerID: customerID,
                            customerName: customerName,
                            customerPhone: customerPhone,
                            userModel: restaurantLists[index],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: 150,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: restaurantLists[index].imageURL.isEmpty
                            ? CenterTitle().centerTitle16(
                                context, 'This restaurant has no image')
                            : Image.network(
                                '${Constants().url}${restaurantLists[index].imageURL}',
                                fit: BoxFit.cover,
                              ),
                      ),
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
                          //res name-------------------------------------------------
                          Material(
                            child: InkWell(
                              onTap: () async {
                                SharedPreferences sharedPreferences =
                                    await SharedPreferences.getInstance();
                                String customerID =
                                    sharedPreferences.getString('id');
                                String customerName =
                                    sharedPreferences.getString('name');
                                String customerPhone =
                                    sharedPreferences.getString('phone');

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CustomerChooseMenuFromRestaurant(
                                      customerID: customerID,
                                      customerName: customerName,
                                      customerPhone: customerPhone,
                                      userModel: restaurantLists[index],
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                '${restaurantLists[index].restaurantName}',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: CupertinoColors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          //TODO: do promotion code here

                          // foodLists[index].ownerID == restaurantLists[index].id
                          //     ? foodLists[index].promotionStatus == '1'
                          //         ? Text(
                          //             'Promotion!',
                          //             style: TextStyle(
                          //               color: Colors.yellow[800],
                          //             ),
                          //           )
                          //         : Text('No promotion')
                          //     : SizedBox(),

                          //res phone-------------------------------------------------
                          SelectableText(
                            '${restaurantLists[index].restaurantPhone}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: CupertinoColors.activeBlue,
                              fontSize: 18,
                            ),
                          ),

                          //res desc-------------------------------------------------
                          SelectableText(
                            '${restaurantLists[index].restaurantDescription}',
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
            ),
          ],
        ),
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 10,
            color: Colors.black,
          );
        },
      );
}
