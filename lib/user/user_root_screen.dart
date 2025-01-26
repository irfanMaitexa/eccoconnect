
import 'package:eccoconnect/user/user_booking_screen.dart';
import 'package:eccoconnect/user/user_complaint_screen.dart';
import 'package:eccoconnect/user/user_profile_screen.dart';
import 'package:eccoconnect/user/user_request_screen.dart';
import 'package:flutter/material.dart';

class UserRootScreen extends StatefulWidget {
  @override
  _UserRootScreenState createState() => _UserRootScreenState();
}

class _UserRootScreenState extends State<UserRootScreen> {
  final List<Widget> _screens = [
    UserRequestScreen(), // First tab: Request
    UserBookingScreen(),          // Second tab: Booking (Replace with actual Booking screen widget)
    UserComplaintsScreen(),
    ProfileScreen(),
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
            icon: Icon(Icons.request_page), // Icon for Request
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online), // Changed icon to represent Booking
            label: 'Booking', // Updated label to Booking
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem), // Icon for Complaints
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), // Icon for Profile
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
