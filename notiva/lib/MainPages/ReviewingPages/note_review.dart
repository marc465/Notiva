
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:audio_session/audio_session.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:intl/intl.dart';
import 'package:notiva/AdditionalPages/chat_ai_page_beta.dart';
import 'package:notiva/Entities/note.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:notiva/SettingsPages/share_and_export_note.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:notiva/Service/websocket_service.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class NoteReview extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  final int id;
  const NoteReview({super.key, required this.secureStorage, required this.id});

  @override
  State<StatefulWidget> createState() => _NoteReviewState();
}

class _NoteReviewState extends State<NoteReview> with TickerProviderStateMixin, WidgetsBindingObserver{
  // 1. First, declare providers that will be initialized in initState
  late NoteProvider funcProvider;
  late ServiceAPI requestProvider;

  // 2. Declare controllers that depend on vsync
  late TabController _tabController;
  late AudioPlayer player;

  // 3. Declare Quill controllers that depend on note data
  late QuillController _controllerSummary;
  late QuillController _controllerTranscript;

  // 4. Declare scroll controllers
  final ScrollController _editSummaryScrollController = ScrollController();
  final ScrollController _editTranscriptScrollController = ScrollController();

  // 5. Declare focus nodes
  FocusNode summaryFocusNode = FocusNode();
  FocusNode transcriptFocusNode = FocusNode();

  // 6. Declare text controllers
  final TextEditingController iconController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // 7. Declare other state variables
  List<int> matches = [];
  int currentMatchIndex = 0;
  bool isColapsed = false;
  bool isSearchOpened = false;
  bool isToolBarVisible = true;
  bool isCloseInTextFieldVisible = false;
  bool isVisible = true;
  double lastOffsetSummary = 0;
  double lastOffsetTranscript = 0;
  String newIcon = "";
  String newName = "";
  // String newSummary = "";
  // String newTranscript = "";
  Timer? timer;

  // 8. Declare global keys
  final GlobalKey quillSummaryEditorKey = GlobalKey();
  final GlobalKey quillTranscriptEditorKey = GlobalKey();

  // 9. Declare value notifiers
  final ValueNotifier<Color> colorOfRedo = ValueNotifier(CupertinoColors.systemGrey);
  final ValueNotifier<Color> colorOfUndo = ValueNotifier(CupertinoColors.systemGrey);

  @override
  void initState() {
    super.initState();
    _initializeProviders();
    _initializeAsync();
  }

  void _initializeProviders() {
    funcProvider = Provider.of<NoteProvider>(context, listen: false);
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
  }

  Future<void> _initializeAsync() async {
    // Initialize basic controllers that don't depend on data
    _tabController = TabController(length: 2, vsync: this);

    // Start data initialization
    await _initializeData();
    player = funcProvider.player!;

    // Initialize controllers that depend on data
    _initializeControllers();

    // Set up listeners
    createListeners();
  }

  Future<void> _initializeData() async {
    funcProvider.initialization(widget.secureStorage, widget.id);
    
    await requestProvider.handleRequest(
      funcProvider.initNote, 
      context
    );

    await funcProvider.initController();

    await requestProvider.handleRequest(
      () async => await funcProvider.initPlayer(context), 
      context
    );
  }

  void _initializeControllers() {
    // Initialize text controllers with data
    iconController.text = funcProvider.note!.getIcon;
    nameController.text = funcProvider.note!.getNotesName;

    final summaryDelta = Delta.fromJson(jsonDecode(funcProvider.note!.summary)['ops']);
    final transcriptDelta = Delta.fromJson(jsonDecode(funcProvider.note!.transcript)['ops']);

    _controllerSummary = QuillController(
      document: Document.fromDelta(summaryDelta),
      selection: const TextSelection.collapsed(offset: 0),
    );

    _controllerTranscript = QuillController(
      document: Document.fromDelta(transcriptDelta),
      selection: const TextSelection.collapsed(offset: 0),
    );

    funcProvider.setNoteInit(true);
  }

  bool handleScrollNotification(UserScrollNotification notification) {
    if (notification.metrics.pixels <= 0) return false;
    if (notification.direction == ScrollDirection.reverse && funcProvider.isVisible) {
      funcProvider.setVisible(false);
    } else if (notification.direction == ScrollDirection.forward && !funcProvider.isVisible) {
      funcProvider.setVisible(true);
    }
    return true;
  }

  @override
  void dispose() {
    // Dispose all controllers and listeners
    player.stop();
    player.dispose();
    funcProvider.clear();
    _tabController.dispose();
    _controllerSummary.dispose();
    _controllerTranscript.dispose();
    _editSummaryScrollController.dispose();
    _editTranscriptScrollController.dispose();
    iconController.dispose();
    nameController.dispose();
    searchController.dispose();
    summaryFocusNode.dispose();
    transcriptFocusNode.dispose();
    timer?.cancel();
    super.dispose();
  }

  void createListeners() {
    iconController.addListener(() {
      final text = iconController.text.trim();
      
      final emodjiRegex = RegExp(r'^[\u2600-\u26FF]$');
      final secondEmojiRegex = RegExp(r'^\p{Emoji}$', unicode: true);
      
      if (!emodjiRegex.hasMatch(text) && !secondEmojiRegex.hasMatch(text)) {
        iconController.clear();
        return;
      }

      if (text == funcProvider.note!.icon) {
        funcProvider.updateFieldStatus('icon', false);
      } else {
        funcProvider.updateFieldStatus('icon', true);
      }
    });

    nameController.addListener((){
      final text = nameController.text.trim();
      if (text == funcProvider.note!.notesName) {
        funcProvider.updateFieldStatus('name', false);
        return;
      }
      funcProvider.updateFieldStatus('name', true);
    });

    _controllerSummary.addListener((){
      final text = _controllerSummary.document.toDelta();
      print(text);
      print(Delta.fromJson(jsonDecode(funcProvider.note!.summary)['ops']));
      if (text == (Delta.fromJson(jsonDecode(funcProvider.note!.summary)['ops']))) {
        funcProvider.updateFieldStatus('summary', false);
        return;
      }
      funcProvider.updateFieldStatus('summary', true);
    });

    _controllerTranscript.addListener((){
      final text = _controllerTranscript.document.toDelta();
      print(text);
      print(Delta.fromJson(jsonDecode(funcProvider.note!.transcript)['ops']));
      if (text == (Delta.fromJson(jsonDecode(funcProvider.note!.transcript)['ops']))) {
        funcProvider.updateFieldStatus('transcript', false);
        return;
      }
      funcProvider.updateFieldStatus('transcript', true);
    });

    _controllerSummary.addListener(_updateUndoRedoColors);
    _controllerTranscript.addListener(_updateUndoRedoColors);

  }

  void _updateUndoRedoColors() {
    bool hasUndo = _controllerSummary.hasUndo || _controllerTranscript.hasUndo;
    bool hasRedo = _controllerSummary.hasRedo || _controllerTranscript.hasRedo;

    colorOfUndo.value = hasUndo ? CupertinoColors.activeBlue : CupertinoColors.systemGrey;
    colorOfRedo.value = hasRedo ? CupertinoColors.activeBlue : CupertinoColors.systemGrey;
  }

  void handleUndo() {
    final editor = (_tabController.index == 0)
                      ? _controllerSummary
                      : _controllerTranscript;
    editor.undo();
    _updateUndoRedoColors();
  }

  void handleRedo() {
    final editor = (_tabController.index == 0)
                      ? _controllerSummary
                      : _controllerTranscript;
    editor.redo();
    _updateUndoRedoColors();
  }

  void searchInNote(String query) {
    if (query.isEmpty) return;

    print("In search");

    QuillController controller = _tabController.index == 0
        ? _controllerSummary
        : _controllerTranscript;

    ScrollController scroll = _tabController.index == 0
      ? _editSummaryScrollController
      : _editTranscriptScrollController;

    FocusNode node = _tabController.index == 0
      ? summaryFocusNode
      : transcriptFocusNode;

    // Extract words from the query
    final queryParts = RegExp(r'\b\w+\b')
        .allMatches(query.toLowerCase())
        .map((match) => match.group(0)!)
        .toList();

    if (queryParts.isEmpty) return;

    print("Query: $query");
    print("Query Parts: $queryParts");

    // Fuzzy search options
    FuzzyOptions options = FuzzyOptions(
      threshold: 0.1,
      tokenize: true,
      matchAllTokens: true,
      shouldNormalize: true,
    );

    // Get words with positions
    List<WordWithPosition> words = getWordWithPositions(
        controller.document.getPlainText(0, controller.document.length));

    List<String> wordList = words.map((wp) => wp.word).toList();

    // Step 1: Find first word matches
    Fuzzy fuzzy = Fuzzy(wordList, options: options);
    final firstMatches = fuzzy.search(queryParts[0]);

    print("First word matches for '${queryParts[0]}': ${firstMatches.length}");

    List<List<int>> result = [];

    // Step 2: Check if the whole phrase can be built
    for (final match in firstMatches) {
      if (match.matches.isEmpty) continue;

      int startIndex = match.matches[0].arrayIndex;
      int currentIndex = startIndex;
      bool matchFound = true;

      for (var i = 1; i < queryParts.length; i++) {
        if (currentIndex + 1 >= wordList.length) {
          matchFound = false;
          break;
        }

        // Look at the next 2 words
        int searchRangeEnd = (currentIndex + 3 > wordList.length)
            ? wordList.length
            : currentIndex + 3;

        Fuzzy subFuzzy = Fuzzy(wordList.sublist(currentIndex + 1, searchRangeEnd), options: options);
        final subMatch = subFuzzy.search(queryParts[i]);

        if (subMatch.isEmpty) {
          matchFound = false;
          break;
        }

        // Convert relative index to global index
        int relativeIndex = subMatch.firstOrNull!.matches[0].arrayIndex;
        currentIndex = currentIndex + 1 + relativeIndex;

        // If the next word is too far, drop this path
        if (currentIndex - startIndex > (i * 2)) {
          matchFound = false;
          break;
        }
      }

      if (matchFound) {
        result.add([startIndex, currentIndex]);
      }
    }

    if (result.isNotEmpty) {    
      print(words[result[0][0]].startIndex);
      print(words[result[0][1]].endIndex);
      selectText(words[result[0][0]].startIndex, words[result[0][1]].endIndex, controller, node);
      scrollToMatch(words[result[0][0]].startIndex, controller, scroll);
    }
  }

  void scrollToMatch(int index, QuillController controller, ScrollController scrollController) {
    // Safe check - if index is less that 0 or higher than length of text - return
    final plainText = controller.document.toPlainText();
    if (index < 0 || index >= plainText.length) return;

    // Create text selection at the target index
    final selection = TextSelection.collapsed(offset: index);
    
    // Get the render object that contains our text
    final renderEditable = scrollController.position.context.notificationContext
        ?.findRenderObject() as RenderBox?;
        
    if (renderEditable != null) {
      // Calculate the target scroll position
      try {
        final metrics = scrollController.position;
        // final currentOffset = metrics.pixels;
        
        // Get viewport height
        final viewportHeight = metrics.viewportDimension;
        
        // Estimate the target position based on character position
        // This is an approximation - you might need to adjust the multiplier
        final estimatedPosition = (index / plainText.length) * metrics.maxScrollExtent;
        
        // Add some offset to show text below the top
        final targetPosition = estimatedPosition - (viewportHeight / 4);
        
        // Ensure we don't scroll past the bounds
        final boundedPosition = targetPosition.clamp(
          metrics.minScrollExtent,
          metrics.maxScrollExtent,
        );

        // Animate to position
        scrollController.animateTo(
          boundedPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        
        // Update selection to highlight the text
        controller.updateSelection(selection, ChangeSource.local);
        
      } catch (e) {
        print('Error scrolling to position: $e');
      }
    }
  }

  void selectText(int start, int end, QuillController controller, FocusNode focusNode) {
  // Ensure the editor has focus
  // focusNode.requestFocus();

  // Ensure indices are within bounds
  int length = controller.document.length;
  start = start.clamp(0, length);
  end = end.clamp(0, length);

  // Wait until the editor is built before updating selection
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.updateSelection(
      TextSelection(baseOffset: start, extentOffset: end),
      ChangeSource.local,
    );
  });
}

  List<WordWithPosition> getWordWithPositions(String text) {
    List<WordWithPosition> positions = [];
    RegExp wordRegex = RegExp(r'\S+');
    
    for (Match match in wordRegex.allMatches(text)) {
      positions.add(WordWithPosition(
        word: match.group(0)!,
        startIndex: match.start,
        endIndex: match.end,
        ));
      }
      
    return positions;
    }

  String extractTimeOfCreation() {
    String res = "${funcProvider.note!.getTimeOfCreation.month}.${funcProvider.note!.getTimeOfCreation.day}.${funcProvider.note!.getTimeOfCreation.year}";
    return res;
  }

  void handleFavourite() {
    timer?.cancel();
    funcProvider.setFavourite();

    timer = Timer(const Duration(milliseconds: 700), () async {
      print("send request for fav");
      print(funcProvider.tempFavValue);

      requestProvider.handleRequest(
        () async {
          if (funcProvider.tempFavValue != null && funcProvider.tempFavValue == funcProvider.note!.isFavourite) return 0;
      
          final response = await http.post(
            Uri.parse("http://localhost:8080/note/is/favourite"),
            headers: {
              'access_token': await widget.secureStorage.read(key: 'access_token') ?? '',
              'note_id': funcProvider.note!.getId.toString(),
              'value': funcProvider.note!.getIsFavourite.toString()
            }
          );
          
          if (response.statusCode == 200) {
            print("favourite logic works fine!");
            funcProvider.tempFavValue = funcProvider.note!.isFavourite;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to set favourite state.\nPlease Try againg later."),
                duration: Duration(seconds: 5),
              )
            );
            funcProvider.setFavourite();
          }
          return response.statusCode;
      }, 
        context);
    });
  }

  Stream<DurationState> get _durationStateStream => Rx.combineLatest3<Duration, Duration, Duration?,DurationState>(
    player.positionStream, 
    player.bufferedPositionStream, 
    player.durationStream,
    (position, buffered, total) => DurationState(
      position,
      buffered,
      total ?? Duration.zero,
    ),
  );

  String getTotalDuration() {
    final duration = player.duration ?? Duration.zero;
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours > 0 ? '$hours:' : ''}'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
  }

  void showShareAndExportSheet(String data) {
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
                              height: constraints.maxHeight * 1, // Обмежуємо висоту контенту
                              child: ShareAndExport(data: data,),
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

  Future<void> onWillPop() async {
    print('in will pop');
    final shouldPop = await _showExitDialog();
    print(shouldPop);
    if (shouldPop && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _showExitDialog() async {
    print('in show dialog');
    // Check if there are any changes
    if (!(funcProvider.changes.values.any((change) => change == true))) {
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

  Future<void> updateNote() async {
    print("in update note");
    if (!funcProvider.changes.values.any((change) => change == true)) {
      print("nothing to change");
      return;
    }

    String? updatedName = funcProvider.changes['name'] == true ? newName : null;
    String? updatedIcon = funcProvider.changes['icon'] == true ? newIcon : null;
    String? updatedSummary = funcProvider.changes['summary'] == true
        ? jsonEncode({"ops": _controllerSummary.document.toDelta().toJson()})
        : null;
    String? updatedTranscript = funcProvider.changes['transcript'] == true
        ? jsonEncode({"ops": _controllerTranscript.document.toDelta().toJson()})
        : null;

    final body = jsonEncode({
      if (updatedName != null) 'note_name': updatedName,
      if (updatedIcon != null) 'icon': updatedIcon,
      if (updatedSummary != null) 'summary': updatedSummary,
      if (updatedTranscript != null) 'transcript': updatedTranscript,
    });

    requestProvider.handleRequest(() async {
      final response = await http.post(
        Uri.parse("http://localhost:8080/note/update"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'access_token': await widget.secureStorage.read(key: 'access_token') ?? "",
          'note_id': funcProvider.id!.toString()
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        final decodedJson = jsonDecode(utf8DecodedBody);

        funcProvider.afterNoteUpdate(
          time: decodedJson['time_of_edit'],
          name: updatedName,
          icon: updatedIcon,
          summary: updatedSummary,
          transcript: updatedTranscript,
        );
        
        newIcon = "";
        newName = "";
      }

      return response.statusCode;
    }, context);
  }


  Future<void> test() async {

    final body = jsonEncode({
      'test_data': "So, Ukraine's economy in 2025, uh, it's kind of a mix, you know? On one hand, we've got GDP growing like, uh, I think around 4.2 percent or something, which is good, but inflation still high. The government is trying to, uh, stabilize the, umm, monitory system, but the prices for, like, basic stuff—bread, fuel—they keep going up.Also, uh, the war recovery efforts, they are, um, impacting everything. Foreign investors, uh, they are kinda interested, but at the same time, they are like, 'is it safe to invest now?' Uh, there's also this problem with, umm, logistics, you know? Export routes, uh, some of them still blocked or not working fully, especially in, uh, sea trade.The IT sector, though, is doing, um, pretty well. It's, like, one of the strongest parts of the economy. A lot of, umm, startups, outsourcing companies—uh, they keep growing. But, uh, there's still a big issue with energy supply, uh, blackouts happening sometimes, which, umm, makes it hard for businesses to plan ahead.And, uh, another thing, the government, they, um, trying to, uh, push reforms, but some of them, umm, are getting stuck in bureaucracy. Uh, the tax system, yeah, it's still complicated, um, businesses struggle to, you know, work with it smoothly.So, yeah, um, 2025—it's a mix of, umm, challenges and opportunities, you know?",
      'comment': "The transcript mentions 'monitory system,' which should be ‘monetary system.' Also, when the speaker says ‘they are kinda interested, but at the same time, they are like, \"is it safe to invest now?\"'—this part could be reworded to sound clearer.The part about ‘export routes blocked' refers specifically to Black Sea trade disruptions, so maybe clarify that.Also, when the speaker says ‘the government, they, um, trying to, uh, push reforms,' it should be ‘the government is trying to push reforms,' and some details about which reforms are delayed could be useful.The section about blackouts affecting IT businesses is important, so it should remain but could be structured better.Make sure the final version is formatted properly with headers, bullet points, and bolded key terms where necessary."
    });

    requestProvider.handleRequest(() async {
      final response = await http.post(
        Uri.parse("http://localhost:8080/note/new/test"),
        headers: {
          'Content-Type': 'application/json',
          'access_token': await widget.secureStorage.read(key: 'access_token') ?? ''
        },
        body: body
      );
      
      print(response.statusCode);

      return response.statusCode;
    }, context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context);

    if (!provider.isNoteInitialized) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(strokeWidth: 1,),
        ),
      );
    }

    if (provider.error != null) {
      return 
      // KeyboardListener(
      //   focusNode: FocusNode(),
      //   onKeyEvent: (event) {
      //     if (event.logicalKey == LogicalKeyboardKey.find) {}
      //   },
      //   child: 
        Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.error}'),
                ElevatedButton(
                  // here
                  onPressed: (){},
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      // );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        print("in pop invoked");
        if (!didPop) {
          await onWillPop();
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          // Part of Appbar with more and back buttons
          appBar: CupertinoNavigationBar(
            backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await onWillPop();
              },
              child: const Icon(
                CupertinoIcons.back,
                color: CupertinoColors.activeBlue,
                size: 30,
              ),
            ),
            middle: LayoutBuilder(
              builder: (context, constraints) {
                double totalWidth = constraints.maxWidth;
                double buttonWidth = 36; // Approximate width of each button
                int totalButtons = 5;
                double spacing = (totalWidth - (buttonWidth * totalButtons)) / (totalButtons);
      
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: spacing), // Space before Undo button
      
                    // Undo button (Fixed position)
                    ValueListenableBuilder<Color>(
                      valueListenable: colorOfUndo,
                      builder: (context, color, child) {
                        return Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: handleUndo,
                            child: Icon(
                              CupertinoIcons.arrow_counterclockwise,
                              color: color,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
      
                    SizedBox(width: spacing * 1.5), // Space between Undo and Redo
      
                    // Redo button (Fixed position)
                    ValueListenableBuilder<Color>(
                      valueListenable: colorOfRedo,
                      builder: (context, color, child) {
                        return Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: handleRedo,
                            child: Icon(
                              CupertinoIcons.arrow_clockwise,
                              color: color,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Share and Submit buttons
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Space between Redo and Share
                          SizedBox(width: spacing),
      
                          // Share button (Position changes if Submit appears)
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showShareAndExportSheet(provider.note!.getNotesName);
                            },
                            child: const Icon(
                              CupertinoIcons.square_arrow_up,
                              color: CupertinoColors.activeBlue,
                              size: 24,
                            ),
                          ),
      
                        if (provider.changes.values.any((change) => change == true)) SizedBox(width: spacing * 1.5), // Extra space if Submit appears
      
                        // Submit button (Only visible if changes exist)
                        if (provider.changes.values.any((change) => change == true))
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              await updateNote();
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ),
                        ],
                      )
                    ),
                  ],
                );
              },
            ),
          ),
          body: SafeArea(
            child: !Provider.of<NoteProvider>(context).isNoteInitialized
              ? const Center(child: CircularProgressIndicator(strokeWidth: 1,))
              : Column(
                children: <Widget>[
                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      // here
                      controller: searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: 
                          provider.inSearch
                            ? IconButton(
                                onPressed: (){
                                  print("close pressed");
                                  searchController.clear();
                                  provider.closeSearch();
                                },
                                icon: const Icon(Icons.close_rounded)
                              )
                            : IconButton(
                                onPressed: (){},
                                icon: const Icon(Icons.mic)
                              ),
                        hintText: "Search in the note"
                      ),
                      onChanged: (textToSearch){
                        final currentText = textToSearch.trim();
      
                        if (currentText.isEmpty) {
                          provider.closeSearch();
                        } else {
                          provider.search(currentText, _tabController.index);
                        }
                      },
                    ),
                  ),
      
                  // Some other data from note in appBar with favourite
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      height: provider.isVisible ? null : 0,
                      child: ClipRect(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 2, 20, 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Icon input field
                                  SizedBox(
                                    width: 48,
                                    child: CupertinoTextField.borderless(
                                      controller: iconController,
                                      maxLength: 1,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        height: 1.3,
                                      ),
                                      onChanged: (text) {
                                        newIcon = text;
                                      },
                                    ),
                                  ),
      
                                  const SizedBox(width: 12),
      
                                  // Name input field
                                  Expanded(
                                    child: CupertinoTextField.borderless(
                                      controller: nameController,
                                      maxLength: 64,
                                      maxLines: 1,
                                      placeholder: 'Note name',
                                      placeholderStyle: TextStyle(
                                        color: CupertinoColors.systemGrey.withOpacity(0.8),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: CupertinoColors.label,
                                      ),
                                    ),
                                  ),
                                  
                                  // Favorite button
                                  IconButton(
                                    onPressed: (){
                                      handleFavourite();
                                    },
                                    icon: provider.note!.isFavourite
                                      ? const Icon(Icons.favorite_rounded, size: 25)
                                      : const Icon(Icons.favorite_border_rounded, size: 25)
                                  ),

                                  // Test button
                                  IconButton(
                                    onPressed: (){
                                      test();
                                    },
                                    icon: const Icon(Icons.temple_buddhist_outlined, size: 25)
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              child: Row(
                                children: [
                                // Top row with creation time and duration
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Creation date
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey6.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.calendar,
                                            size: 14,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            DateFormat('MMM d, y').format(provider.note!.getTimeOfCreation),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: CupertinoColors.systemGrey.darkColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    // Duration of Audio
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey6.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.time,
                                            size: 14,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                          const SizedBox(width: 6),
                                          provider.isPlayerInitialized
                                            ? Text(
                                              getTotalDuration(),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: CupertinoColors.systemGrey.darkColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                            : const CupertinoActivityIndicator(
                                              radius: 8,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                Expanded(child: Container()),
                                
                                // Bottom with last edit time
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey6.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat('HH:mm    MM.dd.yyyy').format(provider.note!.getTimeOfLastChanges),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: CupertinoColors.systemGrey.darkColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                    
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4), // Додав бокові відступи
                              child: Container(
                                height: 44, // Фіксована висота для кращого вигляду
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100, // Світліший відтінок
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all( // Додав тонку рамку
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: TabBar(
                                  dividerHeight: 0,
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [ // Додав легку тінь для виділеного табу
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  labelColor: Colors.black,
                                  unselectedLabelColor: Colors.black,
                                  labelStyle: const TextStyle( // Стиль для активного табу
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: -0.3,
                                  ),
                                  unselectedLabelStyle: const TextStyle( // Стиль для неактивного табу
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    letterSpacing: -0.3,
                                  ),
                                  padding: const EdgeInsets.all(3), // Внутрішній відступ для табів
                                  tabs: const [
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 8),
                                          Text("Summary"),
                                        ],
                                      ),
                                    ),
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 8),
                                          Text("Transcript"),
                                        ],
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
                  ),
                  
                  // TabBarView - Quill Editor
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(bottom: provider.isVisible ? 140.0 : 30),
                      constraints: const BoxConstraints.expand(),
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          Column(
                            children: [
      
                              // Customizing toolbar look
                              GestureDetector(
                                onVerticalDragEnd: (context){
                                  if (provider.isToolBarVisible) {
                                    provider.setToolBarVisibility(false);
                                  }
                                },
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  switchInCurve: Curves.easeInOut,
                                  switchOutCurve: Curves.easeInOut,
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return SizeTransition(
                                      sizeFactor: animation,
                                      axisAlignment: -1.0, // Приховує toolbar вгору
                                      child: child,
                                    );
                                  },
            
                                  child: provider.isToolBarVisible
                                    ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                                        ),
                                      ),
                                      child: QuillSimpleToolbar(
                                        configurations: QuillSimpleToolbarConfigurations(
                                          controller: _controllerSummary,
                                          showSearchButton: false,
                                          showUndo: false,
                                          showRedo: false,
                                          multiRowsDisplay: false, // Keep toolbar in one row
                                        ),
                                      ),
                                    )
                                    : const SizedBox.shrink()
                                )
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                        constraints: BoxConstraints(
                                          minHeight: MediaQuery.of(context).size.height + 100, // або більше, якщо потрібно
                                        ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: NotificationListener<UserScrollNotification>(
                                          onNotification: handleScrollNotification,
                                          child: QuillEditor(
                                            key: quillSummaryEditorKey,
                                            scrollController: _editSummaryScrollController,
                                            configurations: QuillEditorConfigurations(
                                              controller: _controllerSummary,
                                              scrollPhysics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()), // Smooth scrolling
                                              padding: const EdgeInsets.only(bottom: 10),
                                            ),
                                            focusNode: summaryFocusNode,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (!provider.isToolBarVisible) Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(50.0)
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(50.0),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                            child: IconButton(
                                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                              onPressed: () {
                                                provider.setToolBarVisibility(true);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              // Customizing toolbar look
                              GestureDetector(
                                onVerticalDragEnd: (context){
                                  if (provider.isToolBarVisible) {
                                    provider.setToolBarVisibility(false);
                                  }
                                },
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  switchInCurve: Curves.easeInOut,
                                  switchOutCurve: Curves.easeInOut,
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return SizeTransition(
                                      sizeFactor: animation,
                                      axisAlignment: -1.0,
                                      child: child,
                                    );
                                  },
            
                                  child: provider.isToolBarVisible?
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                                        ),
                                      ),
                                      child: QuillSimpleToolbar(
                                        configurations: QuillSimpleToolbarConfigurations(
                                          controller: _controllerTranscript,
                                          showSearchButton: false,
                                          showUndo: false,
                                          showRedo: false,
                                          multiRowsDisplay: false, // Keep toolbar in one row
                                        ),
                                      ),
                                    )
                                    : const SizedBox.shrink()
                                )
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                        constraints: BoxConstraints(
                                          minHeight: MediaQuery.of(context).size.height + 100, // або більше, якщо потрібно
                                        ),
                                      child: NotificationListener(
                                        onNotification: handleScrollNotification,
                                        child: QuillEditor(
                                          key: quillTranscriptEditorKey,
                                          scrollController: _editTranscriptScrollController,
                                          configurations: QuillEditorConfigurations(
                                            controller: _controllerTranscript,
                                            scrollPhysics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()), // Smooth scrolling
                                            padding: const EdgeInsets.only(bottom: 35),
                                          ),
                                          focusNode: transcriptFocusNode,
                                        ),
                                      ),
                                    ),
                                    if (!provider.isToolBarVisible) Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(50.0)
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(50.0),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                            child: IconButton(
                                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                              onPressed: () {
                                                provider.setToolBarVisibility(true);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                            ],
                          )
                        ]
                      ),
                    ),
                  )
                ],
              ),
          ),
          floatingActionButton: GestureDetector(
            onPanUpdate: (details) {
              if (isColapsed && details.delta.dx < 0) {
                setState(() {
                  isColapsed = false;
                });
              }
              if (!isColapsed && details.delta.dx > 0) {
                setState(() {
                  isColapsed = true;
                });
              }
            },
            child: Stack(
              children: [
                // FABs
                AnimatedPositioned(
                  right: isColapsed? -100: 0,
                  bottom: 140,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50.0)
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Row(
                          children: [
            
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0, bottom: 4.0),
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue,
                                    shape: CircleBorder(
                                      side: BorderSide(color: Colors.blue, width: 1)
                                    ),
                                    heroTag: "timer",
                                    elevation: 0,
                                    mini: true,
                                    onPressed: (){},
                                    child: Icon(Icons.translate_rounded),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0, bottom: 4.0),
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue,
                                    shape: CircleBorder(
                                      side: BorderSide(color: Colors.blue, width: 1)
                                    ),
                                    heroTag: "tag",
                                    elevation: 0,
                                    mini: true,
                                    onPressed: (){},
                                    child: Icon(Icons.tag),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0, bottom: 8.0),
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue,
                                    shape: CircleBorder(
                                      side: BorderSide(color: Colors.blue, width: 1)
                                    ),
                                    heroTag: "chat",
                                    elevation: 0,
                                    mini: true,
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => AIMessengerPage(secureStorage: widget.secureStorage, noteId: provider.note!.id,)));
                                      // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(noteId: widget.noteId)));
                                    },
                                    child: Icon(CupertinoIcons.chat_bubble_2_fill),
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      ),
                    ),
                  ),
                ),
                // Arrow
                AnimatedPositioned(
                right: isColapsed ? 0 : -100,
                bottom: 140,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: IconButton(
                  onPressed: (){
                    setState(() {
                      isColapsed = !isColapsed;
                    });
                  },
                  icon: Icon(Icons.chevron_left))
              )
              ],
            ),
          ),
          bottomSheet: AnimatedContainer(
            height: provider.isVisible ? 140: 60,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -1),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              child: SafeArea(
                child: provider.isVisible
                ? buildExpandedPlayer()
                : buildCollapsedPlayer(),
              ),
            ),
          )
          )
        ),
    );
    }

  Widget buildExpandedPlayer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Progress bar
          StreamBuilder<DurationState>(
            stream: _durationStateStream,
            builder: (context, snapshot) {
              final durationState = snapshot.data;
              final progress = durationState?.progress ?? Duration.zero;
              final buffered = durationState?.buffered ?? Duration.zero;
              final total = durationState?.total ?? Duration.zero;
        
              return ProgressBar(
                progress: progress,
                buffered: buffered,
                total: total,
                progressBarColor: CupertinoColors.activeBlue,
                baseBarColor: Colors.grey.withOpacity(0.2),
                bufferedBarColor: Colors.grey.withOpacity(0.3),
                thumbColor: CupertinoColors.activeBlue,
                barHeight: 4,
                thumbRadius: 6,
                onSeek: (duration) {
                  player.seek(duration);
                },
              );
            },
          ),
          
          // Controlls button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Rewind button
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: () {
                    Duration newPosition = player.position - const Duration(seconds: 10);
                    player.seek(newPosition < Duration.zero ? Duration.zero: newPosition);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Icons.replay_10_rounded, size: 40, color: CupertinoColors.activeBlue),
                  ),
                ),
              ),
              
              // Play/Pause button
              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  
                  // Loading state
                  // if (processingState == ProcessingState.loading ||
                  //     processingState == ProcessingState.buffering) {
                  //   return Container(
                  //     margin: const EdgeInsets.all(8.0),
                  //     width: 30.0,
                  //     height: 30.0,
                  //     decoration: BoxDecoration(
                  //       color: Colors.blueAccent[400],
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child: CircularProgressIndicator(
                  //       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  //       strokeWidth: 3,
                  //     ),
                  //   );
                  // }
                  
                  // Play button
                  if (playing != true) {
                    return Material(
                      color: CupertinoColors.activeBlue,
                      shape: CircleBorder(),
                      child: InkWell(
                        onTap: player.play,
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.play_arrow_solid,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  
                  // Pause button or Replay button
                  if (processingState != ProcessingState.completed) {
                    return Material(
                      color: CupertinoColors.activeBlue,
                      shape: CircleBorder(),
                      child: InkWell(
                        onTap: player.pause,
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.pause_fill,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Material(
                      color: CupertinoColors.activeBlue,
                      shape: CircleBorder(),
                      child: InkWell(
                        onTap: () => player.seek(Duration.zero),
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.replay,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              
              // Fast forward button
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: () {
                    Duration newPosition = player.position + const Duration(seconds: 10);
                    player.seek(newPosition > player.duration! ? player.duration: newPosition);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Icons.forward_10_rounded, size: 40, color: CupertinoColors.activeBlue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCollapsedPlayer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Mini play button
          Padding(
            padding: const EdgeInsets.only(right: 12,),
            child: StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final playing = playerState?.playing;
                if (playing == true) {
                  return IconButton(
                    icon: Icon(CupertinoIcons.pause_fill, color: CupertinoColors.activeBlue),
                    onPressed: player.pause,
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  );
                } else {
                  return IconButton(
                    icon: Icon(CupertinoIcons.play_arrow_solid, color: CupertinoColors.activeBlue),
                    onPressed: player.play,
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  );
                }
              },
            ),
          ),
          // Progress bar
          Expanded(
            child: StreamBuilder<DurationState>(
              stream: _durationStateStream,
              builder: (context, snapshot) {
                final durationState = snapshot.data;
                final progress = durationState?.progress ?? Duration.zero;
                final buffered = durationState?.buffered ?? Duration.zero;
                final total = durationState?.total ?? Duration.zero;

                return ProgressBar(
                  barCapShape: BarCapShape.round,
                  thumbRadius: 0,
                  barHeight: 3,
                  progressBarColor: CupertinoColors.activeBlue,
                  baseBarColor: Colors.grey.withOpacity(0.2),
                  bufferedBarColor: Colors.grey.withOpacity(0.3),
                  progress: progress,
                  buffered: buffered,
                  total: total,
                  onSeek: (duration) {
                    player.seek(duration);
                  },
                );
              },
            ),
          ),
          // Time remaining
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: StreamBuilder<DurationState>(
              stream: _durationStateStream,
              builder: (context, snapshot) {
                final durationState = snapshot.data;
                final progress = durationState?.progress ?? Duration.zero;
                final total = durationState?.total ?? Duration.zero;
                final remaining = total - progress;
                
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    remainingTime(remaining),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String remainingTime(Duration dur) {
    final hours = (dur.inHours % 60);
    final minutes = (dur.inMinutes % 60).toString().padLeft(2, "0");
    final seconds = (dur.inSeconds % 60).toString().padLeft(2, "0");

    return hours > 0
      ? "-${hours.toString().padLeft(2, "0")}:$minutes:$seconds"
      : "-$minutes:$seconds";
  }

}

class DurationState {
  const DurationState(this.progress, this.buffered, this.total);
  final Duration progress;
  final Duration buffered;
  final Duration total;
}

class WordWithPosition {
  final String word;
  final int startIndex;
  final int endIndex;

  WordWithPosition(
    {required this.word, 
    required this.startIndex, 
    required this.endIndex}
  );
}


class NoteProvider extends ChangeNotifier {
  int? id;
  Note? note;
  FlutterSecureStorage? secureStorage;
  WebSocketService? service;
  AudioPlayer? player;
  
  Duration currentPosition = Duration.zero;

  String? error;
  Timer? timer;

  bool inSearch = false;
  bool isToolBarVisible = false;

  Map<String, bool> changes = {
    'name': false,
    'icon': false,
    'summary': false,
    'transcript': false,
  };

  bool isNoteInitialized = false;
  bool isPlayerInitialized = false;
  bool isServiceInitialized = false;
  bool isVisible = true;
  bool? tempFavValue;

  AudioPlayer get aplayer {
    player ??= AudioPlayer();
    return player!;
  }

  NoteProvider();

  Future<void> initialization(FlutterSecureStorage storage, int id) async {
    secureStorage = storage;
    this.id = id;
  }

  void setNoteInit(bool value) {
    isNoteInitialized = value;
    notifyListeners();
  }

  Future<int> initNote() async {
    print("in initNote");
    final response = await http.get(Uri.parse("http://localhost:8080/note/view"), headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'access_token': await secureStorage!.read(key: 'access_token') ?? '',
      'note_id': id.toString()
    });
    
    if (response.statusCode == 200) {
      // Ensure UTF-8 decoding
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      print(utf8DecodedBody);

      final decodedJson = jsonDecode(utf8DecodedBody);
      print(decodedJson);
      note = Note.fromJson(decodedJson);

      tempFavValue = note!.isFavourite;
      notifyListeners();
      print('Get note worked fine');
    }

    print(response.statusCode);

    return response.statusCode;
  }

  Future<void> initController() async {
    print("in initController");

    service = WebSocketService("ws://localhost:8080/note/audio/${await secureStorage!.read(key: 'access_token') ?? ''}/${id!}");
    await service!.connect();
  }

  Future<int> initPlayer(BuildContext context) async {
    print("in init Player");

    try {

      if (player != null) {
        await player!.stop();
        await player!.dispose();
      }
      player = AudioPlayer();

      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());

      player!.playbackEventStream.listen(
        (event) {
          print(event);
        },
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
          // Handle streaming errors here if needed
        }
      );

      UriAudioSource source = AudioSource.uri(
        Uri.parse("http://localhost:8080/note/audio"),
        headers: {
          "Content-Type": "application-json",
          "access_token": await secureStorage!.read(key: 'access_token') ?? '',
          "note_id": note!.id.toString()
        }
      );

      await player!.setAudioSource(source);
      isPlayerInitialized = true;
      notifyListeners();
      return 200; // Success

    } on PlayerException catch (e, stack) {
      print("Error loading audio source: $e");
      print(stack);
      
      // Convert player errors to appropriate status codes
      if (e.toString().contains('401')) {
        return 401;
      } else if (e.toString().contains('403')) {
        return 403;
      }
      return 500; // General error
    }
  }

  void closeSearch() {
    inSearch = false;
    notifyListeners();
  }

  void setToolBarVisibility(bool value) {
    isToolBarVisible = value;
    notifyListeners();
  }

  void search(String query, int index) {}

  void setFavourite() {
    note!.isFavourite = !note!.isFavourite;
    notifyListeners();
  }

  void setVisible(bool value) {
    isVisible = value;
    notifyListeners();
  }

  void updateFieldStatus(String field, bool changed) {
    if (changes.containsKey(field) && changes[field] != changed) {
      changes[field] = changed;
      notifyListeners();
    }
  }

void afterNoteUpdate({
  required String time,
  String? name,
  String? icon,
  String? summary,
  String? transcript,
}) {
  changes.forEach((key, value) => changes[key] = false);
  note!.setTimeOfLastChanges = DateTime.parse(time);

  if (name != null) note!.notesName = name;
  if (icon != null) note!.icon = icon;
  if (summary != null) note!.summary = summary;
  if (transcript != null) note!.transcript = transcript;

  notifyListeners();
}


  void clear() {
    id = null;
    note = null;
    secureStorage = null;
    service = null;
    if (player != null) {
      player!.stop();
      player!.dispose();
      player = null;
    }
    currentPosition = Duration.zero;

    error = null;
    timer = null;

    inSearch = false;
    isToolBarVisible = false;

    isNoteInitialized = false;
    isPlayerInitialized = false;
    isServiceInitialized = false;
    tempFavValue = null;
  }
}