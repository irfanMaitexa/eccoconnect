import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserComplaintsScreen extends StatefulWidget {
  const UserComplaintsScreen({Key? key}) : super(key: key);

  @override
  _UserComplaintsScreenState createState() => _UserComplaintsScreenState();
}

class _UserComplaintsScreenState extends State<UserComplaintsScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = true;
  List<Map<String, dynamic>> complaints = [];

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      QuerySnapshot complaintDocs = await FirebaseFirestore.instance
          .collection('complaints')
          .where('userId', isEqualTo: uid)
          .get();

      setState(() {
        complaints = complaintDocs.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
    }
  }

  // Function to add a new complaint
  Future<void> addComplaint(String complaintText) async {
    try {
      await FirebaseFirestore.instance.collection('complaints').add({
        'userId': uid,
        'complaint': complaintText,
        'timestamp': FieldValue.serverTimestamp(),
        'reply': '', // Add an empty reply field initially
      });
      fetchComplaints(); // Refresh the complaint list after adding
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint added successfully!')),
      );
    } catch (e) {
      print('Error adding complaint: $e');
    }
  }

  // Function to show the admin's reply dialog
  void _showAdminReplyDialog(String complaintId) {
    final TextEditingController _replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Admin Reply', style: TextStyle(color: Colors.green)),
          content: TextField(
            controller: _replyController,
            decoration: const InputDecoration(hintText: 'Enter your reply'),
            maxLines: 3,
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_replyController.text.isNotEmpty) {
                  _addReply(complaintId, _replyController.text);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reply cannot be empty!')),
                  );
                }
              },
              child: const Text('Add Reply'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to add the reply to Firestore
  Future<void> _addReply(String complaintId, String replyText) async {
    try {
      await FirebaseFirestore.instance.collection('complaints').doc(complaintId).update({
        'reply': replyText,
      });
      fetchComplaints(); // Refresh the complaints after adding the reply
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply added successfully!')),
      );
    } catch (e) {
      print('Error adding reply: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        backgroundColor: Colors.green,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? const Center(child: Text('No complaints found.'))
              : ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                      ),
                      color: Colors.green[50], // Light green background for cards
                      child: ListTile(
                        title: Text(
                          complaint['complaint'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Timestamp: ${complaint['timestamp']}',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            if (complaint['reply'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Admin Reply: ${complaint['reply']}',
                                  style: const TextStyle(fontSize: 14, color: Colors.green),
                                ),
                              ),
                          ],
                        ),
                        trailing: complaint['reply'].isEmpty
                            ? IconButton(
                                icon: const Icon(Icons.reply),
                                onPressed: () {
                                  _showAdminReplyDialog(complaint['id']);
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddComplaintDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Function to show dialog for adding a new complaint
  void _showAddComplaintDialog() {
    final TextEditingController _complaintController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Complaint', style: TextStyle(color: Colors.green)),
          content: TextField(
            controller: _complaintController,
            decoration: const InputDecoration(hintText: 'Enter your complaint'),
            maxLines: 3,
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_complaintController.text.isNotEmpty) {
                  addComplaint(_complaintController.text);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Complaint cannot be empty!')),
                  );
                }
              },
              child: const Text('Add Complaint'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
