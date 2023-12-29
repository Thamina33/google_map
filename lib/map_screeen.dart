import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Location location = Location();
  late LatLng currentLocation;
  List<LatLng> polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    currentLocation =  const LatLng(0.0, 0.0);
    _animateToUser();
    _getLocationUpdates();
    _startLocationUpdates();
  }

  void _animateToUser() async {
    var pos = await location.getLocation();
    if (pos.latitude != null && pos.longitude != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pos.latitude!, pos.longitude!),
          zoom: 17.0,
        ),
      ));
    }
  }

  void _getLocationUpdates() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        if (currentLocation.latitude != null && currentLocation.longitude != null) {
          // Update current location
          this.currentLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);

          // Update marker position
          mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: this.currentLocation,
              zoom: 17.0,
            ),
          ));

          // Update polyline
          polylineCoordinates.add(this.currentLocation);
        }
      });
    });
  }
  void _startLocationUpdates() {
    const duration = Duration(seconds: 10);

    // Use a periodic timer to fetch location updates every 10 seconds
    Timer.periodic(duration, (Timer timer) {
      _getLocationUpdates();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Map App'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.0, 0.0),
          zoom: 15,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        markers: currentLocation == null
            ? Set()
            : {
          Marker(
            markerId: const MarkerId('userLocation'),
            position: currentLocation,
            onTap: () {
              // Display info window when marker is tapped
              mapController.showMarkerInfoWindow(const MarkerId('userLocation'));
            },
            infoWindow: InfoWindow(
              title: 'My current location',
              snippet:
              'Lat: ${currentLocation.latitude}, Lng: ${currentLocation.longitude}',
            ),
          ),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('userRoute'),
            color: Colors.blue,
            points: polylineCoordinates,
          ),
        },
      ),
    );
  }
}