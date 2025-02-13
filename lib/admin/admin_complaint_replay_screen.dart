import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: AdminComplaintScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class AdminComplaintScreen extends StatefulWidget {
  @override
  _AdminComplaintScreenState createState() => _AdminComplaintScreenState();
}

class _AdminComplaintScreenState extends State<AdminComplaintScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Function to show reply input popup
  void _showReplyDialog(String docId, String existingReply) {
    TextEditingController replyController =
        TextEditingController(text: existingReply);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Reply"),
          content: TextField(
            controller: replyController,
            decoration: InputDecoration(hintText: "Enter reply"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _updateReply(docId, replyController.text);
                Navigator.pop(context);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // Function to update reply in Firestore
  void _updateReply(String docId, String newReply) {
    _firestore.collection("complaints").doc(docId).update({
      "reply": newReply,
    });
  }

  // Function to delete a completed complaint
  void _deleteComplaint(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Complaint?"),
          content: Text("Are you sure you want to delete this complaint?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _firestore.collection("complaints").doc(docId).delete();
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // Light green background
      appBar: AppBar(
        title: Text("Complaints", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Pending Replies"),
            Tab(text: "Completed Replies"),
          ],
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComplaintList(isPending: true),
          _buildComplaintList(isPending: false),
        ],
      ),
    );
  }

  Widget _buildComplaintList({required bool isPending}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("complaints").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No complaints found"));
        }

        var complaints = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return isPending ? (data["reply"] == null || data["reply"] == "")
                           : (data["reply"] != null && data["reply"] != "");
        }).toList();

        if (complaints.isEmpty) {
          return Center(
            child: Text(
              isPending ? "No pending complaints" : "No completed complaints",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            var data = complaints[index].data() as Map<String, dynamic>;
            String docId = complaints[index].id;
            String complaintText = data["complaint"] ?? "No complaint";
            String replyText = data["reply"]?.isNotEmpty == true
                ? data["reply"]
                : "Pending reply";
            Timestamp? timestamp = data["timestamp"];
            String formattedDate = timestamp != null
                ? DateTime.fromMillisecondsSinceEpoch(
                        timestamp.millisecondsSinceEpoch)
                    .toString()
                : "No date";

            return Card(
              color: Colors.green[400],
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  "Complaint: $complaintText",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reply: $replyText",
                      style: TextStyle(
                        color: replyText == "Pending reply" ? Colors.red[100] : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Date: $formattedDate",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                trailing: isPending
                    ? IconButton(
                        icon: Icon(Icons.reply, color: Colors.white),
                        onPressed: () {
                          _showReplyDialog(docId,
                              replyText == "Pending reply" ? "" : replyText);
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteComplaint(docId),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
