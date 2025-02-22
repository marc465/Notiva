import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/CustomExceptions/ServerException.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:notiva/StartingPages/home.dart';
import 'package:notiva/StartingPages/login.dart';
import 'package:notiva/StartingPages/signup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  late TabController _tabController;
  bool isLoading = false;
  String? access_token;
  String? refresh_token;
  String? theme_mode;
  bool? is_logged_out;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    initialization();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> hasInternetAccess() async {
    print("in internet connection checker");
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void initialization() async {

    if (!(await hasInternetAccess())) {
      // do something on internet connection off
    }

    await sharedPrefInitialization();

    Provider.of<ServiceAPI>(context, listen: false).init(_secureStorage, prefs);

    print("pass 1");

    // Read data from device
    await readDataFromDevice();

    // Signup endpoint
    if (refresh_token == null && access_token == null) {
      _tabController.index = 1;
      return;
    }
    print("pass 3");

    
    // One of Login endpoint
    if (refresh_token == null && access_token != null) {
      return;
    }

    print("pass 4");


    // If both or only refresh tokens were valid -> 
    //  send request to server if it decided so, 
    //  then write two new pairs to storage,
    //  and `await requestForTokens` will return true,
    //  so we can push user to home page without login or signup
    try {
      print("in 5");
      if (is_logged_out == null || is_logged_out == false) {
        print("in 5.1");
          setState(() {
            isLoading = true;
          });
        if (await requestForTokens()) {
          print("in 5.2");
          isLoading = false;
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(secureStorage: _secureStorage)));
        } 
      }
    } on ServerException catch (e) {
      print(e);
      // do something on server error
    }

    print("pass 5");


    // otherwise just return and default tabcontroller.index = 0 will send user to Ligin page
    return;
  }

  Future<void> sharedPrefInitialization() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> readDataFromDevice() async {
    access_token = await _secureStorage.read(key: 'access_token');
    refresh_token = await _secureStorage.read(key: 'refresh_token');
    theme_mode = prefs.getString('theme_mode');
    is_logged_out = prefs.getBool('is_logged_out');
  }

  Future<bool> requestForTokens() async {
    final response = await http.get(
      Uri.parse("http://localhost:8080/refresh/tokens"),
      headers: {
        'Cookie': refresh_token ?? '',
      }
    );

    if (response.statusCode == 500) {
      final String text = jsonDecode(response.body);
      print(text);
      throw ServerException(text);
    }

    if (response.statusCode != 200) {
      print(response.statusCode);
      return false;
    }

    Map<String, String> headers = response.headers;

    print(headers);

    refresh_token = headers['set-cookie'];
    access_token = headers['access_token'];

    if (refresh_token == null || access_token == null) {
      return false;
    }

    await _secureStorage.write(key: 'refresh_token', value: refresh_token);
    await _secureStorage.write(key: 'access_token', value: access_token);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
    ? const Center(child: CircularProgressIndicator(),)
    : Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Login'),
            Tab(text: 'Sign Up'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          LoginScreen(secureStorage: _secureStorage,),
          SignUpScreen(secureStorage: _secureStorage,),
        ],
      ),
    );
  }
}