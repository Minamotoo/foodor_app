import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/dialogs.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerAddMenu extends StatefulWidget {
  @override
  _OwnerAddMenuState createState() => _OwnerAddMenuState();
}

class _OwnerAddMenuState extends State<OwnerAddMenu> {
  //variables
  File file;
  String ownerID = '';
  String foodImageURL = '';
  String name = '';
  String description = '';
  double price = 0;
  bool saving = false;
  //init state

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
          centerTitle: true,
          title: Text('Add menu'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'SAVE',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                //TODO: ไว้กลับมาทำกรณีที่แก้ไขอาหารแบบไม่เปลี่ยนภาพด้วย
                file == null || name.isEmpty || price == 0
                    ? onCheck()
                    : onSaveWithImage();
              },
            )
          ],
        ),
        body: saving == false ? showContent(context) : Loading().showSaving(),
      ),
    );
  }

  //show content

  Center showContent(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: ListView(
          children: <Widget>[
            //image
            Container(
              // color: Colors.yellow[300],
              height: 230,
              width: 230,
              child: file == null
                  ? CenterTitle()
                      .centerTitle16(context, 'Tap button to add image of menu')
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
                child: TextField(
                  onChanged: (value) => name = value.trim(),
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
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) => price = double.parse(value.trim()),
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: Colors.black54,
                      ),
                      labelText: 'Price (THB)'),
                ),
              ),
            ),

            //desc
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Material(
                child: TextField(
                  onChanged: (value) => description = value.trim(),
                  maxLines: 4,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.description,
                        color: Colors.black54,
                      ),
                      labelText: 'Some description'),
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
        print('after: $file');
      });
    } catch (e) {}
  }

  onCheck() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content:
                Text('Please input atleast \'Image\',  \'Name\' and \'Price\''),
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
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // onUpdateLocation();
                  },
                ),
              ),
            ],
          );
        });
  }

  Future<void> onSaveWithImage() async {
    setState(() {
      saving = true;
    });
    String foodImageUploadURL = '${Constants().url}/saveFood.php';

    Random random = Random();
    int randomNum = random.nextInt(1000000);
    String imageFileName = 'food$randomNum.jpg';

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    ownerID = sharedPreferences.getString('id');

    try {
      Map<String, dynamic> map = Map();
      map['file'] =
          await MultipartFile.fromFile(file.path, filename: imageFileName);

      FormData formData = FormData.fromMap(map);

      await Dio().post(foodImageUploadURL, data: formData).then((value) async {
        foodImageURL = '/foods/$imageFileName';
        String uploadURL =
            '${Constants().url}/addFood.php?isAdd=true&ownerID=$ownerID&foodImageURL=$foodImageURL&name=$name&price=$price&description=$description';
        print('saved with this image: $foodImageURL');

        await Dio().get(uploadURL).then((value) => Navigator.pop(context));
      });
    } catch (e) {
      print(e);
    }
  }
}
