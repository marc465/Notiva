import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/quick_folder.dart';
import 'package:notiva/MainPages/ReviewingPages/folder_review.dart';

class Folders extends StatefulWidget {

  final FlutterSecureStorage secureStorage;

  const Folders({super.key, required this.secureStorage});

  @override
  State<StatefulWidget> createState() => FoldersState();
}

class FoldersState extends State<Folders> {

  List<QuickFolder> folders = [];
    
  // void _loadMoreFolders() {}

  void getFolders() async {
    
    final response = await http.get(Uri.parse("http://localhost:8080/folders/get"), headers: {
        'Content-Type': 'application/json',
        'access_token': await widget.secureStorage.read(key: 'access_token') ?? ""
    });

    // print(response.statusCode);
    // print(response.body);

    List<dynamic> decodedFolders = jsonDecode(response.body);
    setState(() {
      folders = decodedFolders.map((note) => QuickFolder.fromJson(note)).toList();
    });
  }

  List<Widget> getFoldersWidgets() {

    List<Widget> foldersWidgets = [];

    for (QuickFolder folder in folders) {
      foldersWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 10,
            width: double.infinity,
            child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20.0))
              ),
              child: ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FolderReview(secureStorage: widget.secureStorage, folderId: folder.getId)));
                },
                child: Row(
                  children: <Widget>[
                    Text(folder.icon),
                    Expanded(child: Text(folder.folderName)),
                  ],
                ),
              ),
            ),
          ),
        )
      );
    }
    return foldersWidgets;
  }

  @override
  void initState() {
    super.initState();
    getFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 4,
        children: getFoldersWidgets(),
      ),
    );
  }
}