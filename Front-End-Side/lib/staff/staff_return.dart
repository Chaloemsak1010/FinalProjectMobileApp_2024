import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Model class for Asset
class Asset {
  final int borrowingID;
  final int assetID;
  final String assetName;
  final String borrower;
  final String approver;
  final String dueDate;
  final String image; // For base64 encoded image

  Asset({
    required this.borrowingID,
    required this.assetID,
    required this.assetName,
    required this.borrower,
    required this.approver,
    required this.dueDate,
    required this.image,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      borrowingID: json['borrowingID'],
      assetID: json['asset_id'],
      assetName: json['asset_name'],
      borrower: json['borrower'],
      approver: json['lender'],
      dueDate: json['return_date'],
      image: json['image'] ?? "",
    );
  }
}

class StaffReturn extends StatefulWidget {
  const StaffReturn({Key? key}) : super(key: key);

  @override
  State<StaffReturn> createState() => _StaffReturnState();
}

class _StaffReturnState extends State<StaffReturn> {
  List<Asset> assets = [];

  // Fetch asset data from the API
  Future<void> fetchAssetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        debugPrint("Token not found. Please log in again.");
        return;
      }

      final url = Uri.parse('http://10.0.2.2:3000/staff/showReturn');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        setState(() {
          assets = responseData.map((json) => Asset.fromJson(json)).toList();
        });
      } else {
        setState(() {
          assets = [];
        });
        debugPrint("Failed to load data: ${response.statusCode}");
      }
    } catch (error) {
      debugPrint("Error fetching data: $error");
    }
  }

  // Function to receive an asset
  Future<void> receiveAsset(int assetID, int borrowingID) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      String? staffName = prefs.getString("username");
      

      if (token == null || token.isEmpty || staffName == null) {
        debugPrint("Missing token or staff name. Please log in again.");
        return;
      }

      final url = Uri.parse('http://10.0.2.2:3000/staff/recieve');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': token,
        },
        body: jsonEncode({
          'staff_name': staffName,
          'asset_id': assetID,
          'borrowingID': borrowingID,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("Asset received successfully!");
        fetchAssetData(); // Refresh the asset list
      } else {
        debugPrint("Failed to receive asset: ${response.body}");
      }
    } catch (error) {
      debugPrint("Error receiving asset: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAssetData();
  }

  int _selectedIndex = 2;

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Get Returning Assets",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Sans-serif',
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: assets.isEmpty
          ? const Center(
              child: Text(
                "No assets to display.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return AssetCard(
                  asset: asset,
                  onReceive: () {
                    receiveAsset(asset.assetID, asset.borrowingID);
                  },
                );
              },
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
            label: 'Stats',
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

// Asset card widget
class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onReceive;

  const AssetCard({
    required this.asset,
    required this.onReceive,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: asset.image.isNotEmpty
                      ? Image.memory(
                          base64Decode(asset.image),
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey),
                ),
                const SizedBox(width: 16.0),
                Text(
                  asset.assetName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("BORROWER"),
                    Text(
                      asset.borrower,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DUE DATE"),
                    Text(
                      asset.dueDate,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: onReceive,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBFD3BE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                ),
                child: const Text(
                  "Receive Asset",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
