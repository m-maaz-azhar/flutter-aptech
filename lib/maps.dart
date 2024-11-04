import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {

 final location = Location();

  late GoogleMapController mapController;

  LatLng _center = const LatLng(24.9234263, 67.0356586);

 void _onMapCreated(GoogleMapController controller){
  mapController = controller;
 }

 void _getLocation() async {
  final hasPermission = await location.hasPermission();
  if(hasPermission == PermissionStatus.granted){

    final location_data = await location.getLocation();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(location_data.latitude!, location_data.longitude!), zoom: 10.0)
      )
    );

  } else {
    final permission = await location.requestPermission();
    if(permission == PermissionStatus.granted){
      _getLocation();
    }
  }
 }

 
  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        onMapCreated: (controller) => _onMapCreated(controller),
        initialCameraPosition: CameraPosition(target:_center, zoom: 10.0 ),
    );
  }
}