import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class AddAssets extends StatefulWidget {
  @override
  _AddAssetsState createState() => _AddAssetsState();
}

class _AddAssetsState extends State<AddAssets> {
  final TextEditingController _assetNameController = TextEditingController();
  Uint8List? _selectedImageBytes;

  // Pick image method for Flutter Web
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      if (bytes.isNotEmpty) {
        setState(() {
          _selectedImageBytes = bytes;
        });
      } else {
        print("Failed to load image bytes.");
      }
    }
  }

  // Add asset method (your API call logic)
  Future<void> _addAsset() async {
    if (_assetNameController.text.isEmpty || _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter asset name and select an image")),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      // Create MultipartRequest
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://10.0.2.2:3000/staff/add'), // Replace with your API URL
      );

      // Add fields
      request.fields['asset_name'] = _assetNameController.text;

      // Convert image bytes to file and add it
      var multipartFile = http.MultipartFile.fromBytes(
        'asset', // This should match the key in the backend (field name)
        _selectedImageBytes!,
        filename: "asset_image.jpg", // Give a name to the image file
      );
      request.files.add(multipartFile);

      // Add token to header for authorization
      if (token != null) {
        request.headers['authorization'] = token;
      }

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Asset added successfully")),
        );
        Navigator.pushReplacementNamed(context ,"/staff_BrowseAsset"); // Navigate back after success
      } else {
        var responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add asset: $responseBody")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E4D5),
      appBar: AppBar(
        title: const Text(
          'Add New Asset',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImageBytes != null
                      ? Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Text(
                            "Tap to select an image",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Asset Name',
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _assetNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _addAsset,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    iconColor: Colors.black // Button color
                    ),
              ),
              const Text('Save'),
            ],
          ),
        ),
      ),
    );
  }
}
