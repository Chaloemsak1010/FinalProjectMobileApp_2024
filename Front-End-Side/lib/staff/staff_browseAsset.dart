import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalproject/staff/staff_add_asset.dart';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class HomePageStaff extends StatefulWidget {
  const HomePageStaff({super.key});

  @override
  _HomePageStaffState createState() => _HomePageStaffState();
}

class Asset {
  final int id;
  final String name;
  String status;
  final String image;

  Asset(
      {required this.id,
      required this.name,
      required this.status,
      required this.image});

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      image: json['image'],
    );
  }
}

class _HomePageStaffState extends State<HomePageStaff> {
  List<Asset> assets = [];
  List<Asset> initAssets = [];
  final TextEditingController searchController = TextEditingController();

  Future<void> fetchAssetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final url = Uri.parse('http://10.0.2.2:3000/browseAsset');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': token ?? ""
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          assets = responseData.map((json) => Asset.fromJson(json)).toList();
          initAssets = assets;
        });
      } else {
        debugPrint("Failed to load data: ${response.statusCode}");
      }
    } catch (error) {
      debugPrint("Error fetching data: $error");
    }
  }

  void _updateAssetStatusAPI(int assetId, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
     

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/staff/disable'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': token ?? ""
        },
        body: jsonEncode({
          'asset_id': assetId,
          'newStatus': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        // Successfully updated status
        print("Asset status updated to $newStatus");
      } else {
        // Handle failure
        print("Failed to update asset status: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  void _filterAssets(String query) {
    setState(() {
      assets = query.isEmpty
          ? initAssets
          : initAssets
              .where((asset) =>
                  asset.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAssetData();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/staff_BrowseAsset');
        break;
      case 1:
        Navigator.pushNamed(context, '/staff_Dashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/staff_Return');
        break;
      case 3:
        Navigator.pushNamed(context, '/staff_History');
        break;
      case 4:
        Navigator.pushNamed(context, '/staff_Profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E4D5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFD9E4D5),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterAssets,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return GestureDetector(
                  onTap: asset.status != "Available" ? null : () {},
                  child: AssetCard(
                    asset: asset,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAssets(
                            asset: asset, // Pass the full asset object
                          ),
                        ),
                      );
                    },
                    onToggle: (bool value) {
                      String newStatus = value ? "Available" : "Disable";

                      // Check if status is Borrowed or Pending
                      if (asset.status == "Borrowed" ||
                          asset.status == "Pending") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Cannot change status. Asset is borrowed or pending")),
                        );
                        return;
                      }

                      // Update status locally
                      setState(() {
                        asset.status = newStatus;
                      });

                      // Persist the change via API
                      _updateAssetStatusAPI(asset.id, newStatus);
                    },
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAssets()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Color.fromARGB(255, 138, 181, 139),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: 'Reload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;

  const AssetCard({
    super.key,
    required this.asset,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (asset.status) {
      case "Available":
        statusColor = Colors.green;
        break;
      case "Pending":
        statusColor = Colors.blue;
        break;
      case "Borrowed":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    bool isEditable = asset.status != "Borrowed" && asset.status != "Pending";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.memory(
            base64Decode(asset.image),
            fit: BoxFit.cover,
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 10),
          Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(
            'Status: ${asset.status}',
            style: TextStyle(color: statusColor),
          ),
          ElevatedButton(
            onPressed: isEditable
                ? onEdit
                : null, // Disable Edit button if not editable
            child: const Text('Edit'),
          ),
          Switch(
            value: asset.status == "Available",
            onChanged:
                isEditable ? onToggle : null, // Disable Switch if not editable
          ),
        ],
      ),
    );
  }
}

class EditAssets extends StatefulWidget {
  final Asset asset;

  const EditAssets({super.key, required this.asset});

  @override
  _EditAssetsState createState() => _EditAssetsState();
}

class _EditAssetsState extends State<EditAssets> {
  late TextEditingController _nameController;
  late String _status; // Store the current status
  late Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset.name);
    _status = widget.asset.status; // Initialize with the current asset status
    _selectedImageBytes =
        widget.asset.image.isNotEmpty ? base64Decode(widget.asset.image) : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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

  Future<void> _updateAsset() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid asset name')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:3000/staff/edit'),
      );

      // Add fields to the request
      request.fields['asset_id'] = widget.asset.id.toString();
      request.fields['newName'] = _nameController.text;
      request.fields['newStatus'] = _status;

      // Add token to header for authorization
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // If an image is selected, add it to the multipart request
      if (_selectedImageBytes != null) {
        var imageFile = http.MultipartFile.fromBytes(
          'asset', // Field name expected by the server
          _selectedImageBytes!,
          filename: 'uploaded_image.jpg', // Provide a file name
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(imageFile);
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asset updated successfully')),
        );
        Navigator.pushReplacementNamed(context , "/staff_BrowseAsset"); // Go back after update
      } else {
        final responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update asset: $responseBody')),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating asset')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E4D5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Asset',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  Container(
                    width: double.infinity,
                    height: 150,
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
                            child: Text('No Image Selected'),
                          ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Select New Image'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Name',
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Status',
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _status,
                    onChanged: (newValue) {
                      setState(() {
                        _status = newValue!;
                      });
                    },
                    items: <String>['Available', 'Disable']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.update),
              label: const Text('Update Asset'),
              onPressed: _updateAsset, // Fixed the issue here
            ),
          ],
        ),
      ),
    );
  }
}
