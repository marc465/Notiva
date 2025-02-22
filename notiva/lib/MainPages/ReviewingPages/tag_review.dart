import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notiva/AdditionalPages/notes_to_update_tag_or_folder.dart';
import 'package:notiva/Entities/quick_note.dart';
import 'package:http/http.dart' as http;
// import 'package:notiva/Entities/tag.dart';
import 'package:notiva/MainPages/ReviewingPages/note_review.dart';
import 'package:notiva/Providers/universal_collection_provider.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';

class TagReview extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  final int tagId;

  const TagReview({super.key, required this.secureStorage, required this.tagId});

  @override
  _TagReviewState createState() => _TagReviewState();
}

class _TagReviewState extends State<TagReview> {
  final ScrollController _scrollController = ScrollController();
  String newTag = "";

  TextEditingController tagController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool inSearch = false;


  late NotesCollectionProvider provider;
  late ServiceAPI requestProvider;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();



  @override
  void initState() {
    super.initState();
    provider = Provider.of<NotesCollectionProvider>(context, listen: false);
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
    initialization();
  }

  void initialization() async {

    await requestProvider.handleRequest(
      () async {
        provider.initialization(widget.secureStorage, TagItem());
        return provider.getInitialData(widget.tagId);
      }, 
      context
    );

    tagController.text = provider.collection.tag;

    tagController.addListener((){
      final text = tagController.text.trim();
      if (text == provider.collection.tag) {
        provider.updateFieldStatus('name', false);
        return;
      }
      newTag = text;
      provider.updateFieldStatus('name', true);
    });
  }

  @override
  void dispose() {
    provider.reset();
    _scrollController.dispose();
    super.dispose();
  }

  void addNote() async {
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
                                    child: NotesToUpdateTagOrFolder(secureStorage: widget.secureStorage),
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

  Future<int> updateTag() async {
    if (provider.changes.values.any((element) => element == true)) {
      
      final body = jsonEncode({
          if (provider.changes['name'] == true) 'tag': newTag,
          if (provider.changes['list'] == true) 'idOfNotesInTag': provider
              .notesInCollection
              .map((note) => note.getId)
              .toList(),
        });
      
      print(body);

      final response = await http.post(
        Uri.parse("http://localhost:8080/tag/update"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'access_token': await widget.secureStorage.read(key: 'access_token') ?? "",
          'tag_id': provider.collectionId.toString()
        },
        body: body,
      );

      if (response.statusCode == 200) {
          ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
              duration: Duration(seconds: 3),
              content: Text("Folder updated successfully!")
            )
          );
          provider.update(name: newTag);

          newTag = "";
      }

      return response.statusCode;
    } else {
      return 0;
    }
  }

  Future<void> onWillPop() async {
  final shouldPop = await _showExitDialog();
  if (shouldPop && context.mounted) {
    Navigator.of(context).pop();
  }
}

  Future<bool> _showExitDialog() async {
  // Check if there are any changes
  if (!(provider.changes.values.any((element) => element == true))) {
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
      child: Provider.of<NotesCollectionProvider>(context).isLoading
        ? const Scaffold(
          body: Center(
            child: CircularProgressIndicator(strokeWidth: 1,),
          ),
        )
        : Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
              onPressed: onWillPop,
            ),
            actions: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                onPressed: () async {await requestProvider.handleRequest(updateTag, context);},
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: (provider.changes.values.any((element) => element == true)) 
                      ? CupertinoColors.activeBlue 
                      : CupertinoColors.systemGrey3,
                  ),
                ),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header and Icon
                      Row(
                        children: [
                          // Container(
                          //   alignment: Alignment.center,
                          //   height: 64,
                          //   width: 64,
                          //   padding: const EdgeInsets.all(1),
                          //   decoration: BoxDecoration(
                          //     color: Colors.blue.withOpacity(0.1),
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   child: CupertinoTextField.borderless(
                          //     controller: iconController,
                          //     textAlign: TextAlign.center,
                          //     maxLength: 1,
                          //     keyboardType: TextInputType.text,
                          //     style: TextStyle(
                          //       fontSize: 32
                          //     ),
                          //   )
                          // ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CupertinoTextField.borderless(
                              controller: tagController,
                              maxLength: 32,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Description
                      // const SizedBox(height: 16),
                      // Container(
                      //   width: double.infinity,
                      //   padding: const EdgeInsets.all(10),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(
                      //       color: Colors.grey.withOpacity(0.2),
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: CupertinoTextField.borderless(
                      //     controller: descriptionController,
                      //     maxLines: null,
                      //     style: TextStyle(
                      //       fontSize: 16,
                      //       color: Colors.grey[600],
                      //       height: 1.5,
                      //     ),
                      //   ),
                        
                      //   // Text(
                      //   //   folderDescription ?? "Description of folder",
                      //   //   style: TextStyle(
                      //   //     fontSize: 14,
                      //   //     color: Colors.grey[600],
                      //   //     height: 1.5,
                      //   //   ),
                      //   // ),
                      // ),
                      // Search bar
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Search in notes inside tag",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: provider.isCollectionSearchActive
                              ? IconButton(
                                  onPressed: (){
                                    searchController.clear();
                                    provider.clearSearch(inCollection: true);
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
                            fillColor: CupertinoColors.systemGrey6,
                            contentPadding: const EdgeInsets.all(8.0),
                          ),
                          onChanged: (textToSearch) async {
                            final currentText = textToSearch.trim();

                            if (currentText.isEmpty) {
                              provider.clearSearch(inCollection: true);
                            } else {
                              await requestProvider.handleRequest(() async {
                                return await provider.searchInsideCollection(currentText);
                              }, context);
                            }
                          },
                        )
                      ),
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
                    ],
                  ),
                ),
              ),

              // Notes List
              if (Provider.of<NotesCollectionProvider>(context).isCollectionSearchActive || Provider.of<NotesCollectionProvider>(context).notesInCollection.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24,0,24,10),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16, top: 12),
                            child: Text(
                              provider.isCollectionSearchActive
                              ? 'SEARCH RESULTS'
                              : '${provider.notesInCollection.length} NOTE${provider.notesInCollection.length > 1? 'S': ''}',
                              style: const TextStyle(
                                color: CupertinoColors.secondaryLabel,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                // List of notes
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        QuickNote note;

                        if (provider.isCollectionSearchActive) {
                          note = provider.collectionSearchResults[index];
                        } else {
                          note = provider.notesInCollection[index]; 
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Slidable(
                            key: ValueKey(note.getId),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              dismissible: DismissiblePane(
                                onDismissed: (){provider.removeNoteFromCollection(index);}
                              ),
                              children: [
                                SlidableAction(
                                  flex: 1,
                                  onPressed: (context) {provider.removeNoteFromCollection(index);},
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Remove',
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {                                  
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReview(secureStorage: widget.secureStorage, id: note.getId,)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Icon of note
                                        Container(
                                          height: 40,
                                          width: 40,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            note.getIcon,
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        
                                        // Notes name and transcript
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                note.getNotesName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                note.getTranscript,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Arrow forward iOS
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey[400],
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: provider.isCollectionSearchActive
                      ? provider.collectionSearchResults.length
                      : provider.notesInCollection.length,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
    );
  }

}
