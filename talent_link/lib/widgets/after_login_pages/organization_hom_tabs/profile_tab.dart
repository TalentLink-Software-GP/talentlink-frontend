import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/avatar_name.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/location_picker_screen.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/location_view.dart';
import 'package:talent_link/widgets/base_widgets/button.dart';
import 'package:talent_link/services/location_service.dart';
import 'package:talent_link/widgets/appSetting/seeting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_link/utils/auth_utils.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:talent_link/widgets/appSetting/web_settings_page.dart';

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
      //192.168.1.7        baseUrl: 'http://10.0.2.2:5000',
      // baseUrl: 'http://192.168.1.7:5000',
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

  Future<void> _handleLogout() async {
    try {
      // Use the centralized logout utility for consistent behavior
      await AuthUtils.performCompleteLogout(context);
    } catch (e) {
      logger.e("Error during logout", error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during logout. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.05),
            Colors.white,
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Avatar, Name and Settings
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.9),
                    Theme.of(context).primaryColor.withOpacity(0.7),
                    Theme.of(context).primaryColor.withOpacity(0.5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),
                  child: Stack(
                    children: [Center(child: AvatarName(token: widget.token))],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Organization Location",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LocationView(lat: lat, lag: lag),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: BaseButton(
                      text: 'Update Location',
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Account Settings",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionTile(
                    icon: Icons.settings,
                    title: 'Account Settings',
                    subtitle: 'Manage your organization settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  kIsWeb
                                      ? const WebSettingsPage()
                                      : SettingsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    isLogout: true,
                    onTap: () {
                      _showLogoutDialog();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isLogout
                    ? Colors.red.withOpacity(0.05)
                    : Theme.of(context).primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isLogout
                      ? Colors.red.withOpacity(0.2)
                      : Theme.of(context).primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isLogout
                          ? Colors.red.withOpacity(0.1)
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isLogout ? Colors.red : Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isLogout ? Colors.red : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isLogout ? Colors.red : Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              const Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout? You will need to sign in again to access your account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
