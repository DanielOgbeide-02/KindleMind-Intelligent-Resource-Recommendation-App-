import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recommender_nk/config/theme/app_theme.dart';
import 'package:recommender_nk/presentation/home/pages/user/home_screen.dart';
import 'package:recommender_nk/presentation/profile/pages/profile_page.dart';
import 'package:recommender_nk/presentation/recommended_users/pages/recommended_users.dart';
import 'package:recommender_nk/presentation/search/pages/search_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    SearchPage(),
    RecommendedUsers(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: _pages[_selectedIndex], // Shows the selected page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.surface12,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,          // Active item color
        unselectedItemColor: Colors.grey.shade400, // Inactive items color
        currentIndex: _selectedIndex,              // Important to show active item
        onTap: _onItemTapped,                      // Handle tap
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Connect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
