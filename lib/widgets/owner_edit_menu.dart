import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ramon/models/menu_model.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/dialogs.dart';
import 'package:ramon/utilities/loading.dart';

class OwnerEditMenu extends StatefulWidget {
  //final
  final MenuModel menuModel;
  OwnerEditMenu({Key key, this.menuModel}) : super(key: key);

  @override
  _OwnerEditMenuState createState() => _OwnerEditMenuState();
}

class _OwnerEditMenuState extends State<OwnerEditMenu> {
  //variables
  MenuModel menuModel;

  bool infoLoaded = false;
  bool updating = false;
  bool deletedImage = false;

  File file;

  String newFoodImageURL, newName, newPrice, newDescription;

  //init state
  @override
  void initState() {
    super.initState();
    menuModel = widget.menuModel;
    newFoodImageURL = menuModel.foodImageURL;
    newName = menuModel.name;
    newPrice = menuModel.price;
    newDescription = menuModel.description;

    print('new alone $newFoodImageURL');
    print('from last page ${menuModel.foodImageURL}');

    // loadingInfo();
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
            backgroundColor: Colors.brown,
            title: Text('Update ${menuModel.name}'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'SAVE',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  onCheck();
                },
              ),
            ],
          ),
          body: updating == true ? Loading().showSaving() : showContent(context)
          // infoLoaded == true ? Loading().showLoading() : loadingInfo(),
          ),
    );
  }

  //create content
  Center showContent(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: ListView(
          children: <Widget>[
            //image
            Container(
              height: 230,
              width: 230,
              child: file == null
                  ? '${Constants().url}${menuModel.foodImageURL}'.isEmpty ||
                          '${Constants().url}${menuModel.foodImageURL}' == null
                      ? CenterTitle()
                          .centerTitle16(context, 'No image, no file chosen')
                      : deletedImage == true
                          ? CenterTitle().centerTitle16(
                              context, 'No image, no file chosen')
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                '${Constants().url}${menuModel.foodImageURL}',
                                fit: BoxFit.cover,
                              ),
                            )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        file,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.all(10),
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => chooseImage(ImageSource.camera),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    padding: EdgeInsets.all(10),
                    icon: Icon(Icons.add_photo_alternate),
                    onPressed: () => chooseImage(ImageSource.gallery),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    padding: EdgeInsets.all(10),
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      //delete image
                      setState(() {
                        file = null;
                        deletedImage = true;
                      });
                    },
                  ),
                ],
              ),
            ),

            //name
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Material(
                child: TextFormField(
                  onChanged: (value) => newName = value.trim(),
                  initialValue: menuModel.name,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.restaurant,
                        color: Colors.black54,
                      ),
                      labelText: 'Name'),
                ),
              ),
            ),

            //price
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Material(
                child: TextFormField(
                  onChanged: (value) => newPrice = value.trim(),
                  keyboardType: TextInputType.number,
                  initialValue: menuModel.price,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: Colors.black54,
                      ),
                      labelText: 'Price'),
                ),
              ),
            ),

            //desc
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Material(
                child: TextFormField(
                  onChanged: (value) => newDescription = value.trim(),
                  initialValue: menuModel.description,
                  maxLines: 4,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.description,
                        color: Colors.black54,
                      ),
                      labelText: 'Description'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //methods
  Future<void> chooseImage(ImageSource imageSource) async {
    try {
      var imagePicker = await ImagePicker()
          .getImage(source: imageSource, maxWidth: 800, maxHeight: 800);

      setState(() {
        file = File(imagePicker.path);
        deletedImage = false;
        print('after: $file');
      });
    } catch (e) {}
  }

  void onCheck() {
    if (newName.isEmpty || newPrice.isEmpty) {
      Dialogs().alertDialog(
          context,
          'Input validation!',
          'Please check your input again, \'Name\' and \'Price\' must be filled',
          Colors.brown);
    } else if (file == null && deletedImage == true) {
      Dialogs().alertDialog(
          context,
          'Please add image',
          'You should let customer know what does the menu look, back to select an image for it',
          Colors.brown);
    } else {
      confirmUpdate('${menuModel.id}', newName, newPrice, newDescription,
          newFoodImageURL);
    }
  }

  Future<void> confirmUpdate(String id, String newName, String newPrice,
      String newDescription, String newFoodImageURL) async {
    print(newFoodImageURL);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm updating process'),
            content: Text(
                'Do you want to update \"${menuModel.name}\" with your new info ?'),
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
                    onUpdate(
                        id, newName, newPrice, newDescription, newFoodImageURL);
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

  onUpdate(String id, String newName, String newPrice, String newDescription,
      String newFoodImageURL) async {
    setState(() {
      updating = true;
    });
    // print(file);
    // print(deletedImage);
    // print(id);
    // print(newName);
    // print(newPrice);
    // print(newDescription);
    // print(newFoodImageURL);
    double newPriceDouble = double.parse(newPrice);
    String newFoodImageUploadURL = '${Constants().url}/editImageFood.php';

    Random random = Random();
    int randomNum = random.nextInt(1000000);
    String newImageFileName = 'food$randomNum.jpg';

    if (file != null) {
      Map<String, dynamic> map = Map();
      map['file'] =
          await MultipartFile.fromFile(file.path, filename: newImageFileName);

      print('map: $map');

      FormData formData = FormData.fromMap(map);

      await Dio()
          .post(newFoodImageUploadURL, data: formData)
          .then((value) => newFoodImageURL = '/foods/$newImageFileName');

      print('picked image');
    }

    //upload data
    String url =
        '${Constants().url}/editFoodWhereID.php/?isAdd=true&id=$id&newName=$newName&newPrice=$newPriceDouble&newDescription=$newDescription&newFoodImageURL=$newFoodImageURL';

    try {
      await Dio().get(url).then((value) {
        if (value.toString() == 'true') {
          setState(() {
            newName = '';
            newPrice = '';
            newDescription = '';
            newFoodImageURL = '';
          });
          Navigator.pop(context);
        } else {
          Dialogs().alertDialog(context, 'Error!',
              'Something\'s wrong, try again later', Colors.brown);
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
