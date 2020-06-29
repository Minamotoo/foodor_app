import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ramon/models/user_models.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/dialogs.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OwnerEditInfo extends StatefulWidget {
  @override
  _OwnerEditInfoState createState() => _OwnerEditInfoState();
}

class _OwnerEditInfoState extends State<OwnerEditInfo> {
  //variables----------------------------------------------------------
  String restaurantName, restaurantPhone, restaurantAddress, imageURL;
  double lat, lng;
  String preLat, preLng;
  bool infoLoaded = false;
  bool saving = false;

  UserModel userModel;
  File file;

  //init state----------------------------------------------------------
  @override
  void initState() {
    super.initState();
    getInfo();
  }

  //build----------------------------------------------------------
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
          actions: <Widget>[
            FlatButton(
              child: Text(
                'SAVE',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                confirmDialog();
              },
            )
          ],
          title: Text('Update info'),
        ),
        body:
            //Center(
            //   child: Text('aasdfasdf'),
            // )
            saving == false
                ? infoLoaded == false
                    ? Loading().showLoading()
                    : checkIfInfoAvailable()
                : Loading().showSaving(),
      ),
    );
  }

  //method----------------------------------------------------------
  Future<void> getInfo() async {
    bool gpsServiceStatus = await Geolocator().isLocationServiceEnabled();

    if (gpsServiceStatus == false) {
      normalDialog(
          context, 'Please turn on GPS then restart apllication', Colors.brown);
    } else {
      var currentLocation = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String id = sharedPreferences.getString('id');
      String url = '${Constants().url}/getUserWhereID.php?isAdd=true&id=$id';

      Response response = await Dio().get(url);

      var result = json.decode(response.data.toString());
      print('before: $infoLoaded');
      // print(result);

      for (var item in result) {
        setState(() {
          userModel = UserModel.fromJson(item);

          restaurantName = userModel.restaurantName.trim();
          restaurantPhone = userModel.restaurantPhone.trim();
          restaurantAddress = userModel.restaurantAddress.trim();
          imageURL = userModel.imageURL.trim();

          if (userModel.lat.isEmpty ||
              userModel.lng.isEmpty ||
              userModel.lat == null ||
              userModel.lng == null) {
            lat = currentLocation.latitude;
            lng = currentLocation.longitude;

            print('no lat: $lat');
            print('no lng: $lng');
          } else {
            lat = double.parse(userModel.lat);
            lng = double.parse(userModel.lng);

            print('no lat: $lat');
            print('no lng: $lng');
          }
          infoLoaded = true;
        });
        print('after: $infoLoaded');
        print('after: $lat');
        print('after: $lng');
      }
    }
  }

  checkIfInfoAvailable() {
    //if there is no info
    if (restaurantName.isEmpty &&
        restaurantPhone.isEmpty &&
        restaurantAddress.isEmpty &&
        imageURL.isEmpty) {
      return Center(
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: ListView(
              children: <Widget>[
                Container(
                    height: 230,
                    width: 230,
                    child: file == null
                        ? CenterTitle().centerTitle16(
                            context, 'No image, tap below button to add')
                        : Image.file(file)),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.all(10),
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          //To take photo
                          chooseImage(ImageSource.camera);
                        },
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      IconButton(
                        padding: EdgeInsets.all(10),
                        icon: Icon(Icons.add_photo_alternate),
                        onPressed: () {
                          //To select photo from gallery
                          chooseImage(ImageSource.gallery);
                        },
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
                //-------------------------------------------------------------------------
                Material(
                  child: TextField(
                    onChanged: (value) => restaurantName = value.trim(),
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.home,
                          color: Colors.black54,
                        ),
                        labelText: 'Restaurant name'),
                  ),
                ),
                Material(
                  child: TextField(
                    onChanged: (value) => restaurantPhone = value.trim(),
                    maxLength: 10,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.black54,
                        ),
                        labelText: 'Phone number'),
                  ),
                ),
                Material(
                  child: TextField(
                    onChanged: (value) => restaurantAddress = value.trim(),
                    maxLines: 3,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.map,
                          color: Colors.black54,
                        ),
                        labelText: 'Address'),
                  ),
                ),
                Container(
                    width: 250,
                    height: 300,
                    margin: EdgeInsets.only(bottom: 70),
                    child: showMap())
              ],
            )),
      );
    } else {
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: ListView(
            children: <Widget>[
              //image-----------------------------------------------------------
              Container(
                  height: 230,
                  width: 230,
                  child: file == null
                      ? imageURL.isEmpty
                          ? CenterTitle().centerTitle16(
                              context, 'No image, tap below button to add')
                          : Image.network(imageURL)
                      : Image.file(file)),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.all(10),
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        //To take photo
                        chooseImage(ImageSource.camera);
                      },
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    IconButton(
                      padding: EdgeInsets.all(10),
                      icon: Icon(Icons.add_photo_alternate),
                      onPressed: () {
                        //To select photo from gallery
                        chooseImage(ImageSource.gallery);
                      },
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
                          imageURL = '';
                        });
                      },
                    ),
                  ],
                ),
              ),

              //name-----------------------------------------------------------
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Name',
                      focusColor: Colors.brown,
                      border: OutlineInputBorder(),
                      labelText: 'Restaurant Name'),
                  initialValue: restaurantName.isEmpty ? '' : restaurantName,
                  onChanged: ((value) => restaurantName = value.trim()),
                ),
              ),
              //phone number-----------------------------------------------------------
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Phone',
                      focusColor: Colors.brown,
                      border: OutlineInputBorder(),
                      labelText: 'Phone'),
                  initialValue: restaurantPhone.isEmpty ? '' : restaurantPhone,
                  onChanged: ((value) => restaurantPhone = value.trim()),
                ),
              ),
              //address-----------------------------------------------------------
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                      hintText: 'Address',
                      focusColor: Colors.brown,
                      border: OutlineInputBorder(),
                      labelText: 'Address'),
                  initialValue:
                      restaurantAddress.isEmpty ? '' : restaurantAddress,
                  onChanged: ((value) => restaurantAddress = value.trim()),
                ),
              ),
              //mapp-----------------------------------------------------------
              Container(
                margin: EdgeInsets.only(bottom: 60),
                width: 280,
                height: 350,
                child: lat == null && lng == null
                    ? Loading().showLoading()
                    : showMap(),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> chooseImage(ImageSource imageSource) async {
    try {
      var imagePicker = await ImagePicker.pickImage(
          source: imageSource, maxHeight: 800, maxWidth: 800);

      setState(() {
        file = imagePicker;
        print('after: $file');
      });
    } catch (e) {}
  }

  showMap() {
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
    return <Marker>[
      Marker(
        markerId: MarkerId('myMarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
            title: restaurantName.isEmpty
                ? 'Your current position!'
                : restaurantName,
            snippet: '$lat, $lng'),
      )
    ].toSet();
  }

  confirmDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Saving process'),
            content: Text(
                'Do you want to save current location to be your restaurant\'s location? We recommend to confirm if this is the first time you\'re here'),
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
                    'OK, save it',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onUpdateLocation();
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
                    'No, just save info',
                    style: TextStyle(color: Colors.brown),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onUpdateNoLocation();
                  },
                ),
              ),
            ],
          );
        });
  }

  onUpdateLocation() async {
    setState(() {
      saving = true;
    });

    //get userID
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userID = sharedPreferences.getString('id');

    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    lat = currentLocation.latitude;
    lng = currentLocation.longitude;

    //if didnt pick image
    if (file == null) {
      // print(imageURL);
      String urlNoimage =
          '${Constants().url}/editUserInfo.php?isAdd=true&id=$userID&restaurantName=$restaurantName&restaurantPhone=$restaurantPhone&restaurantAddress=$restaurantAddress&imageURL=$imageURL&lat=$lat&lng=$lng';

      Response response = await Dio().get(urlNoimage);
      if (response.toString() == 'true') {
        print('Saved no new pick');
        Navigator.pop(context);
      } else {
        print('not saved, something wrong');
      }
    } else {
      //save image process below
      Random random = Random();
      int randomNum = random.nextInt(1000000);
      String imageFileName = 'shop$randomNum.jpg';

      Map<String, dynamic> map = Map();
      map['file'] =
          await MultipartFile.fromFile(file.path, filename: imageFileName);

      FormData formData = FormData.fromMap(map);

      String imageUploadedURL = '${Constants().url}/saveFile.php';
      await Dio().post(imageUploadedURL, data: formData).then((value) async {
        imageURL = '${Constants().url}/owner/$imageFileName';
      });

      String usrImage =
          '${Constants().url}/editUserInfo.php?isAdd=true&id=$userID&restaurantName=$restaurantName&restaurantPhone=$restaurantPhone&restaurantAddress=$restaurantAddress&imageURL=$imageURL&lat=$lat&lng=$lng';

      Response response = await Dio().get(usrImage);

      if (response.toString() == 'true') {
        print('Saved with pick');
        Navigator.pop(context);
      } else {
        print('not saved, something wrong');
      }
    }
  }

  onUpdateNoLocation() async {
    setState(() {
      saving = true;
    });

    //get userID
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userID = sharedPreferences.getString('id');

    //if didnt pick image
    if (file == null) {
      // print(imageURL);
      String urlNoimage =
          '${Constants().url}/editUserInfo.php?isAdd=true&id=$userID&restaurantName=$restaurantName&restaurantPhone=$restaurantPhone&restaurantAddress=$restaurantAddress&imageURL=$imageURL&lat=$lat&lng=$lng';

      Response response = await Dio().get(urlNoimage);
      if (response.toString() == 'true') {
        print('Saved no new pick/ no location');
        Navigator.pop(context);
      } else {
        print('not saved, something wrong');
      }
    } else {
      //save image process below
      Random random = Random();
      int randomNum = random.nextInt(1000000);
      String imageFileName = 'shop$randomNum.jpg';

      Map<String, dynamic> map = Map();
      map['file'] =
          await MultipartFile.fromFile(file.path, filename: imageFileName);

      FormData formData = FormData.fromMap(map);

      String imageUploadedURL = '${Constants().url}/saveFile.php';
      await Dio().post(imageUploadedURL, data: formData).then((value) async {
        imageURL = '${Constants().url}/owner/$imageFileName';
      });

      String usrImage =
          '${Constants().url}/editUserInfo.php?isAdd=true&id=$userID&restaurantName=$restaurantName&restaurantPhone=$restaurantPhone&restaurantAddress=$restaurantAddress&imageURL=$imageURL&lat=$lat&lng=$lng';

      Response response = await Dio().get(usrImage);

      if (response.toString() == 'true') {
        print('Saved with pick/ no location');
        Navigator.pop(context);
      } else {
        print('not saved, something wrong');
      }
    }
  }
}
