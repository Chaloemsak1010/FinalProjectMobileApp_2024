import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LenderDashboard extends StatefulWidget {
  const LenderDashboard({super.key});

  @override
  _LenderDashboardState createState() => _LenderDashboardState();
}

class _LenderDashboardState extends State<LenderDashboard> {
  late Timer _timer;
  String _currentDateTime =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  int _selectedIndex = 1;
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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, dynamic> dataBody = {};
  Map<String, double> mapStatus = {};
  // number of user
  int student = 0;
  int lender = 0;
  int staff = 0;
  int totalUser = 0;
  int totalAsset = 0;

  bool _isLoading = true;

  Future<void> getDashboardData() async {
    setState(() => _isLoading = true); // Show loader
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      if (token == null) {
        _showSnackbar("No token");
        return;
      }
      final url = Uri.parse('http://10.0.2.2:3000/dashboard');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'authorization': token},
      );

      if (response.statusCode == 200) {
        setState(() {
          dataBody = jsonDecode(response.body);
          student = dataBody['user_count'][0]['count'];
          lender = dataBody['user_count'][1]['count'];
          staff = dataBody['user_count'][2]['count'];
          totalUser = student + lender + staff;
          mapStatus.clear();
          
          for (var statusEntry in dataBody["status_count"]) {
            totalAsset += (statusEntry["count"] as num).toInt();
            mapStatus[statusEntry["status"]] = statusEntry["count"].toDouble();
          }
          _isLoading = false;
        });
      } else {
        debugPrint("Failed to load data: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    getDashboardData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
  }

  List<Color> generateColorList(int count) {
    return List.generate(
        count, (index) => Colors.primaries[index % Colors.primaries.length]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SizedBox(
          height: 20,
        ),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : buildDashboardContent(),
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

 Widget buildDashboardContent() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Today: $_currentDateTime",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Text('Total assets = $totalAsset', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        mapStatus.isNotEmpty
            ? PieChart(
                dataMap: mapStatus,
                animationDuration: const Duration(milliseconds: 800),
                chartLegendSpacing: 20,
                chartRadius: MediaQuery.of(context).size.width / 2.7,
                colorList: const [
                  Colors.redAccent,
                  Colors.greenAccent,
                  Colors.grey,
                  Colors.orange,
                ],
                initialAngleInDegree: 0,
                chartType: ChartType.ring,
                ringStrokeWidth: 32,
                legendOptions: const LegendOptions(
                  showLegendsInRow: true,
                  legendPosition: LegendPosition.bottom,
                  showLegends: true,
                  legendShape: BoxShape.circle,
                  legendTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: false,
                  decimalPlaces: 1,
                ),
              )
            : const Center(
                child: Text(
                  "No data available for the chart.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'TOTAL USERS = $totalUser',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Container(
                color: const Color.fromARGB(255, 134, 250, 139),
                width: 100,
                height: 100,
                child: Align(
                  alignment: Alignment.center,
                  child: Text('Staff = $staff'),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: const Color.fromARGB(255, 245, 122, 216),
                width: 100,
                height: 200,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Students = $student',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: const Color.fromARGB(255, 255, 147, 142),
                width: 100,
                height: 100,
                child: Align(
                  alignment: Alignment.center,
                  child: Text('Lecturer = $lender'),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

}


