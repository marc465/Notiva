import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/Entities/folder.dart';
import 'package:notiva/Entities/quick_note.dart';

class NewFolder extends StatefulWidget {
  final FlutterSecureStorage secureStorage;

  const NewFolder({super.key, required this.secureStorage});

  @override
  _NewFolderState createState() => _NewFolderState();
}


class _NewFolderState extends State<NewFolder> {
  String newFolderName = "New Folder";
  late TextEditingController _controllerEditing;
  String newIcon = "";
  bool isVisible = false;
  List<QuickNote> listToFolder = <QuickNote>[];
  List<QuickNote> listInFolder = <QuickNote>[];
  late DraggableScrollableController _dragController;

  @override
  void initState() {
    super.initState();
    _controllerEditing = TextEditingController(text: newFolderName);
    _dragController = DraggableScrollableController();
    _dragController.addListener((){
      if (_dragController.size == 0.0 && isVisible) {
        print("in listener 1");
        setState(() {
          isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _dragController.dispose();
    _controllerEditing.dispose();
  }

  List<int> getIdOfNotesToFolder() {
    List<int> res = <int>[];
    for (QuickNote note in listInFolder) {
      res.add(note.getId);
    }
    return res;
  }

  Future<void> getNotesFromServer() async {
    final response = await http.get(
      Uri.parse("http://localhost:8080/notes/get"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'access_token': await widget.secureStorage.read(key: 'access_token') ?? ""
      }
    );

    if (response.statusCode == 200) {
      List<dynamic> notesTemp = jsonDecode(response.body);
      setState(() {
        listToFolder = notesTemp.map((note) => QuickNote.fromJson(note)).toList();
      });
    } else {
      print("ther is an error:");
      print(response.statusCode);
      print(response.body);
    }
  }

  List<Widget> getNotesToFolder() {
    List<Widget> res = <Widget>[];
    for (QuickNote note in listToFolder) {
      res.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextButton(
          onPressed: (){
            setState(() {
              listInFolder.add(listToFolder.removeAt(listToFolder.indexOf(note)));
            });
          },
          child: Row(
            children: <Widget>[
              Text(note.getIcon, style: TextStyle(fontSize: 16.0),),
              SizedBox(width: 8.0,),
              Text(
                note.getNotesName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 8.0,),
              Text(note.getTranscript)
            ],
          ),
        )
      )
    );}

    return res;
  }

  List<Widget> getNotesInFolder() {
    List<Widget> res = <Widget>[];
    for (QuickNote note in listInFolder) {
      res.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextButton(
          onPressed: (){
            setState(() {
              listToFolder.add(listInFolder.removeAt(listInFolder.indexOf(note)));
            });
          },
          child: Row(
            children: <Widget>[
              Text(note.getIcon, style: TextStyle(fontSize: 16.0),),
              SizedBox(width: 8.0,),
              Text(
                note.getNotesName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 8.0,),
              Text(note.getTranscript)
            ],
          ),
        )
      )
    );}

    return res;
  }

  Future<void> saveFolderToServer() async {
    Folder newFolder = Folder(folderName: newFolderName, icon: newIcon, idOfNotesInFolder: getIdOfNotesToFolder());
    print(newFolder);
    final response = await http.post(
      Uri.parse("http://localhost:8080/folders/new"),
      headers: <String, String>{
        'Content-type': 'application/json',
        'access_token': await widget.secureStorage.read(key: 'access_token') ?? ''
      },
      body: jsonEncode(newFolder)
    );

    if (response.statusCode == 200) {
      print("Succesfuly created new Folder");
      Navigator.pop(context, true);
    } else {
      print("ther was a problem");
      print(response.statusCode);
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controllerEditing,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none
            ),
            filled: true,
            fillColor: Colors.grey.shade200,
            contentPadding: const EdgeInsets.all(8.0),
          ),
          onChanged: (text){setState(() {
            newFolderName = text;
          });},
        ),
        actions: [TextButton(
          onPressed: saveFolderToServer,
          child: const Text("Submit")
          )],
      ),
      body: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              hintText: "Put icon of your folder here",
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none
              ),
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.all(8.0),
            ),
            onChanged: (icon){setState(() {
              newIcon = icon;
            });},
          ),
          const Text("Add Notes to folder", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),),
          OutlinedButton(
            child: const Text("+", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),),
            onPressed: () => {
              if (listToFolder.isEmpty) {
                print("here"),
                setState(() {
                  getNotesFromServer();
                  isVisible = true;
                }),
                _dragController.animateTo(1.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
              } else {
                print("there"),
                print(isVisible),
                setState(() {
                  isVisible = true;
                  print(isVisible);
                }),
                _dragController.animateTo(1.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
              }
            }
          ),
          Column(
            children: getNotesInFolder(),
          ),
          Expanded(
            child: DraggableScrollableSheet(
              initialChildSize: isVisible? 1: 0.0,
              minChildSize: 0,
              maxChildSize: 1,
              snap: true,
              snapSizes: const [0.0, 1],
              controller: _dragController,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      // 
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      // Drag handle and title
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // Drag handle
                            // 
                            Container(
                              width: 36,
                              height: 4,
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // Title
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 16,
                              ),
                              child: Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Search bar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search in Notes',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: const Icon(Icons.mic),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tags list
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            listToFolder.isEmpty 
                              ? [Center(child: Text('No notes available'))]
                              : getNotesToFolder()
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      )
    );
  }
}
