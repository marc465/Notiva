import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/quick_note.dart';
import 'package:notiva/MainPages/ReviewingPages/note_review.dart';
import 'package:notiva/Providers/notes_provider.dart';
// import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:notiva/SettingsPages/share_and_export_note.dart';
import 'package:provider/provider.dart';


class Notes extends StatefulWidget {
  final FlutterSecureStorage secureStorage;

  const Notes({super.key, required this.secureStorage});

  @override
  State<Notes> createState() => _NotesState();
}


class _NotesState extends State<Notes> with TickerProviderStateMixin {
  late NotesProvider provider;
  late ServiceAPI requestProvider;
  final Map<int, AnimationController> _animationControllers = {};

  @override
  void initState() {
    super.initState();
    provider = context.read<NotesProvider>();
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
    if (!provider.wasInitialized) {
      initialization();
    }
  }

  void initialization() async {
    await requestProvider.handleRequest(provider.getNotes, context);
    
    if (mounted) {
      setState(() {}); // Оновлюємо UI після завантаження нотаток
    }
  }

  Widget notesGenerator(BuildContext context, QuickNote note, int index) {
    _animationControllers[index] ??= AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final String formattedDate =
        DateFormat('MMM d, yyyy').format(note.getTimeOfLastChanges);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SizeTransition(
        sizeFactor: Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _animationControllers[index]!,
            curve: Curves.easeInOut,
          ),
        ),
        child: Slidable(
          key: ValueKey(note.getId),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            dismissible: DismissiblePane(onDismissed: () {
              provider.deleteStart(null, index);
            }),
            children: [
              _buildSlidableAction(
                context,
                color: CupertinoColors.systemRed,
                icon: CupertinoIcons.delete,
                label: 'Delete',
                onPressed: () => provider.deleteStart(_animationControllers, index),
              ),
              _buildSlidableAction(
                context,
                color: CupertinoColors.systemGrey,
                icon: CupertinoIcons.archivebox,
                label: 'Archive',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Archive function coming soon"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _buildSlidableAction(
                context,
                color: CupertinoColors.systemBlue,
                icon: CupertinoIcons.share,
                label: 'Share',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShareAndExport(data: note.getId.toString()),
                    ),
                  );
                },
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              border: Border.all(width: 1, color: CupertinoColors.systemGrey5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NoteReview(secureStorage: widget.secureStorage, id: note.getId,),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 2.0),
                  leading: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Container(
                      // Provide extra room and shift the icon slightly higher
                      margin: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        note.getIcon,
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      note.getNotesName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.getTranscript.isNotEmpty)
                        Text(
                          note.getTranscript,
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel,
                            fontWeight: FontWeight.w500
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: CupertinoColors.inactiveGray,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlidableAction(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SlidableAction(
      onPressed: (_) => onPressed(),
      backgroundColor: color,
      foregroundColor: CupertinoColors.white,
      icon: icon,
      label: label,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      borderRadius: BorderRadius.circular(10),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: CupertinoColors.systemGrey6,
      body: RefreshIndicator(
        onRefresh: () async {await requestProvider.handleRequest(provider.getNotes, context);},
        child: ListView.builder(
          itemCount: provider.notes.length,
          itemBuilder: (context, index){
            return notesGenerator(context, provider.notes[index], index);
          }
        ),
      )
      
    );
  }

}
