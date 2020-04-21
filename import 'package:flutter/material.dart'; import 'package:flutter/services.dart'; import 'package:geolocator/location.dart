import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';





class LocationDetail extends StatefulWidget {
  @override
  _LocationDetailState createState() => _LocationDetailState();
}

class _LocationDetailState extends State<LocationDetail> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
  Position _currentPosition;
  String _currentAddress;


  @override
  Widget build(BuildContext context) {
    return Form(

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[



            RaisedButton(
              child: Text("Get location",style: TextStyle(color: Colors.white),),
              color: Colors.blue[500],
              onPressed: () {
                _getCurrentLocation();
              },
            ),
            Text("Location Details :"),

            if (_currentPosition != null)
              Text(_currentAddress),
          ],
        ),
      ),
    );
  }

  _getCurrentLocation() {


    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
}





