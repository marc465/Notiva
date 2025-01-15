import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin(String username, String password) async {

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8080/login"),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
            'username': username,
            'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final accesstoken = response.headers['access_token'];
        final cookieHeader = response.headers['set-cookie'];
      
        await _secureStorage.write(key: "access_token", value: accesstoken);
        await _secureStorage.write(key: 'refresh_token', value: cookieHeader);
      
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(secureStorage: _secureStorage)));
      }
      else {
        print(response.statusCode);
        print(response.headers);
        print(response.body);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  int validateCredentials(String username, String password) {
    const int maxLength = 32; // Max length for username and password
    final RegExp validCharacters = RegExp(r'^[a-zA-Z0-9]+$'); // Only alphanumeric

    // Check if both fields are empty
    if (username.isEmpty && password.isEmpty) {
      return 0;
    }

    // Check if username is empty
    if (username.isEmpty) {
      return 1;
    }

    // Check if password is empty
    if (password.isEmpty) {
      return 2;
    }

    // Check for invalid characters in username
    if (!validCharacters.hasMatch(username)) {
      return 3;
    }

    // Check for invalid characters in password
    if (!validCharacters.hasMatch(password)) {
      return 4;
    }

    // Check if username exceeds max length
    if (username.length > maxLength) {
      return 5;
    }

    // Check if password exceeds max length
    if (password.length > maxLength) {
      return 6;
    }

    // If all checks pass
    return 7;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),

                // Logo
                const Icon(
                  Icons.cloud_outlined,
                  size: 100,
                  color: Colors.lightBlueAccent,
                ),
                const SizedBox(height: 20),

                // App Title
                const Text(
                  "Welcome to Notiva",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  "Login to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 50),

                // Username Field
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.blueAccent),
                      labelText: "Username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      String username = _usernameController.text;
                      String password = _passwordController.text;

                      switch (validateCredentials(username, password)) {
                        case 0:
                          print("Both fields are empty.");
                          break;
                        case 1:
                          print("Username is empty.");
                          break;
                        case 2:
                          print("Password is empty.");
                          break;
                        case 3:
                          print("Username contains invalid characters.");
                          break;
                        case 4:
                          print("Password contains invalid characters.");
                          break;
                        case 5:
                          print("Username is too long.");
                          break;
                        case 6:
                          print("Password is too long.");
                          break;
                        case 7:
                          _handleLogin(username, password);
                      }
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Forgot Password
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),

                // Footer
                const SizedBox(height: 50),
                const Text(
                  "Notiva © 2024",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
