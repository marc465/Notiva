import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notiva/AdditionalPages/notes_tags_page.dart';
import 'package:notiva/MainPages/CreatingPages/new_folder.dart';
import 'package:notiva/MainPages/ReviewingPages/note_review.dart';
import 'package:notiva/Providers/theme_provider.dart';
import 'package:notiva/Providers/universal_collection_provider.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:notiva/start.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();  // Add this line
  if (Platform.isIOS) {
    // Force the preferred refresh rate
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => TagsProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ServiceAPI(),
      ),
      ChangeNotifierProvider(
        create: (context) => NoteProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => NotesCollectionProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => NotesToProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ThemeProvider()
      )
    ],
    child: const NotivaApp(),
  ));
}

class NotivaApp extends StatelessWidget {
  const NotivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);  // Fix: Add type parameter

    return MaterialApp(
      title: "Notiva",
      builder: (context, child) {
        return MediaQuery(
          // Force the correct pixel ratio
          data: MediaQuery.of(context).copyWith(devicePixelRatio: 1.0),
          child: child!,
        );
      },
      home: const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Start()
        )
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          brightness: Brightness.light,  // Add this
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,  // Add this
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}