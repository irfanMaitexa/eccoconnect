import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

class UserUploadScreen extends StatefulWidget {
  final String filePath;

  const UserUploadScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  _UserUploadScreenState createState() => _UserUploadScreenState();
}

class _UserUploadScreenState extends State<UserUploadScreen> {
  late Future<Map<String, dynamic>> _uploadResponse;

  @override
  void initState() {
    super.initState();
    _uploadResponse = _uploadFile(widget.filePath);
  }

  Future<Map<String, dynamic>> _uploadFile(String filePath) async {
    var uri = Uri.parse('https://example.com/upload');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
    ));

    var response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return Map<String, dynamic>.from(responseData as Map);
    } else {
      throw Exception('Failed to upload file');
    }
  }

  String _formatDisposalInstructions(Map<String, dynamic> instructions) {
    return '''
    🗑️ Disposal: ${instructions['disposal']}
    ♻️ Recycling: ${instructions['recycling']}
    🌱 Composting: ${instructions['composting']}
    ⚠️ Hazardous: ${instructions['hazardous']}
    💡 Tips: ${instructions['tips']}
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload & Predict'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.lightGreenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _uploadResponse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              final predictedClass = data['predicted_class'] ?? 'Unknown';
              final disposalInstructions = _formatDisposalInstructions(data['disposal_instructions'] ?? {});

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.file(
                          File(widget.filePath),
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      color: Colors.white,
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Predicted Class',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              predictedClass,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Disposal Instructions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              disposalInstructions,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text(
                  'No data available.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
