
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/MainPages/favourites.dart';
import 'package:notiva/MainPages/folders.dart';
import 'package:notiva/MainPages/notes.dart';
import '../MainPages/CreatingPages/new_note.dart';
import '../AdditionalPages/notes_tags_page.dart';
import 'package:notiva/MainPages/CreatingPages/new_folder.dart';


class HomePage extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  const HomePage({super.key, required this.secureStorage});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  
  final List<String> _hintTextList = ['Search in notes...', 'Search in favourites...', 'Search in folders...'];
  late TabController _tabController;
  late String _hintText;
  final List<Type> _toCreate = [NewNoteCreation, NewFolder];
  late Type _toCreateType;
  final List<String> _fabList = ['Create New Note', 'Create New Folder'];
  late String _fabText;
  final GlobalKey<FoldersState> _foldersKey = GlobalKey();


  Widget createWidgetByType(Type type, {required FlutterSecureStorage secureStorage}) {
    if (type == NewNoteCreation) {
      return NewNoteCreation(secureStorage: secureStorage);
    } else if (type == NewFolder) {
      return NewFolder(secureStorage: secureStorage);
    } else {
      throw Exception("Unsupported type: $type");
    }
  }

  @override
  void initState() {
    super.initState();
    _hintText = _hintTextList.first;
    _toCreateType = _toCreate.first;
    _fabText = _fabList.first;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _hintText = _hintTextList[0];
            _toCreateType = _toCreate[0];
            _fabText = _fabList[0];
            break;
          case 1:
            _hintText = _hintTextList[1];
            _toCreateType = _toCreate[1];
            _fabText = _fabList[0];
            break;
          case 2:
            _hintText = _hintTextList[2];
            _toCreateType = _toCreate[1];
            _fabText = _fabList[1];
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // App Bar
        appBar:  AppBar(
          title: const Text('MyNotes'),
          actions: <Widget>[
            IconButton(
              onPressed: (){},
              icon:  const Icon(
                Icons.settings_outlined
              )
            )
          ],
        // Search bar and tags button
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  // Search bar
                  Expanded(child: TextField(
                    decoration: InputDecoration(
                      hintText: _hintText,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () {},
                      ), 
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide.none
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.all(8.0),
                    ),
                    onSubmitted: (textToSearch){},
                  )
                  ),
                  // Tags button
                  const SizedBox(width: 8,),
                  IconButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context)=> NotesTagPage(secureStorage: widget.secureStorage,)
                        )
                      );
                    },
                    icon: const Icon(Icons.tag),
                  )
                ]
              ),
            ),
          ),
        ),
        // body
        // TabBarView - general contorller for the tabs
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            // GridView - scrollable grid of notes
            Notes(secureStorage: widget.secureStorage),
            Favourites(secureStorage: widget.secureStorage),
            Folders(key: _foldersKey, secureStorage: widget.secureStorage,)
          ]
        ),
      // Create new note button
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: FloatingActionButton(
              onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => createWidgetByType(_toCreateType, secureStorage: widget.secureStorage) )
                  ).then((value) {
                    print("object");
                    _foldersKey.currentState?.getFolders();
                  });
              },
              backgroundColor: Colors.blue.shade700,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))
              ),
              child: Text(_fabText, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      // Bottom Navigation Bar
        bottomNavigationBar: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.note_add_sharp),
              text: "Notes",
            ),
            Tab(
              icon: Icon(Icons.favorite_border),
              text: "Favourites",
            ),
            Tab(
              icon: Icon(Icons.folder),
              text: "Folders",
            )
          ]
        )
      ),
    );
  }
}
