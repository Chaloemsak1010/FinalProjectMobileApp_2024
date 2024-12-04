// ignore: file_names
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookAssetLender extends StatefulWidget {
  const BookAssetLender({super.key});

  @override
  State<BookAssetLender> createState() => _BookAssetLenderState();
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

  // Factory constructor to create an Asset from JSON
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      image: json['image'],
    );
  }
}

class _BookAssetLenderState extends State<BookAssetLender> {
  // fetch data browse asset list
  List<Asset> assets = [];
  List<Asset> initAssets = [];
  List<Asset> filteredAssets = [];
  final TextEditingController searchController = TextEditingController();

  Future<void> fetchAssetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      // debugPrint("Token: $token");

      // API endpoint
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

// Filter assets based on search query
  void _filterAssets(String query) {
    if (query.trim().isEmpty){
      // if we put space bar will show initAssets
      setState(() {
        assets = initAssets ;
      });
      return ;
    }
    setState(() {
      assets = initAssets
          .where(
              (asset) => asset.name.toLowerCase().contains(query.trim().toLowerCase()))
          .toList();
      
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAssetData();
    
    // Problem: A student can borrow only one asset a day.
    // fetch data from borrowing when status = pending and id = userID
    // if res.lengh == 0 mean user can book another but if != 0 user will can not book that time
  }

  void _updateAssetStatus(int id, String newStatus) {
    setState(() {
      for (var asset in assets) {
        if (asset.id == id) {
          asset.status = newStatus;
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AssetPage(
      assets: assets,
      onUpdateStatus: _updateAssetStatus,
      searchController: searchController,
      onSearchChanged: _filterAssets,
    );
  }
}

class AssetPage extends StatefulWidget {
  final List<Asset> assets;
  final Function(int, String) onUpdateStatus;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;

  const AssetPage({
    super.key,
    required this.assets,
    required this.onUpdateStatus,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/lender_BrowseAsset');
        break;
      case 1:
        Navigator.pushNamed(context, '/lender_Dashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/lender_Request');
        break;
      case 3:
        Navigator.pushNamed(context, '/lender_History');
        break;
      case 4:
        Navigator.pushNamed(context, '/lender_Profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: widget.searchController,
              onChanged:
                  widget.onSearchChanged, // Update filtered assets on search
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: widget.assets.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: widget.assets[index].status != "Available"
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestStatusPage(
                                asset: widget.assets[index],
                                onUpdateStatus: widget.onUpdateStatus,
                              ),
                            ),
                          );
                        },
                  child: AssetCard(asset: widget.assets[index]),
                );
              },
            ),
          ),
        ],
      ),
     bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromARGB(255, 138, 181, 139),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Check request',
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

  const AssetCard({super.key, required this.asset});

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
      case "Disabled":
      default:
        statusColor = Colors.red;
        break;
    }

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
          Text(
            asset.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Status: ${asset.status}',
            style: TextStyle(color: statusColor),
          ),
        ],
      ),
    );
  }
}

// sub page for send request
class RequestStatusPage extends StatefulWidget {
  final Asset asset;
  final Function(int, String) onUpdateStatus;

  const RequestStatusPage(
      {super.key, required this.asset, required this.onUpdateStatus});

  @override
  State<RequestStatusPage> createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  String _startDate = '';
  String _endDate = '';
  
  // request
  Future<void> request(int asset_id  ) async{ 
    final prefs = await SharedPreferences.getInstance();
    int? user_id = prefs.getInt("userID");

    //APi
    try {
      String? token = prefs.getString("token");

      // API endpoint
      final url = Uri.parse('http://10.0.2.2:3000/student/request');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': token ?? ""
        },
        body: jsonEncode({ "asset_id" : asset_id , "user_id": user_id , "borrow_date": _startDate , "return_date": _endDate }),
      );

      if (response.statusCode == 200) {
        final Map responseData = jsonDecode(response.body);
        // save borrowingID as local storage
        await prefs.setInt("borrowingID" , responseData['borrowingID']);
        widget.onUpdateStatus(widget.asset.id, 'Pending');
        if (!mounted){return;}
        Navigator.pushNamed(
          context,
          '/student_Request',
          arguments: _endDate,
        );

        
      } else {
        debugPrint("Failed to load data: ${response.statusCode}");
      }
    } catch (error) {
      debugPrint("Error fetching data: $error");
    }

  }
 
  

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  void selectDateStart() async {
    DateTime? dt = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: startDate,
        lastDate: DateTime(2024, 12, 31));
    // change the value to new value
    if (dt != null) {
      setState(() {
        _startDate = '${dt.year}-${dt.month}-${dt.day}';
        startDate = dt;
      });
    }
  }

  void selectDateEnd() async {
    DateTime? endDateSelect = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime(2024, 12, 31),
    );

    // Validate the selected end date
    if (endDateSelect != null) {
      if (endDateSelect.isAfter(startDate) || endDateSelect == startDate) {
        // Valid end date
        setState(() {
          _endDate =
              '${endDateSelect.year}-${endDateSelect.month}-${endDateSelect.day}';
          endDate = endDateSelect;
        });
      } else {
        // Invalid end date
        setState(() {
          _endDate = 'Invalid end date';
        });
      }
    }
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/student_BrowseAsset');
        break;
      case 1:
        Navigator.pushNamed(context, '/student_Request');
        break;
      case 2:
        Navigator.pushNamed(context, '/student_History');
        break;
      case 3:
        Navigator.pushNamed(context, '/student_Profile');
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'YOU SELECT',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: 200,
              color: Colors.white,
              child: Center(
                child: Image.memory(
                  base64Decode(widget.asset.image),
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.asset.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'STATUS: ${widget.asset.status.toUpperCase()}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // noww
            Row(
              children: [
                FilledButton.icon(
                  onPressed: selectDateStart,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Borrowing Date'),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(_startDate),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: selectDateEnd,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Returning Date'),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(_endDate),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.asset.status == 'Available'
                  ? () => request(widget.asset.id)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(183, 150, 190, 127),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SEND REQUEST TO BORROW',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromARGB(255, 138, 181, 139),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Check request',
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
