import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ramon/models/menu_model.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:ramon/utilities/dialogs.dart';
import 'package:ramon/widgets/owner_add_menu.dart';
import 'package:ramon/widgets/owner_edit_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerMenu extends StatefulWidget {
  @override
  _OwnerMenuState createState() => _OwnerMenuState();
}

class _OwnerMenuState extends State<OwnerMenu> {
  //variables
  bool infoLoaded = false;
  bool deleting = false;
  bool updating = false;

  String ownerID;
  List<MenuModel> listFood = List();

  var loopContent;

  // bool saving = false;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.brown,
        title: Text('Menu'),
        //TODO: add serch function
        // actions: <Widget>[
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(Icons.search),
        //   )
        // ],
      ),
      body: Container(
        margin: EdgeInsets.only(bottom: 70),
        child: deleting == true || updating == true
            ? Loading().showProcess()
            : infoLoaded == false ? Loading().showLoading() : isInfoAvailable(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          listFood.clear();
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OwnerAddMenu()))
              .then((value) => reload());
        },
      ),
    );
  }

  //methods

  isInfoAvailable() {
    if (loopContent == null) {
      return showNoInfo(context);
    } else {
      return showInfo();
    }
  }

  Future<void> getInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String ownerID = sharedPreferences.getString('id');
    String url =
        '${Constants().url}/getFoodWhereOwnerID.php?isAdd=true&ownerID=$ownerID';

    Response response = await Dio().get(url);

    if (response.toString() == 'null') {
      setState(() {
        loopContent = null;
        infoLoaded = true;
      });
    } else {
      var result = json.decode(response.data.toString());
      loopContent = result;

      for (var item in result) {
        MenuModel menuModel = MenuModel.fromJson(item);
        setState(() {
          listFood.add(menuModel);
          infoLoaded = true;
        });
      }
    }
  }

  Future<void> confirmDelete(String foodID, String foodName) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm deleting process'),
            content: Text(
                'Do you really want to delete \"$foodName\", this process is uncancelable'),
            actions: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.brown),
                  ),
                  color: Colors.brown,
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete(foodID);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.brown),
                  ),
                  color: Colors.white,
                  child: Text(
                    'Dismiss',
                    style: TextStyle(color: Colors.brown),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        });
  }

  onDelete(String getFoodID) async {
    String url = '${Constants().url}/deleteFood.php?isAdd=true&id=$getFoodID';
    setState(() {
      listFood.clear();
      deleting = true;
    });

    try {
      await Dio().get(url).then((value) => reload());
      setState(() {
        deleting = false;
      });
    } catch (e) {
      print(e);
    }
  }

  // Future<void> confirmReload(String foodID, String foodName)

  //create content-----------------------------------------------------------------
  Center showNoInfo(BuildContext context) => CenterTitle().centerTitle(
      context, 'There is no menu yet, tap \'Add\' icon below to add some');

  Widget showInfo() => ListView.builder(
        itemCount: listFood.length,
        itemBuilder: (context, index) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //image
            InkWell(
              onTap: () {
                //on update
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OwnerEditMenu(
                      menuModel: listFood[index],
                    ),
                  ),
                ).then((value) {
                  setState(() {
                    listFood.clear();
                  });
                  reload();
                });
              },
              child: Container(
                padding: EdgeInsets.all(10),
                width: 170,
                height: 170,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    '${Constants().url}${listFood[index].foodImageURL}',
                    fit: BoxFit.cover,
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
                    Text(
                      '${listFood[index].name}',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: CupertinoColors.systemBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${listFood[index].price} THB.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: CupertinoColors.systemRed,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      child: Text(
                        '${listFood[index].description}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        listFood[index].promotionStatus == '1'
                            ? IconButton(
                                icon: Icon(Icons.star),
                                color: Colors.yellow[800],
                                onPressed: () {
                                  Dialogs().normalDialog(
                                      context,
                                      'Promotion: ${listFood[index].promotionDetail}',
                                      Colors.brown);
                                },
                              )
                            : IconButton(
                                icon: Icon(Icons.star),
                                color: Colors.white,
                                onPressed: () {},
                              ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            //on update
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OwnerEditMenu(
                                  menuModel: listFood[index],
                                ),
                              ),
                            ).then((value) {
                              setState(() {
                                listFood.clear();
                              });
                              reload();
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            //on del
                            confirmDelete('${listFood[index].id}',
                                '${listFood[index].name}');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  //reload after add menu
  reload() async {
    setState(() {
      infoLoaded = false;
    });
    getInfo();
  }
}
