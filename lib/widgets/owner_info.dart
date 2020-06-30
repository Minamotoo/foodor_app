import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ramon/models/user_models.dart';
import 'package:ramon/utilities/constants.dart';
import 'package:ramon/utilities/dialogs.dart';
import 'package:ramon/utilities/loading.dart';
import 'package:ramon/utilities/center_title.dart';
import 'package:ramon/widgets/owner_edit_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OwnerInfo extends StatefulWidget {
  @override
  _OwnerInfoState createState() => _OwnerInfoState();
}

class _OwnerInfoState extends State<OwnerInfo> {
  //variables-----------------------------------------------------------------------------
  String restaurantName,
      restaurantPhone,
      restaurantAddress,
      restaurantDescription,
      imageURL;
  double lat, lng;
  String preLat, preLng;
  bool infoLoaded = false;
  bool backFromEdit = false;
  UserModel userModel;

  //override stat----------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    getInfo();
  }

  //build-----------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.brown,
        title: Text('Info'),
      ),
      body: infoLoaded == false
          ? Loading().showLoading()
          : checkIfInfoAvailable(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[800],
        child: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OwnerEditInfo()))
              .then((value) => reload());
        },
      ),
    );
  }

  //method-----------------------------------------------------------------------------

  Future<void> getInfo() async {
    bool gpsServiceStatus = await Geolocator().isLocationServiceEnabled();

    if (gpsServiceStatus == false) {
      Dialogs().alertDialog(context, 'GPS is off!',
          'Please turn on GPS then restart apllication', Colors.brown);
    } else {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String id = sharedPreferences.getString('id');
      String url = '${Constants().url}/getUserWhereID.php?isAdd=true&id=$id';

      Response response = await Dio().get(url);

      var result = json.decode(response.data.toString());

      // var currentLocation = await Geolocator()
      //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      for (var item in result) {
        setState(() {
          userModel = UserModel.fromJson(item);

          restaurantName = userModel.restaurantName.trim();
          restaurantPhone = userModel.restaurantPhone.trim();
          restaurantAddress = userModel.restaurantAddress.trim();
          restaurantDescription = userModel.restaurantDescription.trim();
          imageURL = userModel.imageURL.trim();

          if (userModel.lat.isEmpty ||
              userModel.lng.isEmpty ||
              userModel.lat == null ||
              userModel.lng == null) {
            lat = 0;
            lng = 0;
          } else {
            lat = double.parse(userModel.lat);
            lng = double.parse(userModel.lng);
          }
          infoLoaded = true;
        });
      }
    }
  }

  checkIfInfoAvailable() {
    if (restaurantName.isEmpty &&
        restaurantPhone.isEmpty &&
        restaurantAddress.isEmpty &&
        restaurantDescription.isEmpty &&
        '${Constants().url}$imageURL'.isEmpty) {
      return showNoInfo(context);
    } else {
      return showInfo();
    }
  }

  //create content---------------------------------------------------------------------------
  Center showInfo() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: ListView(
          children: <Widget>[
            Container(
              height: 200,
              width: 200,
              child: imageURL == null || imageURL.isEmpty
                  ? Center(
                      child: CenterTitle().centerTitle16(context, 'No image'),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        '${Constants().url}$imageURL',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            //-------------------------------------------------------------------
            Text(
              'Restaurant name: ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue[800]),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 20,
                ),
                Text(
                  userModel.restaurantName.isEmpty ||
                          userModel.restaurantName == null
                      ? '-'
                      : userModel.restaurantName,
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            //-------------------------------------------------------------------
            Text(
              'Restaurant phone: ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue[800]),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 20,
                ),
                Text(
                  userModel.restaurantPhone.isEmpty ||
                          userModel.restaurantPhone == null
                      ? '-'
                      : userModel.restaurantPhone,
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            //-------------------------------------------------------------------
            Text(
              'Restaurant address: ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue[800]),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 20,
                ),
                Container(
                  width: 250,
                  child: Text(
                    userModel.restaurantAddress.isEmpty ||
                            userModel.restaurantAddress == null
                        ? '-'
                        : userModel.restaurantAddress,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            //-------------------------------------------------------------------
            Text(
              'Restaurant description: ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue[800]),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 20,
                ),
                Container(
                  width: 250,
                  child: Text(
                    userModel.restaurantDescription.isEmpty ||
                            userModel.restaurantDescription == null
                        ? '-'
                        : userModel.restaurantDescription,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            //-------------------------------------------------------------------
            Container(
              width: 250,
              height: 300,
              margin: EdgeInsets.only(bottom: 70),
              child: lat == null || lng == null || lat == 0 || lng == 0
                  ? CenterTitle().centerTitle16(context, 'No location info')
                  : showMap(),
            )
          ],
        ),
      ),
    );
  }

  Widget showNoInfo(BuildContext context) => CenterTitle()
      .centerTitle(context, 'No info, tap \'Pen\' icon below to add');

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

  reload() async {
    setState(() {
      infoLoaded = false;
    });
    getInfo();
  }
}
