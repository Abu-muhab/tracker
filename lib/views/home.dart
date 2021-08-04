import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  LatLng _currentLocation;
  LatLng driverLocation;
  BitmapDescriptor markerBitMap;
  BitmapDescriptor markerBitMap2;
  List<Marker> markers;

  @override
  void initState() {
    getLocation();
    getDriverLocation();
    loadMarkerImage();
    Timer(Duration(seconds: 2), () {
      getLocation();
    });
    super.initState();
  }

  void loadMarkerImage() async {
    ByteData temp = await rootBundle.load("images/truck.png");
    ByteData temp2 = await rootBundle.load("images/user.png");
    markerBitMap = BitmapDescriptor.fromBytes(temp.buffer.asUint8List());
    markerBitMap2 = BitmapDescriptor.fromBytes(temp2.buffer.asUint8List());
  }

  void getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

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

    _locationData = await location.getLocation();
    print("${_locationData.latitude},${_locationData.longitude}");

    setState(() {
      _currentLocation =
          LatLng(_locationData.latitude, _locationData.longitude);
    });
  }

  void getDriverLocation() async {
    FirebaseFirestore.instance
        .collection("slave_location")
        .doc("slave_location")
        .snapshots()
        .listen((doc) {
      print(doc.data()['latitude']);
      setState(() {
        driverLocation =
            LatLng(doc.data()['latitude'], doc.data()['longitude']);
      });
    });
  }

  // void getCarLocation() async {
  //   FirebaseFirestore.instance
  //       .collection("slave_location")
  //       .doc("slave_location")
  //       .snapshots()
  //       .listen((doc) {
  //     print(doc.data()['latitude']);
  //     setState(() {
  //       driverLocation =
  //           LatLng(doc.data()['latitude'], doc.data()['longitude']);
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    markers = driverLocation == null
        ? Marker(
            markerId: MarkerId("currentLocationMarker"),
            position: _currentLocation,
            icon: markerBitMap)
        : [
            Marker(
                markerId: MarkerId("currentLocationMarker"),
                position: _currentLocation,
                icon: markerBitMap),
            Marker(
                markerId: MarkerId("driverLocation"),
                position: driverLocation,
                icon: markerBitMap2)
          ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Trucktrack",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: _currentLocation == null || markerBitMap == null
            ? SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition:
                          CameraPosition(target: _currentLocation, zoom: 19),
                      markers: markers.toSet(),
                    ),
                  ),
                  Container(
                    color: Colors.black,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.directions_car_outlined,
                            color: Colors.white,
                          ),
                          title: Text(
                            "Last Known Coordinates",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                              "Latitude: ${double.parse(_currentLocation.latitude.toStringAsFixed(5))}, Longitude: ${double.parse(_currentLocation.longitude.toStringAsFixed(5))}",
                              style: TextStyle(color: Colors.white)),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(
                            Icons.account_box_outlined,
                            color: Colors.white,
                          ),
                          title: Text(
                            "Last Known Coordinates",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                              "Latitude: ${double.parse(driverLocation.latitude.toStringAsFixed(5))}, Longitude: ${double.parse(driverLocation.longitude.toStringAsFixed(5))}",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
