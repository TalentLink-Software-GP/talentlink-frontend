import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:talent_link/services/message_service.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tab.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/map_screen.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/notifications/notifications_for_user.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/post_creator.dart';
import 'package:talent_link/widgets/login_widgets/login_page.dart';
import 'package:talent_link/widgets/web_layouts/web_navigation.dart';
import 'package:talent_link/utils/responsive/responsive_layout.dart';
import 'package:logger/logger.dart';

final String baseUrl = dotenv.env['BASE_URL']!;

class WebHomePage extends StatefulWidget {
  final String data; // Token
  final Function(String) onTokenChanged;

  const WebHomePage({
    super.key,
    required this.data,
    required this.onTokenChanged,
  });

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage>
    with AutomaticKeepAliveClientMixin {
  final _logger = Logger();
  @override
  bool get wantKeepAlive => true;
  int _selectedIndex = 0;
  late MessageService _messageService;

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: "Home",
    ),
    NavigationItem(
      icon: Icons.find_in_page_outlined,
      activeIcon: Icons.find_in_page,
      label: "Jobs",
    ),
    NavigationItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      label: "Map",
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: "Profile",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messageService = MessageService(widget.data);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    widget.onTokenChanged('Unauthorized');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _handleSearchNavigation() {
    _messageService.navigateToSearchPage(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      desktop: _buildWebLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(
            "TalentLink",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.message_outlined),
              onPressed: _handleSearchNavigation,
              color: Colors.white,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.05),
                Colors.white,
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              PostCreator(token: widget.data),
              JobsScreenTab(token: widget.data),
              MapScreen(token: widget.data),
              ProfileTab(token: widget.data, onLogout: _handleLogout),
            ],
          ),
        ),
        bottomNavigationBar: WebNavigation(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          items: _navigationItems,
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return WebNavigationLayout(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      navigationItems: _navigationItems,
      headerActions: [
        IconButton(
          icon: const Icon(Icons.message_outlined),
          onPressed: _handleSearchNavigation,
          tooltip: 'Messages',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            );
          },
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 16),
      ],
      child: Container(
        padding: const EdgeInsets.all(24),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildWebPostCreator(),
            _buildWebJobsScreen(),
            _buildWebMapScreen(),
            _buildWebProfileTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebPostCreator() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      child: PostCreator(token: widget.data),
    );
  }

  Widget _buildWebJobsScreen() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: JobsScreenTab(token: widget.data),
    );
  }

  Widget _buildWebMapScreen() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: MapScreen(token: widget.data),
    );
  }

  Widget _buildWebProfileTab() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      child: ProfileTab(token: widget.data, onLogout: _handleLogout),
    );
  }
}
