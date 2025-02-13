import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverRequestScreen extends StatefulWidget {
  @override
  _DriverRequestScreenState createState() => _DriverRequestScreenState();
}

class _DriverRequestScreenState extends State<DriverRequestScreen> {
  late String currentUserId;
  Map<int, bool> _showUserDetails = {};

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }


  Future<String?> fetchPaymentAmount() async {
    final doc = await FirebaseFirestore.instance.collection('wasteprice').get();
    if (doc.docs.isNotEmpty) {
      return doc.docs[0].data()['payment'].toString();
    }
    return null;
  }



  void showQRCode(BuildContext context, String amount) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Payment QR Code'),
      content: QrImageView(  // Use QrImageView for latest qr_flutter version
        data: '$amount',
        version: QrVersions.auto,
        size: 200.0,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}



  Future<List<Map<String, dynamic>>> fetchRequests(String status) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('driver.id', isEqualTo: currentUserId)
        .where('driverStatus', isEqualTo: status)
        .get();

    List<Map<String, dynamic>> requests = [];

    for (var doc in querySnapshot.docs) {
      var requestData = doc.data();
      requestData['id'] = doc.id;

      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(requestData['userId'])
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        requestData['userDetails'] = userData;
      }

      requests.add(requestData);
    }

    return requests;
  }

  Future<void> openMap(double latitude, double longitude) async {
    try {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) throw 'Location service is not enabled';
      }
      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted) throw 'Permission denied';
      }
      LocationData currentLocation = await location.getLocation();
      double currentLat = currentLocation.latitude!;
      double currentLong = currentLocation.longitude!;
      final url =
          'https://www.google.com/maps/dir/?api=1&origin=$currentLat,$currentLong&destination=$latitude,$longitude';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not open map';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  Widget buildRequestList(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchRequests(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No $status requests available.'));
        } else {
          List<Map<String, dynamic>> requests = snapshot.data!;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final user = request['userDetails'];
              bool _isDetailsVisible = _showUserDetails[index] ?? false;

              return Card(
                margin: EdgeInsets.all(12),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(request['imageUrl']),
                        backgroundColor: Colors.grey[200],
                      ),
                      title: Text(
                        request['driver']['name'] ?? 'Unknown Driver',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Material: ${request['material']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            'Quantity: ${request['quantity']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
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
                    ),
                    if(status == 'Ongoing')

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                 
                                  GestureDetector(
                                    onTap: () async{

                                     final amount =     await fetchPaymentAmount();
                                      
                                      showQRCode(context, amount!);
                                     
                                    },
                                    child: Text(
                                      'Make payment qr code',
                                      style: TextStyle(
                                        color: Colors.teal,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),


           status == 'Completed'  ? SizedBox() :        Align(
  alignment: Alignment.centerRight,
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: ElevatedButton(
      onPressed: () async {
        String nextStatus;
        if (status == 'Assigned') {
          nextStatus = 'Ongoing';
        } else if (status == 'Ongoing') {
          nextStatus = 'Completed';
        } else {
          nextStatus = '';
        }

        if (nextStatus.isNotEmpty) {
          try {
            await FirebaseFirestore.instance
                .collection('requests')
                .doc(request['id'])
                .update({'driverStatus': nextStatus,'paymentStatus': true}); 
                
                await FirebaseFirestore.instance
                .collection('requests')
                .doc(request['id'])
                .update({'status': nextStatus});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Status updated to $nextStatus'),
              ),
            );
            setState(() {}); // Refresh UI
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update status: $e'),
              ),
            );
          }
        }
      },
      
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        status == 'Assigned'
            ? 'Ongoing'
            : status == 'Ongoing'
                ? 'Complete'
                : 'Completed',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  ),
)

                 
                  
                  
                  
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          
          bottom: TabBar(
            tabs: [
              Tab(text: 'Assigned'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildRequestList('Assigned'),
            buildRequestList('Ongoing'),
            buildRequestList('Completed'),
          ],
        ),
      ),
    );
  }
}
