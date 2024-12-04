import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;

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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String? username = "";
  String? image = "";
  String? email = "";
  String? role = "";

  Future<void> fetchUserData() async {
    // /userData/:userID
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    role = prefs.getString('role');
    String? token = prefs.getString('token');
    if (token == null) {
      _showSnackbar("No token");
      return;
    }

    //APi
    try {
      final url = Uri.parse('http://10.0.2.2:3000/userData/$userID');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': token ?? ""
        },
      );

      if (response.statusCode == 200) {
        final Map responseData = jsonDecode(response.body);
        setState(() {
          username = responseData['name'];
          email = responseData['email'];
          image = responseData['image'];
        });
      } else {
        debugPrint("Failed to load data: ${response.statusCode}");
        _showSnackbar("Failed to load data");
      }
    } catch (error) {
      debugPrint("Error fetching data: $error");
      _showSnackbar("Error");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserData();
  }

  // clear Local storage when user log out
  void clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _showSnackbar("Logged out successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '$role PROFILE',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.memory(
                  base64Decode(image ?? ""),
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username ?? 'Default Username',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        email ?? 'Default Username',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                email: email ?? "",
                                username: username ?? "",
                                // add other parameters as needed
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          backgroundColor: Colors.grey[300],
                        ),
                        child: Text(
                          'EDIT PROFILE',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildMenuButton(Icons.favorite_border, 'FAVOURITES'),
            _buildMenuButton(Icons.language, 'LANGUAGE'),
            _buildMenuButton(Icons.settings, 'APP SETTING'),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                clearLocalStorage();
                Navigator.pushNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[100],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'LOG OUT',
                style: TextStyle(color: Colors.black),
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

  Widget _buildMenuButton(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

// for edit profile
class EditProfileScreen extends StatefulWidget {
  String username;
  String email;
  EditProfileScreen({Key? key, required this.username, required this.email}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  File? _profileImage; // For storing the selected profile image

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
  final prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt("userID");
  String? token = prefs.getString("token");

  if (userId == null || token == null) {
    _showSnackbar("User not authenticated");
    return;
  }

  try {
    final url = Uri.parse('http://10.0.2.2:3000/userEdit');
    var request = http.MultipartRequest('POST', url);

    request.headers['authorization'] = token;
    debugPrint(_passwordController.text);

    // Get values, falling back to initial values if necessary
    String username = _usernameController.text.isNotEmpty ? _usernameController.text : widget.username;
    String email = _emailController.text.isNotEmpty ? _emailController.text : widget.email;

    // Add form fields
    request.fields['userID'] = userId.toString();
    request.fields['NewUsername'] = username;
    request.fields['NewEmail'] = email;
    request.fields['NewPassword'] = _passwordController.text;

    // Add the image file if selected
    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile',
        _profileImage!.path,
      ));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> parsedData = jsonDecode(responseData);
      // go back to user profile
      Navigator.pushReplacementNamed(context , '/student_Profile');
    } else {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> parsedData = jsonDecode(responseData);
      _showSnackbar(parsedData['message']);
      debugPrint("Failed to update profile: ${response.statusCode}");
    }
  } catch (error) {
    debugPrint("Error updating profile: $error");
  }
}


  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                SizedBox(height: 6),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'CHANGE PROFILE',
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ),
                SizedBox(height: 16),
                _buildTextField(
                    _usernameController, 'USERNAME', 'Enter your username'),
                SizedBox(height: 8),
                _buildTextField(_emailController, 'EMAIL', 'Enter your email'),
                SizedBox(height: 8),
                _buildTextField(
                    _passwordController, 'PASSWORD', 'Enter your password',
                    isObscure: true),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'UPDATE',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String placeholder, {
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.green[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            hintText: placeholder,
            hintStyle: TextStyle(
                color: Color.fromARGB(255, 145, 145, 145), fontSize: 10),
          ),
        ),
      ],
    );
  }
}