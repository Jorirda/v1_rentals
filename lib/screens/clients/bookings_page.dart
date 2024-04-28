import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late int _selectedIndex;

  late String lat = '';
  late String long = '';
  // static const googlePlex = LatLng(37.4223, -122.0848);
  // static const gaoboSoft = LatLng(31.322384677383823, 120.41921422457392);

  // Future<Position> _getCurrentLocation() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled');
  //   }

  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission == await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permantly denied, we cannot request permissions');
  //   }
  //   return await Geolocator.getCurrentPosition();
  // }

  // void _liveLocation() {
  //   LocationSettings locationSettings = const LocationSettings(
  //     accuracy: LocationAccuracy.high,
  //     distanceFilter: 100,
  //   );

  //   Geolocator.getPositionStream(locationSettings: locationSettings)
  //       .listen((Position position) {
  //     setState(() {
  //       lat = position.latitude.toString();
  //       long = position.longitude.toString();
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text("My Bookings"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Current location of User:'),
                Text('Latitude: $lat'),
                Text('Longitude: $long'),
                ElevatedButton(
                  onPressed: () {
                    // _getCurrentLocation().then((value) {
                    //   setState(() {
                    //     lat = '${value.latitude}';
                    //     long = '${value.longitude}';
                    //     print(lat);
                    //     print(long);
                    //   });
                    // });
                  },
                  child: const Text('Get Current Location'),
                )
              ],
            ),
          )
          // GoogleMap(
          //   initialCameraPosition: CameraPosition(target: gaoboSoft, zoom: 15),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          //   child: ToggleButtons(
          //     children: const <Widget>[
          //       Text('Completed'),
          //       Text('Pending'),
          //       Text('In Progress'),
          //     ],
          //     isSelected:
          //         List.generate(3, (index) => index == _selectedIndex),
          //     onPressed: (int index) {
          //       setState(() {
          //         _selectedIndex = index;
          //       });
          //     },
          //   ),
          // ),
          ),
    );
  }
}
