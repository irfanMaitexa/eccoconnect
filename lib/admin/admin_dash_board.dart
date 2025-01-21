import 'package:eccoconnect/admin/admin_drivers_list_screen.dart';
import 'package:eccoconnect/admin/request_list_screen.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    RequestListingScreen(),
    HomeScreen(),

    
   DriverListingScreen(),
   ManageUsersScreen(),
    PickupScreen(),
    
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[300],
        backgroundColor: Colors.green,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Requests',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Drivers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Pickup',
          ),
          
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  void _navigateToComplaints(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ComplaintsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 80, color: Colors.green),
          SizedBox(height: 20),
          Text(
            'Welcome to the Admin Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Use the bottom navigation to manage users, drivers, and more.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _navigateToComplaints(context),
            icon: Icon(Icons.report_problem, color: Colors.white),
            label: Text('View Complaints'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Text(
          'Complaints Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class ManageUsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Users',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class ManageDriversScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Manage Drivers Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class PickupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Pickup Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

