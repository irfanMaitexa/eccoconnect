import 'package:eccoconnect/user/user_request_screen.dart';
import 'package:flutter/material.dart';

class UserRootScreen extends StatefulWidget {
  @override
  _UserRootScreenState createState() => _UserRootScreenState();
}

class _UserRootScreenState extends State<UserRootScreen> {
  final List<Widget> _screens = [
    Scaffold(), // Add your actual screens here
    UserRequestScreen(),
    Scaffold(),
    Scaffold(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.lightGreen, // Light Green Bottom Navigation Bar
        selectedItemColor: Colors.white, // White selected icon color
        unselectedItemColor: Colors.white.withOpacity(0.7), // Light white for unselected items
        type: BottomNavigationBarType.fixed, // Ensure the icons remain clear
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem), // Changed icon to represent complaints
            label: 'Complaints', // Changed label to Complaints
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
