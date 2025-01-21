import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverRequestScreen extends StatefulWidget {
  @override
  _DriverRequestScreenState createState() => _DriverRequestScreenState();
}

class _DriverRequestScreenState extends State<DriverRequestScreen> {
  late String currentUserId;
  Map<int, bool> _showUserDetails = {}; // Use a map to track state for each request

  @override
  void initState() {
    super.initState();
    // Get the current user's UID using FirebaseAuth
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  // Fetch Requests and associated User Data
  Future<List<Map<String, dynamic>>> fetchRequests() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('driver.id', isEqualTo: currentUserId) // Filter requests by driver ID
        .get();

    List<Map<String, dynamic>> requests = [];

    for (var doc in querySnapshot.docs) {
      var requestData = doc.data() as Map<String, dynamic>;

      // Fetch user data using userId from the request
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(requestData['userId'])
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        requestData['userDetails'] = userData; // Add user details to the request
      }

      requests.add(requestData);
    }

    return requests;
  }

  // Function to launch Google Maps with the user's location
 Future<void> openMap(double latitude, double longitude) async {
  try {
    // Create an instance of the Location plugin
    Location location = Location();

    // Check if location service is enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Request to enable location service
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw 'Location service is not enabled';
      }
    }

    // Check if location permissions are granted
    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        throw 'Location permission is not granted';
      }
    }

    // Get current location of the user
    LocationData currentLocation = await location.getLocation();
    double currentLat = currentLocation.latitude!;
    double currentLong = currentLocation.longitude!;

    // Construct the URL for Google Maps Directions
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$currentLat,$currentLong&destination=$latitude,$longitude';

    // Launch the URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open map';
    }
  } catch (e) {
    throw 'Error: $e';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Requests'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No requests available.'));
          } else {
            List<Map<String, dynamic>> requests = snapshot.data!;
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final user = request['userDetails'];
                
                // Track user details state per request
                bool _isDetailsVisible = _showUserDetails[index] ?? false;

                return Card(
                  margin: EdgeInsets.all(12),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(request['imageUrl']),
                      backgroundColor: Colors.grey[200],
                    ),
                    title: Text(
                      request['driver']['name'] ?? 'Unknown Driver',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Material: ${request['material']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Quantity: ${request['quantity']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Divider(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showUserDetails[index] = !_isDetailsVisible;
                            });
                          },
                          child: Text(
                            'User: ${user['name']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        if (_isDetailsVisible) ...[
                          Divider(),
                          Text('Email: ${user['email']}'),
                          Text('Phone: ${user['phone']}'),
                          Divider(),
                          if (user['location'] != null)
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.teal),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    openMap(user['location']['latitude'],
                                        user['location']['longitude']);
                                  },
                                  child: Text(
                                    'View on Map',
                                    style: TextStyle(
                                      color: Colors.teal,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: Colors.teal,
                    ),
                    onTap: () {
                      // Navigate to a detailed request screen if needed
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
