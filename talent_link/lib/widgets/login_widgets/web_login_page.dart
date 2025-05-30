import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:talent_link/services/fcm_service.dart';
import 'package:talent_link/utils/app_lifecycle_manager.dart';
import 'package:talent_link/widgets/admin/adminDashboard.dart';
import 'package:talent_link/widgets/admin/web_admin_dashboard.dart';
import 'package:talent_link/widgets/after_login_pages/web_organization_home_page.dart';
import 'package:talent_link/widgets/web_layouts/web_form_components.dart';
import 'package:talent_link/widgets/after_login_pages/web_home_page.dart';
import 'package:talent_link/widgets/after_login_pages/organization_home_page.dart';
import 'package:talent_link/widgets/forget_account_widgets/web_forgot_account_screen.dart';
import 'package:talent_link/widgets/sign_up_widgets/web_sign_up_choose_positions.dart';
import 'package:talent_link/utils/responsive/responsive_layout.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final String baseUrl = dotenv.env['BASE_URL']!;

class WebLoginPage extends StatefulWidget {
  const WebLoginPage({super.key});

  @override
  State<WebLoginPage> createState() => _WebLoginPageState();
}

class _WebLoginPageState extends State<WebLoginPage>
    with SingleTickerProviderStateMixin {
  final logger = Logger();
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleFcmRecovery() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      logger.i('FCM token is $token');

      if (token != null) {
        final fcmService = FCMService();
        await fcmService.sendTokenToServer(token);
      } else {
        logger.e('FCM token is null');
      }
    } catch (e) {
      logger.e('FCM recovery failed', error: e);
    }
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      logger.i("Starting web login process...");
      logger.i("Base URL: $baseUrl");
      logger.i("Email: ${emailController.text}");

      var url = Uri.parse('$baseUrl/auth/login');
      logger.i("Making request to: $url");

      // Create HTTP client with timeout
      final client = http.Client();

      var response = await client
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": emailController.text,
              "password": passwordController.text,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              logger.e("Request timed out after 30 seconds");
              throw Exception(
                "Request timed out. Please check your internet connection.",
              );
            },
          );

      logger.i("Response status code: ${response.statusCode}");
      logger.i("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        logger.i("Web login successful");

        if (!mounted) return;

        final decodedToken = JwtDecoder.decode(data["token"]);
        final role = decodedToken['role'];
        String userId = decodedToken['id'];
        String username = decodedToken['username'];

        logger.i(
          "Decoded token - Role: $role, UserId: $userId, Username: $username",
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('username', username);
        await prefs.setString('role', role);
        await prefs.setString('userId', userId);

        logger.i("Saved user data to SharedPreferences");

        // Handle FCM with timeout and error handling
        try {
          logger.i("Starting FCM recovery...");
          await _handleFcmRecovery().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              logger.w("FCM recovery timed out, continuing without FCM");
              return;
            },
          );
          logger.i("FCM recovery completed");
        } catch (fcmError) {
          logger.w("FCM recovery failed, continuing without FCM: $fcmError");
          // Continue with login even if FCM fails
        }

        logger.i("Navigating to home page...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => AppLifecycleManager(
                  userId: userId,
                  token: data["token"],
                  child:
                      role == 'admin'
                          ? WebAdminDashboard(token: data["token"])
                          : role == 'Organization'
                          ? WebOrganizationHomePage(token: data["token"])
                          : WebHomePage(
                            data: data["token"],
                            onTokenChanged: (newToken) async {
                              // Handle token change
                            },
                          ),
                ),
          ),
        );
      } else {
        var data = jsonDecode(response.body);
        setState(() {
          errorMessage = data["message"] ?? "Login failed";
        });
        logger.e(
          "Web login failed with status ${response.statusCode}: ${response.body}",
        );
      }
    } catch (e) {
      logger.e("Web login error: $e");
      setState(() {
        if (e.toString().contains("timeout") ||
            e.toString().contains("Timeout")) {
          errorMessage =
              "Request timed out. Please check your internet connection and try again.";
        } else if (e.toString().contains("SocketException") ||
            e.toString().contains("Connection")) {
          errorMessage =
              "Cannot connect to server. Please check your internet connection.";
        } else {
          errorMessage = "Login failed: ${e.toString()}";
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      logger.i("Web login process completed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildWebLayout(context);
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildWebHeader(context),

          // Main Content including Footer
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLoginSection(context),
                  _buildFeaturesSection(context),
                  _buildWebFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and Brand
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.work_outline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                "TalentLink",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),

          // Navigation Links
          Row(
            children: [
              _buildHeaderLink("Features", () {}),
              _buildHeaderLink("About", () {}),
              _buildHeaderLink("Contact", () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderLink(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 48),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              // Left side - Welcome message
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back to\nTalentLink",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Sign in to access your account and continue your professional journey.",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 80),
              // Right side - Login form
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: WebCard(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 24),
                            WebTextField(
                              controller: emailController,
                              labelText: "Email",
                              prefixIcon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            WebTextField(
                              controller: passwordController,
                              labelText: "Password",
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            if (errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            WebButton(
                              text: "Sign In",
                              width: double.infinity,
                              height: 48,
                              isLoading: isLoading,
                              onPressed: login,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                WebForgotAccountScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => WebChoosePositions(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Create Account",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 48),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                "Why Choose TalentLink",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 60),
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      Icons.verified_user_outlined,
                      "Verified Profiles",
                      "Join a community of verified professionals and organizations.",
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildFeatureCard(
                      Icons.security_outlined,
                      "Secure Platform",
                      "Your data is protected with enterprise-grade security.",
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildFeatureCard(
                      Icons.support_agent_outlined,
                      "24/7 Support",
                      "Get help whenever you need it from our support team.",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
      color: Colors.grey[900],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.work_outline,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "TalentLink",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Connecting talent with opportunity",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFooterTitle("Company"),
                        _buildFooterLink("About Us"),
                        _buildFooterLink("Careers"),
                        _buildFooterLink("Contact"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFooterTitle("Resources"),
                        _buildFooterLink("Blog"),
                        _buildFooterLink("Help Center"),
                        _buildFooterLink("Guidelines"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFooterTitle("Legal"),
                        _buildFooterLink("Privacy Policy"),
                        _buildFooterLink("Terms of Service"),
                        _buildFooterLink("Cookie Policy"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Container(height: 1, color: Colors.grey[800]),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "© 2024 TalentLink. All rights reserved.",
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  Row(
                    children: [
                      _buildSocialIcon(Icons.facebook),
                      const SizedBox(width: 16),
                      _buildSocialIcon(Icons.alternate_email),
                      const SizedBox(width: 16),
                      _buildSocialIcon(Icons.business_center),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      child: Icon(icon, color: Colors.grey[400], size: 24),
    );
  }
}
