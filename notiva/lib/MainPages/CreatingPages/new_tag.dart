import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/AdditionalPages/notes_to_tag_or_folder.dart';
import 'package:notiva/MainPages/CreatingPages/new_folder.dart';
import 'package:notiva/MainPages/ReviewingPages/note_review.dart';
import 'package:notiva/MainPages/ReviewingPages/tag_review.dart';
import 'package:notiva/Providers/universal_collection_provider.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';

class NewTag extends StatefulWidget {
  final FlutterSecureStorage secureStorage;

  const NewTag({super.key, required this.secureStorage});

  @override
  _NewTagState createState() => _NewTagState();
}


class _NewTagState extends State<NewTag> {
  String tagName = "";
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
    print("inside");
    provider.initialization(widget.secureStorage, TagItem());
    await requestProvider.handleRequest(
      provider.getData, 
      context
    );
  }

  Future<int> saveTag() async {
    if (provider.notesInside.isNotEmpty) {
      final response = await http.post(
        Uri.parse("http://localhost:8080/tags/new"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'access_token': await widget.secureStorage.read(key: 'access_token') ?? "",
        },
        body: jsonEncode({
          'tag': tagName,
          'idOfNotesInTag': provider
              .notesInside
              .map((note) => note.getId)
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        int tag_id = jsonDecode(response.body)["tag_id"];
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => TagReview(
              secureStorage: widget.secureStorage, 
              tagId: tag_id
            )
          )
        );
      }

      return response.statusCode;
    }
    return 0;
  }

  void addNote() {
    provider.isLoading = true;
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
  if (provider.notesInside.isEmpty && tagName.isEmpty) {
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
              "Create Tag",
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
                  () async {return await saveTag();}, 
                  context
                );
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
                          // Tag Name Section
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
                                    'TAG NAME',
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
                                  onChanged: (text){tagName = text;},
                                ),
                              ],
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
                          // Notes in tag Section
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
                                  // List of notes chained to tag
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
