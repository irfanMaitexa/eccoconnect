import 'package:eccoconnect/admin/admin_login.dart';
import 'package:eccoconnect/user/user_login_screen.dart';
import 'package:flutter/material.dart';

class ChooseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Choose Role', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoleCard(
              role: 'Admin',
              icon: Icons.admin_panel_settings,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLoginScreen(),));
                // Navigate to Admin Screen
              },
            ),
            SizedBox(height: 16),
            RoleCard(
              role: 'User',
              icon: Icons.person,
              onPressed: () {

                Navigator.push(context, MaterialPageRoute(builder: (context) => UserLoginScreen(),));
                // Navigate to User Screen
              },
            ),
            SizedBox(height: 16),
            RoleCard(
              role: 'Driver',
              icon: Icons.local_shipping,
              onPressed: () {
                // Navigate to Driver Screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String role;
  final IconData icon;
  final VoidCallback onPressed;

  const RoleCard({
    required this.role,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 10,),
          Icon(icon, size: 30, color: Colors.white),
          Text(
            role,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Icon(Icons.arrow_forward, color: Colors.white),
          SizedBox(width: 10,)
        ],
      ),
    );
  }
}

