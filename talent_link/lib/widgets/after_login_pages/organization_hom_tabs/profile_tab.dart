import 'package:flutter/material.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/avatar_name.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/location_picker_screen.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/location_view.dart';
import 'package:talent_link/widgets/base_widgets/button.dart';
import 'package:talent_link/services/location_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';

class ProfileTab extends StatefulWidget {
  final String token;
  const ProfileTab({super.key, required this.token});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final logger = Logger();
  double lat = 32.150146;
  double lag = 35.253834;
  bool isLoading = true;

  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService(
      baseUrl: 'http://10.0.2.2:5000',
      token: widget.token,
    );
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final decodedToken = JwtDecoder.decode(widget.token);
      final username = decodedToken['username'];
      final location = await _locationService.getLocationByUsername(username);
      setState(() {
        lat = location['lat']!;
        lag = location['lng']!;
        isLoading = false;
      });
    } catch (e) {
      logger.e("Error fetching location", error: e);
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateLocation(double newLat, double newLng) async {
    setState(() {
      lat = newLat;
      lag = newLng;
    });

    final success = await _locationService.setLocation(
      lat: newLat,
      lng: newLng,
    );
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update location")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AvatarName(token: widget.token),
            Divider(),
            LocationView(lat: lat, lag: lag),
            Divider(),
            BaseButton(
              text: 'Set Location',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => LocationPickerScreen(
                          initialLat: lat,
                          initialLng: lag,
                        ),
                  ),
                );

                if (result != null) {
                  await _updateLocation(result['lat'], result['lng']);
                }
              },
            ),
          ],
        );
  }
}
