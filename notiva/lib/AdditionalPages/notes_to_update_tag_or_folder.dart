import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/quick_note.dart';
// import 'package:notiva/MainPages/ReviewingPages/folder_review.dart';
import 'package:notiva/Providers/universal_collection_provider.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';

class NotesToUpdateTagOrFolder extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  const NotesToUpdateTagOrFolder({super.key, required this.secureStorage});

  @override
  State<StatefulWidget> createState() => _NotesToUpdateTagOrFolderState();
}

class _NotesToUpdateTagOrFolderState extends State<NotesToUpdateTagOrFolder> {
  TextEditingController searchController = TextEditingController();
  late NotesCollectionProvider provider;
  late ServiceAPI requestProvider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<NotesCollectionProvider>(context, listen: false);
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
    initial();
  }

  void initial() async {
    await requestProvider.handleRequest(provider.loadAvailableNotes, context);
  }

  Future<void> refreshData() async {
    try {
      provider.isLoading = true;
      await requestProvider.handleRequest(
        provider.loadAvailableNotes, 
        context
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tags: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        provider.isLoading = false;
      }
    }
  }

  @override
  Widget build(context) {
    return SafeArea(
      child: Consumer<NotesCollectionProvider>(
        builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              "Notes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search in notes...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: provider.isSearchActive
                    ? IconButton(
                      onPressed: (){
                        searchController.clear();
                        provider.clearSearch();
                      }, 
                      icon: const Icon(CupertinoIcons.clear)
                    )
                    : IconButton(
                      onPressed: (){},
                      icon: const Icon(Icons.mic)
                    )
                  ),
                  onChanged: (query) async {
                    final currentText = searchController.text;
                    if (currentText.isEmpty) {
                      provider.clearSearch();
                    } else {
                      await requestProvider.handleRequest(
                        () async {return await provider.searchNotes(currentText);}, 
                        context
                      );
                    }
                  },
                ),
              )
            ),
          ),
          body: provider.isLoading
            ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
            : Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: RefreshIndicator(
                onRefresh: refreshData,
                child: ListView.builder(
                  itemCount: provider.isSearchActive
                    ? provider.searchResults.length
                    : provider.availableNotes.length,
                      
                  itemBuilder: (context, index) {
                    QuickNote note;
                      
                    if (provider.isSearchActive) {
                      note = provider.searchResults[index];
                    } else {
                      note = provider.availableNotes[index];
                    }
                      
                    return Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // List of notes chained to folder
                          if (index != 0)
                          Container(
                            height: 1,
                            color: CupertinoColors.separator,
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              provider.addNoteToCollection(index);
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
                                  // Forward arrow
                                  const Icon(
                                        CupertinoIcons.plus_circle_fill,
                                        color: CupertinoColors.activeGreen,
                                        size: 18,
                                      ),
                                  // const Icon(
                                  //   CupertinoIcons.forward,
                                  //   color: CupertinoColors.systemGrey3,
                                  //   size: 18,
                                  // ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          );
        }
      ),
    );
  }

}
