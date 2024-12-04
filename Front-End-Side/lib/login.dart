// Update by kean

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoginForm(),
    );
  }
}


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Check if email or password fields are empty
    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Please enter both email and password.");
      return;
    }

    // API endpoint
    final url = Uri.parse('http://10.0.2.2:3000/login');
    
    try {
      // Send login request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map;
        final userID = responseData['id'];
        final username = responseData['username'];
        final role = responseData['role'];
        final token = responseData['token'];
        final image = responseData['image'];
        //Save user data to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userID', userID);
        await prefs.setString('username', username);
        await prefs.setString('role', role);
        await prefs.setString('token', token);
        await prefs.setString('image', image);
        await prefs.setString('email' , email);
        // should add set borrowingID if student already booking

        // String? testRole = prefs.getString('role');
        // debugPrint(prefs.getString('token'));

        // Navigate based on user role
        _navigateBasedOnRole(role);
      } else {
        _showSnackbar("Invalid email or password.");
      }
    } catch (e) {
      // print(e);
      _showSnackbar("Error connecting to server. Please try again.");
    }
  }

  // Helper method to show snackbar
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper method to navigate based on role
  void _navigateBasedOnRole(String? role) {
    switch (role) {
      case 'Student':
        Navigator.pushNamed(context, '/student_BrowseAsset');
        break;
      case 'Staff':
        Navigator.pushNamed(context, '/staff_BrowseAsset');
        break;
      case 'Lender':
        Navigator.pushNamed(context, '/lender_BrowseAsset');
        break;
      default:
        _showSnackbar("Role not recognized.");
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage('assets/images/Login.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          const Icon(
            Icons.menu_book,
            size: 80,
            color: Colors.black,
          ),
          const SizedBox(height: 20),
          const Text(
            'LOGIN',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE0F2D9),
                hintText: 'EMAIL ADDRESS',
                hintStyle: const TextStyle(color: Colors.black45),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE0F2D9),
                hintText: 'PASSWORD',
                hintStyle: const TextStyle(color: Colors.black45),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA8BCA1),
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: loginUser,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
