import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _userLocation;
  final Set<Marker> _markers = {};

  // Example org locations
  final List<LatLng> _orgLocations = [
    LatLng(37.42796133580664, -122.085749655962), // Replace with real data
    LatLng(37.424, -122.092),
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always)
        return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: MarkerId("user"),
          position: _userLocation!,
          infoWindow: InfoWindow(title: "You are here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );

      for (int i = 0; i < _orgLocations.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId("org_$i"),
            position: _orgLocations[i],
            infoWindow: InfoWindow(title: "Organization #$i"),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _userLocation == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                onMapCreated: (controller) => _mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: _userLocation!,
                  zoom: 14.5,
                ),
                myLocationEnabled: true,
                markers: _markers,
              ),
    );
  }
}
