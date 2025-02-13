import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:eccoconnect/user/user_upload_file_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserRequestScreen extends StatefulWidget {
  const UserRequestScreen({super.key});

  @override
  _UserRequestScreenState createState() => _UserRequestScreenState();
}

class _UserRequestScreenState extends State<UserRequestScreen> with SingleTickerProviderStateMixin {
  final _materialController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dateController = TextEditingController();
  File? _image; // To store the selected image
  late TabController _tabController; // TabController for managing the tabs

  final List<Map<String, String>> pendingRequests = [
    {'material': 'Plastic', 'quantity': '5 kg', 'date': '2025-01-07'},
  ];

  final List<Map<String, String>> acceptedRequests = [
    {'material': 'Glass', 'quantity': '10 kg', 'date': '2025-01-05'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {

      
    },);
  }

bool isloading = false;

 Future<void> _addRequest() async {

  setState(() {
    isloading = true;
    
  });
  if (_materialController.text.isEmpty || _quantityController.text.isEmpty || _dateController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all details')));
    return;
  }

  String? imageUrl;

  final cloudinary = Cloudinary.signedConfig(
    apiKey: '175664883731164',
    apiSecret: 'Zgz36gtidS3h7L_CYYXbpiUkVO0',
    cloudName: 'dbh5ptgio',
  );

  // Upload image to Cloudinary
  if (_image != null) {
    try {
      final response = await cloudinary.upload(
        file: _image!.path,
        fileBytes: null,
        resourceType: CloudinaryResourceType.image,
        folder: 'waste_requests', // Optional: Specify folder in Cloudinary
      );
      imageUrl = response.secureUrl; // Get the secure URL of the uploaded image
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      return;
    }
  }

  try {
    // Get the current user's ID (if using Firebase Authentication)
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    // Add the request to Firestore
    await FirebaseFirestore.instance.collection('requests').add({
      'userId': userId,
      'material': _materialController.text,
      'quantity': _quantityController.text,
      'date': _dateController.text,
      'imageUrl': imageUrl ?? '', // Add the image URL or an empty string
      'createdAt': FieldValue.serverTimestamp(), // Add timestamp
      'status' : 'pending',
      'isAccepted' : false,
      'paymentStatus' : false,
    });

    // Update local state
    setState(() {
     
      _materialController.clear();
      _quantityController.clear();
      _dateController.clear();
      _image = null; // Clear the selected image
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request added successfully')));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add request: $e')));
  }

  setState(() {
    isloading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waste Request', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
        
      ),
      body: isloading ? Center(child: CircularProgressIndicator(color: Colors.lightGreen,),) : Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Waste Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                _buildTextField('Material Type', _materialController),
                _buildTextField('Quantity (kg)', _quantityController),
                _buildTextField('Request Date', _dateController),
                SizedBox(height: 20),
                _image == null
                    ? Text('No image selected')
                    : Stack(
                        children: [
                          Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Pick Waste Image', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    
                  ],
                ),
                SizedBox(height: 40,),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addRequest,
                        child: Text('Request Pickup', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ImageUploadScreen(),));
        },
        backgroundColor: Colors.lightGreen,
        child: Icon(Icons.camera_alt, color: Colors.white),
        tooltip: 'Pick Waste Image',
      ),
    );
  }

 Widget _buildTextField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: TextField(
      controller: controller,
      readOnly: label == 'Request Date', // Make it read-only for date
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      onTap: label == 'Request Date'
          ? () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (selectedDate != null) {
                setState(() {
                  controller.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format as yyyy-MM-dd
                });
              }
            }
          : null,
    ),
  );
}


  Widget _buildRequestList(List<Map<String, String>> requests) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: ListTile(
            title: Text(request['material']!),
            subtitle: Text('Quantity: ${request['quantity']} \nDate: ${request['date']}'),
            contentPadding: EdgeInsets.all(16),
            tileColor: Colors.white,
            trailing: _tabController.index == 0
                ? IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        acceptedRequests.add(request);
                        pendingRequests.removeAt(index);
                      });
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
