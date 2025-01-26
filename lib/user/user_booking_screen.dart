import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserBookingScreen extends StatefulWidget {
  const UserBookingScreen({Key? key}) : super(key: key);

  @override
  _UserBookingScreenState createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> acceptedRequests = [];
  List<Map<String, dynamic>> assignedRequests = [];
  List<Map<String, dynamic>> completedRequests = [];
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Updated length to 4
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      QuerySnapshot requestDocs = await FirebaseFirestore.instance
          .collection('requests')
          .where('userId', isEqualTo: uid) // Filter by userId (uid)
          .get();

      List<Map<String, dynamic>> pending = [];
      List<Map<String, dynamic>> accepted = [];
      List<Map<String, dynamic>> assigned = [];
      List<Map<String, dynamic>> completed = [];

      for (var doc in requestDocs.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['status'] == 'pending') {
          pending.add(data);
        } else if (data['status'] == 'accepted') {
          accepted.add(data);
        } else if (data['status'] == 'Ongoing') {
          assigned.add(data);
        } else if (data['status'] == 'Completed') {
          completed.add(data);
        }
      }

      setState(() {
        pendingRequests = pending;
        acceptedRequests = accepted;
        assignedRequests = assigned;
        completedRequests = completed;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookings',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'), // New "Accepted" tab
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildRequestList(pendingRequests),
                buildRequestList(acceptedRequests), // New tab content
                buildRequestList(assignedRequests),
                buildRequestList(completedRequests),
              ],
            ),
    );
  }

  Widget buildRequestList(List<Map<String, dynamic>> requests) {
    if (requests.isEmpty) {
      return const Center(child: Text('No requests found.'));
    }
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      request['imageUrl'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    '${request['material']} - ${request['quantity']}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            'Date: ${request['date']}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.payment, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            'Payment: ${request['paymentStatus'] ? "Paid" : "Pending"}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey),
                Row(
                  children: [
                    const Icon(Icons.stadium, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      'Status: ${request['status']}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
