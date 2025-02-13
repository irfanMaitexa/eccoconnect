import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminCompletedOrdersScreen extends StatefulWidget {
  @override
  _AdminCompletedOrdersScreenState createState() => _AdminCompletedOrdersScreenState();
}

class _AdminCompletedOrdersScreenState extends State<AdminCompletedOrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("Completed Orders", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTotalQuantityCard(),
          Expanded(child: _buildOrderList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.attach_money, color: Colors.white),
        onPressed: () => _showSetPaymentDialog(context),
      ),
    );
  }

  Widget _buildTotalQuantityCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("requests").where("status", isEqualTo: "Completed").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _loadingIndicator();
        int totalQuantity = snapshot.data!.docs.fold(0, (sum, doc) {
          String quantityStr = (doc.data() as Map<String, dynamic>)["quantity"] ?? "0";
          return sum + int.tryParse(quantityStr.toString())!;
        });

        return Card(
          margin: EdgeInsets.all(10),
          color: Colors.green[400],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.white, size: 35),
            title: Text("Total Waste Collected", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            trailing: Text("$totalQuantity kg", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("requests").where("status", isEqualTo: "Completed").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _loadingIndicator();
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No completed orders", style: TextStyle(fontSize: 18, color: Colors.black54)));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildOrderCard(data);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(data["imageUrl"] ?? ""),
        ),
        title: Text(data["name"] ?? "Unknown Driver", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Material: ${data["material"] ?? "N/A"}", style: TextStyle(color: Colors.grey[700])),
            Text("Quantity: ${data["quantity"] ?? "0"}", style: TextStyle(color: Colors.grey[700])),
          ],
        ),
        
      ),
    );
  }

void _showSetPaymentDialog(BuildContext context) async {
  TextEditingController _priceController = TextEditingController();

  // Fetch the existing payment for the order
  final snapshot = await _firestore.collection("wasteprice").get();
  if (snapshot.docs.isNotEmpty) {
    _priceController.text = (snapshot.docs[0].data() as Map<String, dynamic>)["payment"] ?? "";
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Update Payment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.currency_rupee, color: Colors.green),
                hintText: "Enter amount in ₹",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.green[50],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text("Cancel", style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_priceController.text.isNotEmpty) {
                      await _firestore.collection("wasteprice").doc(snapshot.docs[0].id).set({
                        "payment": _priceController.text,
                      }, SetOptions(merge: true));
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text("Update", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

  Widget _loadingIndicator() {
    return Center(child: CircularProgressIndicator(color: Colors.green));
  }
}
