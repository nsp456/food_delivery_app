import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:food_delivery_app/user/UserHome.dart';

import 'UserHome.dart';
import 'Menucard.dart';

class StartPage extends StatelessWidget {
  String _address = "";
  Location location = Location();
  LocationData _currentPosition;
  LatLng _initialcameraposition = LatLng(19.0473, 73.0699);

  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    locationSet = true;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    _initialcameraposition =
        LatLng(_currentPosition.latitude, _currentPosition.longitude);

    _getAddress(_currentPosition.latitude, _currentPosition.longitude)
        .then((value) {
      _address = "${value.first.addressLine}";
      print("Address2 = " + _address);
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/start_page.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            padding: EdgeInsets.all(totalWidth * 10 / 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Image.asset("assets/images/start_page.jpeg"),
                SizedBox(
                  height: totalHeight * 120 / 700,
                ),
                Text(
                  "Hi, nice to meet you!",
                  style: TextStyle(
                      fontFamily: "Robonto",
                      fontWeight: FontWeight.bold,
                      fontSize: totalHeight * 30 / 700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: totalHeight * 10 / 700,
                ),
                Text(
                  "Set your location to start exploring restaurants around you",
                  maxLines: 2,
                  style: TextStyle(
                      fontFamily: "Robonto",
                      fontWeight: FontWeight.normal,
                      fontSize: totalHeight * 25 / 700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: totalHeight * 30 / 700,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _showMyDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(totalHeight * 10 / 700)),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.add_location_sharp,
                              size: totalHeight * 20 / 700),
                        ),
                        TextSpan(
                          text: " Use Current Location",
                          style: TextStyle(
                              fontSize: totalHeight * 20 / 700,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: totalHeight * 15 / 700,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapHomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(totalHeight * 10 / 700)),
                  ),
                  child: Text(
                    "Set Your Location Manually",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: totalHeight * 20 / 700,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                SizedBox(
                  height: totalHeight * 100 / 700,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    await getLoc();
    return showDialog<void>(
      context: context,
      // double totalHeight = MediaQuery.of(context).size.height;
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Address', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  "In order to help us serve you better, kindly provide us your complete address by clicking the edit button present on the top right corner of the screen !",
                  textAlign: TextAlign.justify,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                  style: TextStyle(
                    color: Colors.black,
                    // fontSize: * 15 / 700,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Sure', textAlign: TextAlign.center),
              onPressed: () async {
                // await getLoc();
                // Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => new MenuOptionSide(
                          automatic: false, address: _address),
                    ));
              },
            ),
          ],
        );
      },
    );
  }
}
