import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Providers/theme_provider.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:notiva/start.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final FlutterSecureStorage secureStorage;

  const SettingsPage({super.key, required this.secureStorage});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  late SharedPreferences prefs;
  late ServiceAPI requestProvider;


  // Example user data
  String _username = "JohnDoe";
  String _email = "john@example.com";
  
  // Example settings
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  // system data
  String deleteConfirmationText = "";
  
  final List<String> _availableLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
  ];

  @override
  void initState() {
    super.initState();
    initPreferences();
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(content: const Text(
            "Setting Page is in development. Functional and design will be changed."
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(label: "Ok", onPressed: () {ScaffoldMessenger.of(context).hideCurrentSnackBar();}),
        )
      );
    });
  }

  Future<void> initPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _handleUpdateProfilePicture() {
    // Implement profile picture update logic
  }

  void _handleUpdateUsername(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Username'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter new username',
            filled: true,
            fillColor: Colors.grey[200],
          ),
          // initialValue: _username,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement username update logic
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleUpdateEmail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Email'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter new email',
            filled: true,
            fillColor: Colors.grey[200],
          ),
          // initialValue: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement email update logic
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Current password',
                filled: true,
                fillColor: Colors.grey[200],
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'New password',
                filled: true,
                fillColor: Colors.grey[200],
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Confirm new password',
                filled: true,
                fillColor: Colors.grey[200],
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement password change logic
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableLanguages
              .map(
                (language) => RadioListTile<String>(
                  title: Text(language),
                  value: language,
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              prefs.setBool('is_logged_out', true);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Start()), (Route<dynamic> route) => false);
              },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Implement sign out logic
    }
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type "DELETE" to confirm',
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {deleteConfirmationText = value;},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Implement account deletion logic
              if (deleteConfirmationText != "DELETE") {
                showWrongWriteConfirmationMessage();
                Navigator.pop(context);
                return;
              }

              if (
                await requestProvider.handleRequest(sendDeleteRequest, context) != 200
              ) {
                showFailDelete();
              }
              await deleteAllUserDataFromDevice();
              showDeletedMessage();
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const Start()), 
                (Route<dynamic> route) => false
              );
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<int> sendDeleteRequest() async {
    final access_token = await widget.secureStorage.read(key: 'access_token') ?? '';
    final refresh_token = await widget.secureStorage.read(key: 'refresh_token') ?? '';

    final response = await http.post(
      Uri.parse("http://localhost:8080/delete/account"),
      headers: {
        'access_token': access_token,
      }
    );

    if(response.statusCode == 200) {
      final confirmation = await http.post(
        Uri.parse("http://localhost:8080/delete/account/confirmation"),
        headers: {
          'access_token': access_token,
          'refresh_token': refresh_token,
          'confirm': jsonDecode(response.body)['code']
        }
      );
      print(confirmation.statusCode);
      return confirmation.statusCode;
    }
    print(response.statusCode);
    return response.statusCode;
  }

  Future<void> deleteAllUserDataFromDevice() async {
    widget.secureStorage.delete(key: 'access_token');
    widget.secureStorage.delete(key: 'refresh_token');
    prefs.remove('theme_mode');
    prefs.remove('is_logged_out');
  }

  void showFailDelete() {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Failed To Delete Account"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Failed to delete your account. It's possible due to several reasons including: \n -Spent time for delete\n -Network issues\n -Server problems\nReccommend try again faster and if it doen't work - contact our customer service")
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text("Okay"),
            onPressed: (){
              Navigator.pop(context);
            }, 
          )
        ],
      )
    );
  }  

  void showDeletedMessage() {
    ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: const Text("We are sorry! Your account was deleted... :(\nIf you ever would want to stick with us again - we will be happy!"),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(label: "Ok", onPressed: (){}),
        )
      );
  }

  void showWrongWriteConfirmationMessage() {
    ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Text("Your confirmation text \"$deleteConfirmationText\" isn't \"DELETE\"\nPlease Try again"),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(label: "Ok", onPressed: (){
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }),
        )
      );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 35.0),
        child: ListView(
          children: [
            _buildAccountSection(),
            const Divider(),
            _buildPreferencesSection(themeProvider),
            const Divider(),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: const Text('Profile Picture'),
          onTap: _handleUpdateProfilePicture,
        ),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Username'),
          subtitle: Text(_username),
          onTap: () => _handleUpdateUsername(context),
        ),
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: const Text('Email'),
          subtitle: Text(_email),
          onTap: () => _handleUpdateEmail(context),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Change Password'),
          onTap: () => _handleChangePassword(context),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(ThemeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Enable push notifications'),
          value: _notificationsEnabled,
          onChanged: (bool value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Enable dark theme'),
          value: _darkModeEnabled,
          onChanged: (bool value) {
            setState(() {
              _darkModeEnabled = value;
            });
            provider.toggleTheme();
          },
        ),
        ListTile(
          title: const Text('Language'),
          subtitle: Text(_selectedLanguage),
          onTap: () => _showLanguageSelection(context),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign Out'),
          onTap: _handleSignOut,
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () => _showDeleteAccountConfirmation(context),
        ),
      ],
    );
  }

}
