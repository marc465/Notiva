import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/AdditionalPages/notes_to_tag_or_folder.dart';
import 'package:notiva/Entities/quick_note.dart';
import 'package:notiva/MainPages/ReviewingPages/folder_review.dart';
import 'package:notiva/MainPages/ReviewingPages/note_review.dart';
import 'package:notiva/Providers/universal_collection_provider.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';

class NewFolder extends StatefulWidget {
  final FlutterSecureStorage secureStorage;

  const NewFolder({super.key, required this.secureStorage});

  @override
  _NewFolderState createState() => _NewFolderState();
}


class _NewFolderState extends State<NewFolder> {
  String folderName = "";
  String folderDescription = "";
  ValueNotifier<String> selectedIcon = ValueNotifier("");
  TextEditingController iconController = TextEditingController();
  late NotesToProvider provider; 
  late ServiceAPI requestProvider;
  final TextEditingController folderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    provider = Provider.of<NotesToProvider>(context, listen: false);
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
    initialization();
  }

  @override
  void dispose() {
    provider.clear();
    super.dispose();
  }

  void initialization() async {
    provider.initialization(widget.secureStorage, FolderItem());
    await requestProvider.handleRequest(
      provider.getData, 
      context
    );

    iconController.addListener((){
      final text = iconController.text.trim();
      
      final emodjiRegex = RegExp(r'^[\u2600-\u26FF]$');
      final secondEmojiRegex = RegExp(r'^\p{Emoji}$', unicode: true);
      
      if (!emodjiRegex.hasMatch(text) && !secondEmojiRegex.hasMatch(text)) {
        iconController.clear();
        return;
      }
    });
  }

  Future<int> saveFolder() async {
    if (provider.notesInside.isNotEmpty) {
      final body = jsonEncode({
        if (folderName.isNotEmpty) 'folderName': folderName,
        if (folderDescription.isNotEmpty) 'folderDescription': folderDescription,
        if (selectedIcon.value.isNotEmpty) 'icon': selectedIcon,
        'idOfNotesInFolder': provider
            .notesInside
            .map((note) => note.getId)
            .toList(),
      });

      final response = await http.post(
        Uri.parse("http://localhost:8080/folders/new"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'access_token': await widget.secureStorage.read(key: 'access_token') ?? "",
        },
        body: body
      );

      if (response.statusCode == 200) {
          int folder_id = jsonDecode(response.body)["folder_id"];
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (context) => FolderReview(
                secureStorage: widget.secureStorage, 
                folderId: folder_id
              )
            )
          );
      }

      return response.statusCode;
    } else {
      return 0;
    }
  }

  void showEmojiPicker() {
    String emoji = ""; // Тимчасова змінна для введеного емоджі

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Enter Emoji Icon"),
        content: Column(
          children: [
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: iconController,
              autofocus: true,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: const TextStyle(fontSize: 32),
              onChanged: (value) {
                emoji = value;
              },
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text("OK"),
            isDefaultAction: true,
            onPressed: () {
              if (emoji.isNotEmpty) {
                selectedIcon.value = emoji;
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void addNote() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight * 0.95,
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
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Builder(
                              builder: (newContext) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: SizedBox(
                                    height: constraints.maxHeight - 4,
                                    child: NotesToNewTagOrFolder(secureStorage: widget.secureStorage),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> onWillPop() async {
    final shouldPop = await _showExitDialog();
    if (shouldPop && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _showExitDialog() async {
  // Check if there are any changes
  if (provider.notesInside.isEmpty 
      && folderName.isEmpty 
      && selectedIcon.value.isEmpty 
      && folderDescription.isEmpty) {
    return true;
  }
  
  try {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'Unsaved changes will be lost. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Leave',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  } catch (e) {
    return false;
  }
}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          await onWillPop();
        } 
      },
      child: SafeArea(
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          // AppBar
          navigationBar: CupertinoNavigationBar(
            backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
            middle: const Text(
              "Create Folder",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await onWillPop();
              },
              child: const Icon(
                CupertinoIcons.back,
                size: 30,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await requestProvider.handleRequest(
                  () async {return await saveFolder();}, 
                  context);
              },
              child: Text(
                "Submit",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  // here
                  color: provider.notesInside.isNotEmpty 
                    ? CupertinoColors.activeBlue 
                    : CupertinoColors.systemGrey3,
                ),
              ),
            ),
          ),
          // Body
          child: SafeArea(
            child: Scaffold(
              // Everything will be scrollable
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Folder Name Section
                          Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, top: 12),
                                  child: Text(
                                    'FOLDER NAME',
                                    style: TextStyle(
                                      color: CupertinoColors.secondaryLabel,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                CupertinoTextField.borderless(
                                  maxLength: 128,
                                  placeholder: "Enter folder name",
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  style: const TextStyle(fontSize: 17),
                                  // here
                                  onChanged: (text){folderName = text;},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Folder Description Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground, // Світлий фон для контрасту
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
      
                                const Text(
                                  'FOLDER DESCRIPTION',
                                  style: TextStyle(
                                    color: CupertinoColors.secondaryLabel,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CupertinoTextField(
                                  placeholder: "Enter folder description...",
                                  padding: const EdgeInsets.all(12),
                                  style: const TextStyle(fontSize: 17),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null, // Автоматичне збільшення
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemBackground,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: CupertinoColors.systemGrey4,
                                      width: 1,
                                    ),
                                  ),
                                  onChanged: (text) {folderDescription = text;},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Icon Selector
                          Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ValueListenableBuilder(
                              valueListenable: selectedIcon,
                              builder: (context, value, child) {
                                return CupertinoButton(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  // here
                                  onPressed: showEmojiPicker,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          // color: CupertinoColors.activeBlue,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: 
                                            value != ""
                                              ? Text(
                                                value,
                                                style: const TextStyle(fontSize: 20, color: CupertinoColors.white),
                                              )
                                              : const Text(
                                                "🚀",
                                                style: TextStyle(fontSize: 20, color: CupertinoColors.white),
                                              )
                                        )
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        value != ""? "Icon": "Choose Icon",
                                        style: const TextStyle(
                                          color: CupertinoColors.label,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        CupertinoIcons.forward,
                                        color: CupertinoColors.systemGrey3,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Add Note Button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              onPressed: addNote,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.plus_circle_fill,
                                    color: CupertinoColors.activeBlue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Add Note",
                                    style: TextStyle(
                                      color: CupertinoColors.activeBlue,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Notes in folder Section
                          if (Provider.of<NotesToProvider>(context).notesInside.isNotEmpty) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bar of notes list
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16, top: 12),
                                    child: Text(
                                      '${provider.notesInside.length} NOTE${provider.notesInside.length > 1? 'S': ''}',
                                      style: const TextStyle(
                                        color: CupertinoColors.secondaryLabel,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // List of notes chained to folder
                                  ...provider.notesInside.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final note = entry.value;
                                    
                                    return Column(
                                      children: [
                                        if (index != 0)
                                          Container(
                                            height: 1,
                                            color: CupertinoColors.separator,
                                          ),
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () async {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReview(secureStorage: widget.secureStorage, id: note.getId)));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: CupertinoColors.systemBackground.resolveFrom(context),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                // Icon of note
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: CupertinoColors.systemGrey6,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(note.getIcon, style: const TextStyle(fontSize: 20),),
                                                ),
                                                const SizedBox(width: 12),
                                                // Notes name and transcript
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Notes name
                                                      Text(
                                                        note.notesName,
                                                        style: const TextStyle(
                                                          color: CupertinoColors.label,
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      // Notes transcript
                                                      Text(
                                                        note.transcript,
                                                        style: const TextStyle(
                                                          color: CupertinoColors.systemGrey,
                                                          fontSize: 14,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Removing note from list
                                                CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    provider.removeNoteFromFolder(index);
                                                  },
                                                  child: const Icon(
                                                    CupertinoIcons.minus_circle_fill,
                                                    color: CupertinoColors.destructiveRed,
                                                    size: 22,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class NotesToProvider extends ChangeNotifier {
  CollectionItem? type;
  FlutterSecureStorage? secureStorage;
  List<QuickNote> availableNotes = [];
  List<QuickNote> notesInsideEntry = [];
  List<QuickNote> searchResult = [];
  bool isLoading = true;
  bool inSearch = false;
  Timer? _timer;

  List<QuickNote> get allAvailableNotes => availableNotes;
  List<QuickNote> get notesInside => notesInsideEntry;
  List<QuickNote> get searchResults => searchResult;

  NotesToProvider();

  void initialization(FlutterSecureStorage storage, CollectionItem givenType) {
    secureStorage = storage;
    type = givenType;
  }

  Future<int> getData() async {
    print("init of provider");
    
    final response = await http.get(
      Uri.parse("http://localhost:8080/notes/get"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': await secureStorage!.read(key: 'access_token') ?? '',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> _all_notes = jsonDecode(response.body);
      availableNotes = _all_notes.map((note) => QuickNote.fromJson(note)).toList();
      isLoading = false;
      notifyListeners();
    }

    return response.statusCode;
  }

  Future<int> loadAvailable() async {
    print("in load av in notesToProvider");

    final response = await http.get(
      Uri.parse("http://localhost:8080/${type!.endpoint}/view/avaiable"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': await secureStorage!.read(key: 'access_token')?? '',
        'except': notesInsideEntry.map((note) => note.getId).toList().toString(),
      }
    );

    if (response.statusCode == 200) {
      print("everything was good");
      final notesList = jsonDecode(response.body);
      print(notesList);
      availableNotes = notesList.map<QuickNote>((note) => QuickNote.fromJson(note)).toList();
      isLoading = false;
      notifyListeners();
    }
    return response.statusCode;
  }

  Future<int> search(String query) async {
    if (query.isEmpty || query.trim().isEmpty) return 0;
    final completer = Completer<int>();

    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 300), 
      () async {
        final statusCode = await _searchImplementation(query);
        completer.complete(statusCode);
      }
    );

    return completer.future;
  }

  Future<int> _searchImplementation(String query) async {
    print("search impl in provider");
    print(query);
    isLoading = true;
    inSearch = true;
    notifyListeners();
    
    final response = await http.get(
      Uri.parse("http://localhost:8080/search/in/notes"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': await secureStorage!.read(key: 'access_token') ?? '',
        'query': query
      }
    );

    if (response.statusCode == 200) {
      List<dynamic> _all_notes = jsonDecode(response.body);
      searchResult = _all_notes.map((note) => QuickNote.fromJson(note)).toList();
      isLoading = false;
      notifyListeners();
    }

    return response.statusCode;
  }

  void putNoteInFolder(int index) {
    print("putNoteInFolder");

    QuickNote note;

    if (inSearch) {
      note = searchResult.removeAt(index);
      availableNotes.remove(note);
    } else {
      note = availableNotes.removeAt(index);
    }

    if (!notesInside.contains(note)) {
      notesInside.add(note);
    }
    print(notesInside);
    notifyListeners();
  }

  void removeNoteFromFolder(int index) {
    print("removeNoteFromFolder");
    final note = notesInside.removeAt(index);

    if (!availableNotes.contains(note)) {
      availableNotes.add(note);
    }
    notifyListeners();
  }

  void setInSearchToFalse() {
    _timer?.cancel();

    if (!inSearch) return;

    inSearch = false;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void clear() {
    type = null;
    secureStorage = null;
    availableNotes = [];
    notesInsideEntry = [];
    searchResult = [];
    isLoading = true;
    inSearch = false;
    _timer = null;
  }
}

