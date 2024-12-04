import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class LenderHistory extends StatefulWidget {
  const LenderHistory({super.key});

  @override
  State<LenderHistory> createState() => _LenderHistoryState();
}

class _LenderHistoryState extends State<LenderHistory> {
  List<dynamic> responseData = [];
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> getLenderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt("userID");
    String? token = prefs.getString("token");
    if (token == null) {
      _showSnackbar("No token");
      return;
    }
    // debugPrint(userID.toString());
    // API endpoint
    final url = Uri.parse('http://10.0.2.2:3000/lender/history/$userID');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'authorization': token},
    );

    if (response.statusCode == 200) {
      setState(() {
        responseData = jsonDecode(response.body);
      });
    } else {
      debugPrint("Failed to load data: ${response.statusCode}");
    }
  }

  int _selectedIndex = 3;

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
  void initState() {
    // TODO: implement initState
    super.initState();
    getLenderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFD7E6CF), // Background color from your image
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        automaticallyImplyLeading: false,
      ),
      body: responseData.isEmpty
          ? Center(
              child: Container(
                  color: Colors.green[100],
                  padding: EdgeInsets.all(20),
                  child: const Text(
                    "No History found !!!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  )),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Label(title: 'ALL'),
                  // SizedBox(height: 10,),
                  Expanded(
                    child: ListView.builder(
                      itemCount: responseData.length,
                      itemBuilder: (context, index) {
                        final item = responseData[index];
                        return BookCard(
                          image: item['image'] ?? 0,
                          bookTitle: item['asset_name'] ?? 'Unknown',
                          Borrower: item['Borrower'] ?? 'Unknown',
                          Approver: item['Lender'] ?? 'Unknown',
                          Receiver: item['Receiver'] ??
                              'No Cuz,Disapprove or Not yet return',
                          BorrowDate: item['borrow_date'] ?? 'Unknown',
                          DueDate: item['return_date'] ?? 'Unknown',
                        );
                      },
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

class Label extends StatelessWidget {
  final String title;
  const Label({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String image;
  final String bookTitle;
  final String Borrower;
  final String Approver;
  final String Receiver;
  final String BorrowDate;
  final String DueDate;

  const BookCard({
    required this.image,
    required this.bookTitle,
    required this.Borrower,
    required this.Approver,
    required this.Receiver,
    required this.BorrowDate,
    required this.DueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.memory(
                base64Decode(image ?? ""),
                fit: BoxFit.cover,
                width: 60,
                height: 60,
              ),
              const SizedBox(width: 10),
              Text(
                bookTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BookDetailRow(label: 'Borrower', value: Borrower),
          BookDetailRow(
            label: 'Approver',
            value: Approver,
          ),
          BookDetailRow(
            label: 'Receiver',
            value: Receiver,
          ),
          BookDetailRow(
            label: 'Borrow Date',
            value: BorrowDate,
          ),
          BookDetailRow(
            label: 'Due Date',
            value: DueDate,
          ),
        ],
      ),
    );
  }
}

class BookDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const BookDetailRow({required this.label, required this.value});
  // const BookDetailRow({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          Text(
            value, // Placeholder for date
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
