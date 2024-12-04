import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LenderCheckRequest extends StatefulWidget {
  const LenderCheckRequest({super.key});

  @override
  State<LenderCheckRequest> createState() => _LenderCheckRequestState();
}

class _LenderCheckRequestState extends State<LenderCheckRequest> {
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  int _selectedIndex = 2;
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

  List<Map<String, dynamic>> data = [];
  // - see Request
  Future<void> getRequestData() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");
    if (token == null) {
      _showSnackbar("No token");
      return;
    }
    // debugPrint(userID.toString());
    // API endpoint
    final url = Uri.parse('http://10.0.2.2:3000/lender/seeRequest');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'authorization': token},
    );

    if (response.statusCode == 200) {
      setState(() {
        data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
      // debugPrint(data.length.toString()+"fsdfsdf");
    } else {
      debugPrint("Failed to load data: ${response.statusCode}");
    }
  }
  //- funcion to Approve or disaprove
  // { asset_id, borrowID, approved , lenderID }
  Future<void> permission(int asset_id , int borrowing_id , String result ) async{ // result is approve or disapprove
    debugPrint(result);
    debugPrint(borrowing_id.toString());

    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt("userID");

    //APi
    try {
      String? token = prefs.getString("token");

      // API endpoint
      final url = Uri.parse('http://10.0.2.2:3000/lender/approve');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': token ?? ""
        },
        body: jsonEncode({ "asset_id" : asset_id , "borrowID": borrowing_id , "approved": result , "lenderID" : userID  })
      );

      if (response.statusCode == 200) {
        final Map responseData = jsonDecode(response.body);
        _showSnackbar("successfully to ${responseData['msg']}");
        await Future.delayed(const Duration(seconds: 3));
        
        // Refresh the screen
        if (mounted) { // Check if the widget is still mounted to avoid errors
          Navigator.pop(context); // Remove the current screen
          Navigator.pushNamed(context, '/lender_Request'); // Push the same route again
        }
        

      } else {
        _showSnackbar("Failed to $result");
        debugPrint("Failed to load data: ${response.statusCode}");
      }
    } catch (error) {
      debugPrint("Error fetching data: $error");
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRequestData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.green[50], // Background color similar to the image
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "REQUEST TO BORROW",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // List of book requests
              Expanded(
                child: ListView.builder(
                  itemCount: data.length, // Number of book requests
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            // Image placeholder
                            Image.memory(
                                base64Decode(data[index]['image'].toString()),
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              ),
                            const SizedBox(width: 16),

                            // Book details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data[index]["asset_name"],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Borrow Date: ${data[index]['borrow_date']}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    "Return Date: ${data[index]['return_date']}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    "Borrower: ${data[index]['username']}", // You can vary names here
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),

                            // Allow and Disallow buttons
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    permission(data[index]['asset_id'] , data[index]['borrowing_id'] , "Approved");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text("ALLOW"),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    permission(data[index]['asset_id'] , data[index]['borrowing_id'] , "Disapproved");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text("DISALLOW"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
