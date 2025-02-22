
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/AdditionalPages/search_results_favourites.dart';
import 'package:notiva/AdditionalPages/search_results_folders.dart';
import 'package:notiva/AdditionalPages/search_results_notes.dart';
import 'package:notiva/Entities/quick_folder.dart';
import 'package:notiva/Entities/quick_note.dart';
import 'package:notiva/Interfaces/providers_delete.dart';
import 'package:notiva/MainPages/favourites.dart';
import 'package:notiva/MainPages/folders.dart';
import 'package:notiva/MainPages/notes.dart';
import 'package:notiva/Providers/favourites_provider.dart';
import 'package:notiva/Providers/folders_provider.dart';
import 'package:notiva/Providers/notes_provider.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:notiva/SettingsPages/basic_settings.dart';
import 'package:provider/provider.dart';
import '../MainPages/CreatingPages/new_note.dart';
import '../AdditionalPages/notes_tags_page.dart';
import 'package:notiva/MainPages/CreatingPages/new_folder.dart';
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  const HomePage({super.key, required this.secureStorage});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  
  final List<String> _hintTextList = ['Search in notes...', 'Search in favourites...', 'Search in folders...'];
  late TabController _tabController;
  late ValueNotifier<String> _hintText;
  final List<Type> _toCreate = [NewNoteCreation, NewFolder];
  late Type _toCreateType;
  final List<String> _fabList = ['Create New Note', 'Create New Folder'];
  late String _fabText;
  final GlobalKey<FoldersState> _foldersKey = GlobalKey();
  late StatefulWidget searchResultPage;
  late SearchProviderNotes searchProviderNotes;
  late SearchProviderFavourites searchProviderFavourites;
  late SearchProviderFolders searchProviderFolders;
  bool inSearch = false;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  late ServiceAPI requestProvider;



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
    _hintText = ValueNotifier(_hintTextList.first);
    _toCreateType = _toCreate.first;
    _fabText = _fabList.first;
    _tabController = TabController(length: 3, vsync: this);

    requestProvider = Provider.of<ServiceAPI>(context, listen: false);

    _tabController.addListener(() {
      _hintText.value = _hintTextList[_tabController.index];
    });

    // _controller.addListener((){
    //   setState(() {
    //     inSearch = _controller.text.isEmpty;
    //   });
    // });

    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _toCreateType = _toCreate[0];
            _fabText = _fabList[0];
            break;
          case 1:
            _toCreateType = _toCreate[1];
            _fabText = _fabList[0];
            break;
          case 2:
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

  void searchFunc(String query) async {
    if (query.isEmpty) {
      return;
    }

    try {
      print("in search function");
      
      print("in delayed");
    
      switch (_tabController.index) {
        case 0:
          print(0);
          searchProviderNotes = SearchProviderNotes(accessToken: await widget.secureStorage.read(key: "access_token") ?? '');
          await requestProvider.handleRequest(
            () async {return await searchProviderNotes.search(query);},
            context
          );
          searchResultPage = NotesSearchResults(secureStorage: widget.secureStorage, searchProvNotes: searchProviderNotes);
          break;
          
        case 1:
          print(1);
          searchProviderFavourites = SearchProviderFavourites(accessToken: await widget.secureStorage.read(key: "access_token") ?? '');
          await requestProvider.handleRequest(
            () async {return await searchProviderFavourites.search(query);},
            context
          );
          searchResultPage = FavouritesSearchResults(secureStorage: widget.secureStorage, searchProvFav: searchProviderFavourites);
          break;
    
        case 2:
          print(2);
          searchProviderFolders = SearchProviderFolders(accessToken: await widget.secureStorage.read(key: "access_token") ?? '');
          await requestProvider.handleRequest(
            () async {return await searchProviderFolders.search(query);},
            context
          );
          searchResultPage = FoldersSearchResults(secureStorage: widget.secureStorage, searchProvFolders: searchProviderFolders);
          break;
          
        default:
          break;
      }
    
      setState(() {
        inSearch = true;
      });
    } on Exception catch (e) {
      debugPrint('Search error: $e');
    }
  }
  
  void showTagsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight * 0.95, // Обмежуємо висоту до 90% екрану
              child: DraggableScrollableSheet(
                initialChildSize: 1,
                minChildSize: 0.9,
                maxChildSize: 1,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: SingleChildScrollView( // Додаємо ScrollView
                      controller: scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Важливо!
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25.0),
                            child: SizedBox(
                              height: constraints.maxHeight * 0.9, // Обмежуємо висоту контенту
                              child: NotesTagPage(secureStorage: widget.secureStorage),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget undoDeleteBar(ProvidersDeleteMixin provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 30, right: 30),
      child: AnimatedContainer(
        width: double.infinity,
        // padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          border: Border.all(),
          borderRadius: BorderRadius.circular(15)
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        value: provider.progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[700]!),
                      )
                    ),
                    Text("${provider.remainingTime.floor()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),)
                  ],
                ),
              ),
              Expanded(
                child: Text(provider.deletionMessage, style: const TextStyle(color: Colors.white),)
              ),
              TextButton(
                child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[200]),),
                onPressed: (){provider.deleteCancel();}
              )
            ],
          ),
        ),
      ),
    );
  }

  void openDrawer(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Side Menu'),
        message: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoActionSheetAction(
              onPressed: () {
                print("Archive clicked");
                Navigator.pop(context);
              },
              child: generateButton("Archive", "Coming soon!")
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                print("Drafts clicked");
                Navigator.pop(context);
              },
              child: generateButton("Drafts", "Coming soon!")
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                print("Deleted clicked");
                Navigator.pop(context);
              },
              child: generateButton("Deleted", "Coming soon!")
            ),
          ],
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
          isDefaultAction: true,
        ),
      ),
    );
  }

  Widget generateButton(String text, String? subtext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(CupertinoIcons.folder, size: 24, color: CupertinoColors.activeBlue),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            if (subtext != null) Text(subtext, style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey)),
          ],
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (thisContext) => NotesProvider(thisContext, widget.secureStorage)),
        ChangeNotifierProvider(create: (thisContext) => FavouritesProvider(thisContext, widget.secureStorage)),
        ChangeNotifierProvider(create: (thisContext) => FoldersProvider(thisContext, widget.secureStorage))
      ],
      builder: (context, child){
        final notesProvider = context.watch<NotesProvider>();
        final favouritesProvider = context.watch<FavouritesProvider>();
        final foldersProvider = context.watch<FoldersProvider>();

        ProvidersDeleteMixin? activeProvider;
        if (notesProvider.isTimerStart) {
          activeProvider = notesProvider;
        } else if (favouritesProvider.isTimerStart) {
          activeProvider = favouritesProvider;
        } else if (foldersProvider.isTimerStart) {
          activeProvider = foldersProvider;
        }

        return Material(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              // App Bar
              appBar:  AppBar(
                title: const Text('MyNotes', style: TextStyle(fontWeight: FontWeight.w500,),),
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: (){
                    openDrawer(context);
                  }, 
                  icon: const Icon(Icons.more_horiz_rounded)
                ),
                actions: <Widget>[
                  IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(secureStorage: widget.secureStorage,)));
                    },
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
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: _hintText.value,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: inSearch
                                ? IconButton(
                                    onPressed: (){
                                      setState(() {
                                        _controller.clear();
                                        inSearch = false;
                                      });
                                    }, 
                                    icon: const Icon(CupertinoIcons.clear)
                                  )
                                : IconButton(
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
                            onChanged: (textToSearch){
                              if (textToSearch.isEmpty) {
                                setState(() {
                                  _controller.clear();
                                  inSearch = false;
                                });
                                return;
                              }
          
                              // Скасовуємо попередній таймер, якщо він існує
                              _debounceTimer?.cancel();
                              
                              // Встановлюємо новий таймер
                              _debounceTimer = Timer(const Duration(milliseconds: 200), () {
                                searchFunc(textToSearch);
                              });
                            },
                          )
                        ),
                        // Tags button
                        const SizedBox(width: 8,),
                        IconButton(
                          onPressed: (){
                            showTagsSheet();
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context)=> NotesTagPage(secureStorage: widget.secureStorage,)
                            //   )
                            // );
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
              body: inSearch
              ? searchResultPage
              : Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        // GridView - scrollable grid of notes
                        Notes(secureStorage: widget.secureStorage),
                        Favourites(secureStorage: widget.secureStorage),
                        Folders(key: _foldersKey, secureStorage: widget.secureStorage,)
                      ]
                    ),
                    if (activeProvider != null && activeProvider.isTimerStart) undoDeleteBar(activeProvider)
                  ],
                ),
              ),
              // Create new note button
              floatingActionButton: inSearch
              ? const SizedBox.shrink()
              : Padding(
                padding: const EdgeInsets.only(left: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FloatingActionButton(
                    onPressed: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => createWidgetByType(_toCreateType, secureStorage: widget.secureStorage) )
                      );
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
              bottomNavigationBar: inSearch
              ? const SizedBox.shrink()
              : TabBar(
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
          ),
        );
      },
    );
    }
}

class SearchProviderNotes extends ChangeNotifier {
  String accessToken;
  List<QuickNote> result = [];
  bool isLoading = false;

  List<QuickNote> get results => result;

  SearchProviderNotes({required this.accessToken});

  Future<int> search(String query) async {
    print("in search provider notes");
    if (query.isEmpty) return 0;

    print("query is not empty");
    print(query);

    isLoading = true;
    
    final response = await http.get(
      Uri.parse("http://localhost:8080/search/in/notes"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': accessToken,
        'query': query
      }
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      List<dynamic> _notes = jsonDecode(response.body);
      result = _notes.map((note) => QuickNote.fromJson(note)).toList();
      isLoading = false;
      notifyListeners();
    }
    return response.statusCode;
  }

  Future<int> deleteNote(int id) async {
    final response = await http.delete(Uri.parse("http://localhost:8080/notes/delete"), headers: {
        'Content-Type': 'application/json',
        'access_token': accessToken,
        'note_id': id.toString()
    });

    if (response.statusCode == 200) {
      result.removeWhere((note) => note.getId == id);
      notifyListeners();
    }

    return response.statusCode;
  }

}


class SearchProviderFavourites extends ChangeNotifier {
  String accessToken;
  List<QuickNote> result = [];
  bool isLoading = false;

  List<QuickNote> get results => result;

  SearchProviderFavourites({required this.accessToken});

  Future<int> search(String query) async {
    print("in search provider notes");
    if (query.isEmpty) return 0;

    print("query is not empty");
    print(query);

    isLoading = true;
    
    final response = await http.get(
      Uri.parse("http://localhost:8080/search/in/notes"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': accessToken,
        'query': query,
        'favourite': true.toString()
      }
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      List<dynamic> _notes = jsonDecode(response.body);
      result = _notes.map((note) => QuickNote.fromJson(note)).toList();
      isLoading = false;
      notifyListeners();
    }
    return response.statusCode;
  }

  Future<int> deleteNote(int id) async {
    final response = await http.delete(Uri.parse("http://localhost:8080/notes/delete"), headers: {
        'Content-Type': 'application/json',
        'access_token': accessToken,
        'note_id': id.toString()
    });

    if (response.statusCode == 200) {
      result.removeWhere((note) => note.getId == id);
      notifyListeners();
    }
    
    return response.statusCode;
  }
}


class SearchProviderFolders extends ChangeNotifier {
  String accessToken;
  List<QuickFolder> result = [];
  bool isLoading = false;

  List<QuickFolder> get results => result;

  SearchProviderFolders({required this.accessToken});

  Future<int> search(String query) async {
    print("in search provider folders");
    if (query.isEmpty) return 0;

    print("query is not empty");
    print(query);

    isLoading = true;
    
    final response = await http.get(
      Uri.parse("http://localhost:8080/search/in/folders"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': accessToken,
        'query': query
      }
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      List<dynamic> _folders = jsonDecode(response.body);
      result = _folders.map((folder) => QuickFolder.fromJson(folder)).toList();
      isLoading = false;
      notifyListeners();
    }
    return response.statusCode;
  }


  Future<int> deleteFolder(int id) async {
    final response = await http.delete(Uri.parse("http://localhost:8080/folders/delete"), headers: {
        'Content-Type': 'application/json',
        'access_token': accessToken,
        'folder_id': id.toString()
    });
    if (response.statusCode == 200) {
      result.removeWhere((folder) => folder.getId == id);
      notifyListeners();
    }
    return response.statusCode;
  }

}

