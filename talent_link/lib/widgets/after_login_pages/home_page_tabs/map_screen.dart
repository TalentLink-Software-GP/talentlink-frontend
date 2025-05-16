import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:talent_link/services/location_service.dart';
import 'package:talent_link/services/organization_service.dart';

class MapScreen extends StatefulWidget {
  final String token;

  const MapScreen({super.key, required this.token});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _logger = Logger();
  LatLng? _userLocation;
  final Set<Marker> _markers = {};

  late final LocationService _locationService;
  late final OrganizationService _orgService;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService(
      baseUrl: 'http://10.0.2.2:5000',
      token: widget.token,
    );
    _orgService = OrganizationService(
      // ← Add this
      baseUrl: 'http://10.0.2.2:5000/api/organization',
      token: widget.token,
    );
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
          permission != LocationPermission.always) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    final currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _userLocation = currentLatLng;
      _markers.add(
        Marker(
          markerId: MarkerId("user"),
          position: currentLatLng,
          infoWindow: InfoWindow(title: "You are here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    });

    await _loadOrganizationMarkers();
  }

  Future<void> _onMarkerTapped(String organizationId) async {
    try {
      final data = await _orgService.getOrganizationProfile(
        organizationId: organizationId,
      );

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(data['name'] ?? 'No Name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data['industry'] != null)
                    Text('Industry: ${data['industry']}'),
                  if (data['email'] != null) Text('Email: ${data['email']}'),
                  if (data['description'] != null)
                    Text('About: ${data['description']}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            ),
      );
    } catch (e) {
      _logger.e('Failed to load organization details', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load organization info')),
      );
    }
  }

  Future<void> _loadOrganizationMarkers() async {
    try {
      final locations = await _locationService.getAllCompaniesLocations();
      _logger.d("Fetched locations: $locations");
      for (int i = 0; i < locations.length; i++) {
        final org = locations[i];
        final lat = (org['lat'] as num).toDouble();
        final lng = (org['lng'] as num).toDouble();
        final name = org['organization']['name'] ?? 'Organization #$i';

        _markers.add(
          Marker(
            markerId: MarkerId(org['organization']['id']),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            onTap: () => _onMarkerTapped(org['organization']['id']),
          ),
        );
      }

      setState(() {});
    } catch (e) {
      _logger.e("Failed to load organization markers", error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _userLocation == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
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
