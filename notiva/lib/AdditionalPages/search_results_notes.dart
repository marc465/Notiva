import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/quick_note.dart';
import 'package:notiva/MainPages/ReviewingPages/note_review.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:notiva/StartingPages/home.dart';
import 'package:provider/provider.dart';


class NotesSearchResults extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  final SearchProviderNotes searchProvNotes;

  const NotesSearchResults({super.key, required this.secureStorage, required this.searchProvNotes});

  @override
  State<NotesSearchResults> createState() => _NotesSearchResultsState();
}


class _NotesSearchResultsState extends State<NotesSearchResults> {
  late ServiceAPI requestProvider;

  @override
  void initState() {
    super.initState();
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
  }


  Widget searchedNotesGenerator(BuildContext context, QuickNote note) {
    print(note);
    return Slidable(
      key: ValueKey(note.getId),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () async {
            await requestProvider.handleRequest(() async {
              return await widget.searchProvNotes.deleteNote(note.getId);
            }, context);
          }
        ),
        children: [
          SlidableAction(
            onPressed: (context) {print("share");},
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Share',
          ),
          SlidableAction(
            onPressed: (context) {print("archive");},
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            icon: Icons.archive_outlined,
            label: 'Archive',
          ),
          SlidableAction(
            onPressed: (context) async {
              await requestProvider.handleRequest(() async {
                return await widget.searchProvNotes.deleteNote(note.getId);
              }, context);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ]
      ),
      child: Padding(
          padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReview(secureStorage: widget.secureStorage, id: note.getId,)));
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200, width: 1),
                    right: BorderSide(color: Colors.grey.shade200, width: 1),
                    left: BorderSide(color: Colors.grey.shade200, width: 1),
                    bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                    )
                ),
                child: Row(
                    children: <Widget>[
                      Text(note.getIcon, style: const TextStyle(fontSize: 48),),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Text(
                                note.getNotesName,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                              )
                            ),
                            Expanded(
                              child: Text(note.getTranscript)
                            )
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_outlined)
                    ],
                  ),
              ),
            ),
          )
    );
  }

  @override
  Widget build(BuildContext context) {

    if (widget.searchProvNotes.isLoading) {
      print("is loading");
      return const Center(
        child: CircularProgressIndicator(),
      );
    }


    if (widget.searchProvNotes.result.isEmpty) {
      print("nothing found");
      return const Center(
        child: Text("Nothing was find :(")
      );
    }

    print("everything is correct");
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.searchProvNotes.result.length,
        itemBuilder: (context, index){
          return searchedNotesGenerator(context, widget.searchProvNotes.result[index]);
        }
      )
    );
  }
}
