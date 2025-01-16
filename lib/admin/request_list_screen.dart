import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestListingScreen extends StatefulWidget {
  const RequestListingScreen({Key? key}) : super(key: key);

  @override
  _RequestListingScreenState createState() => _RequestListingScreenState();
}

class _RequestListingScreenState extends State<RequestListingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs: Pending and Accepted
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data() ?? {};
  }

  Widget buildRequestList(String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: statusFilter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No requests available.'));
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final createdAt = (request['createdAt'] as Timestamp).toDate();
            final formattedDate = DateFormat('MMMM d, y').format(createdAt);

            return FutureBuilder<Map<String, dynamic>>(
              future: getUserDetails(request['userId']),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(); // Show nothing while loading user data
                }

                final userDetails = userSnapshot.data ?? {};
                final userEmail = userDetails['email'] ?? 'N/A';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(request['imageUrl']),
                              radius: 25,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Material: ${request['material']}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: ${request['quantity']}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  'Status: ${request['status']}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              request['isAccepted'] ? Icons.check_circle : Icons.pending,
                              color: request['isAccepted'] ? Colors.green : Colors.grey,
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(
                          'Created At: $formattedDate',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          'User Email: $userEmail',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${userDetails['name']}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  'Phone: ${userDetails['phone']}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final location = userDetails['location'];
                                final latitude = location['latitude'];
                                final longitude = location['longitude'];
                                final url =
                                    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url),
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Could not open Google Maps')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.map, size: 16, color: Colors.teal),
                              label: const Text(
                                'View on Google Maps',
                                style: TextStyle(fontSize: 12, color: Colors.teal),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Request Listings'),
          backgroundColor: Colors.green,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildRequestList('pending'), // Show pending requests
            buildRequestList('accept'), // Show accepted requests
          ],
        ),
      ),
    );
  }
}
