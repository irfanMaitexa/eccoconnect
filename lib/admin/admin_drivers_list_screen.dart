import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverListingScreen extends StatefulWidget {
  const DriverListingScreen({Key? key}) : super(key: key);

  @override
  _DriverListingScreenState createState() => _DriverListingScreenState();
}

class _DriverListingScreenState extends State<DriverListingScreen> {
  // Fetch driver details from Firestore
  Future<List<Map<String, dynamic>>> getDrivers() async {
    try {
      final driverSnapshot = await FirebaseFirestore.instance.collection('drivers').get();
      return driverSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID for deletion
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to load drivers');
    }
  }

  // Delete driver by ID
  Future<void> deleteDriver(String driverId) async {
    try {
      await FirebaseFirestore.instance.collection('drivers').doc(driverId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver deleted successfully!')),
      );
      setState(() {}); // Refresh the UI after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete driver.')),
      );
    }
  }

  // Show confirmation dialog before deletion
  void showDeleteConfirmation(BuildContext context, String driverId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Driver'),
          content: const Text('Are you sure you want to delete this driver?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                deleteDriver(driverId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Build driver list with Delete button and improved UI
  Widget buildDriverList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getDrivers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No drivers available.'));
        }

        final drivers = snapshot.data!;

        return ListView.builder(
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            final driver = drivers[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(driver['licensePhoto']),
                ),
                title: Text(
                  driver['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver['phone'], style: TextStyle(color: Colors.grey[600])),
                    Text(driver['email'], style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        showDeleteConfirmation(context, driver['id']);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                onTap: () {
                  showDriverDetails(context, driver);
                },
              ),
            );
          },
        );
      },
    );
  }

  // Driver details dialog
  void showDriverDetails(BuildContext context, Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(driver['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(driver['licensePhoto']),
              ),
              const SizedBox(height: 12),
              Text('Phone: ${driver['phone']}', style: TextStyle(fontSize: 16)),
              Text('Email: ${driver['email']}', style: TextStyle(fontSize: 16)),
              Text('License: ${driver['licenseNumber']}', style: TextStyle(fontSize: 16)),
              Text('Status: ${driver['status']}', style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Listings'),
        backgroundColor: Colors.green[700],
      ),
      body: buildDriverList(),
    );
  }
}
