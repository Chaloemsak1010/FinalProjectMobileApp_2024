import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RequestStat extends StatefulWidget {
  const RequestStat({super.key});

  @override
  _RequestStatState createState() => _RequestStatState();
}

class _RequestStatState extends State<RequestStat> {
  Map<String, dynamic> data = {};
  String bookStatus = "PENDING";
  String returnDate = "24/12/2024";
  int _selectedIndex = 1;
  bool isDataLoaded = false;

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> getDataCheckRequest() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve token and borrowing ID
    String? token = prefs.getString("token");
    if (token == null) {
      _showSnackbar("No token");
      setState(() {
        isDataLoaded = true;
      });
      return;
    }
    int? borrowingID = prefs.getInt("borrowingID");
    if (borrowingID == null) {
      _showSnackbar("No borrowing request found");
      setState(() {
        isDataLoaded = true;
      });
      return;
    }
    int? userID = prefs.getInt("userID");

    // API request
    final url = Uri.parse('http://10.0.2.2:3000/student/check_request');
    final response = await http.post(
      url,
      body: jsonEncode({"borrowingID": borrowingID, "userID": userID}),
      headers: {'Content-Type': 'application/json', 'authorization': token},
    );

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        isDataLoaded = true;
      });
    } else {
      debugPrint("Failed to load data: ${response.statusCode}");
      setState(() {
        isDataLoaded = true;
      });
    }
  }

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
  void initState() {
    super.initState();
    getDataCheckRequest();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as String?;
    if (arguments != null && arguments.isNotEmpty) {
      returnDate = arguments;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isDataLoaded
          ? (data.isEmpty
              ? Center(
                child: Container(
                  color:Colors.green[100],
                  padding: EdgeInsets.all(20),
                  child: const Text(
                  "No borrowing request found",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                  ),    
                )
                ),
              )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Request Status Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8E3D8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'REQUEST STATUS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      // Book Status Container
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(30),
                        height: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8E3D8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (data["image"] != null)
                              Image.memory(
                                base64Decode(data["image"]),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                            else
                              const Placeholder(
                                fallbackHeight: 60,
                                fallbackWidth: 60,
                                color: Colors.grey,
                              ),
                            const SizedBox(height: 10),
                            // Book Details Text
                            Text(
                              '${data["asset_name"] ?? "Unknown"}\nSTATUS: ${data["status"] ?? "Unknown"}\nRETURNING DATE: ${data["return_date"] ?? returnDate}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ))
          : Center(child: CircularProgressIndicator()),
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
