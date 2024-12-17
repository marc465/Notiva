import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

void main() {
  runApp(const NotivaApp());
}

class NotivaApp extends StatelessWidget {
  const NotivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notiva",
      home: const HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue),
          useMaterial3: true),
      debugShowCheckedModeBanner: false,
      );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
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
        
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
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
                    const SizedBox(width: 8,),
                    IconButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context)=>const TagPage()
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
        
          body: TabBarView(
            children: <Widget>[
              GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 4,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 10,
                      width: double.infinity,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReview(data: "aNOTE",)));
                          },
                          child: const Row(
                            children: <Widget>[
                              Icon(Icons.rocket),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Text("Title of Note")
                                    ),
                                    Expanded(
                                      child: Text("Subtitle of this Note")
                                    )
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_outlined)
                            ],
                          ),
                        )
                      ),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 10,
                      width: double.infinity,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReview(data: "bNOTE",)));
                          },
                          child: const Row(
                            children: <Widget>[
                              Icon(Icons.rocket),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Text("Title of Note")
                                    ),
                                    Expanded(
                                      child: Text("Subtitle of this Note")
                                    )
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_outlined)
                            ],
                          ),
                        )
                      ),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 10,
                      width: double.infinity,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReview(data: "cNOTE",)));
                          },
                          child: const Row(
                            children: <Widget>[
                              Icon(Icons.rocket),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Text("Title of Note")
                                    ),
                                    Expanded(
                                      child: Text("Subtitle of this Note")
                                    )
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_outlined)
                            ],
                          ),
                        )
                      ),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 10,
                      width: double.infinity,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReview(data: "dNOTE",)));
                          },
                          child: const Row(
                            children: <Widget>[
                              Icon(Icons.rocket),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Text("Title of Note")
                                    ),
                                    Expanded(
                                      child: Text("Subtitle of this Note")
                                    )
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_outlined)
                            ],
                          ),
                        )
                      ),
                    )
                  ),
                ],
              ),
              const Center(child: Icon(Icons.favorite),),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 4,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      child: ElevatedButton(
                        onPressed: (){},
                        child: const Row(
                          children: <Widget>[
                            Icon(Icons.place),
                            Text("Some folder name"),
                            Text("18 notes")
                          ],
                        ),
                      ),
                    ),
                  )
                ]
              )
            ]
          ),
          
        
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: FloatingActionButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewNoteCreation())
                    );
                },
                backgroundColor: Colors.blue.shade700,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))
                ),
                child: const Text("Create New Note", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        
          bottomNavigationBar: const TabBar(
              tabs: <Widget>[
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
  }
}

class TagPage extends StatelessWidget {
  const TagPage({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tags",
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
              decoration: InputDecoration(
                hintText: "Search in the tags",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.mic)
                )
              ),
            ),
          )
        ),
      ),
      body: GridView.count(
        crossAxisCount: 1,
        childAspectRatio: 5,
        children: List.generate(5, (index){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context)=> CurrentTagPage(tag: "#TagIndex:$index")
                        )
                      );
                    },
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "#TagIndex:$index",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold
                  )
                )
              ),
            ),
          );
        }),
      ),
    );
  }
}

class CurrentTagPage extends StatefulWidget {
  final String tag;
  const CurrentTagPage({super.key, required this.tag});

  @override
  State<StatefulWidget> createState() => _CurrentTagPageState();
}

class _CurrentTagPageState extends State<CurrentTagPage> {
  final ScrollController _controller = ScrollController();
  List<int> items = List.generate(10, (index) => index);

  @override
  void initState() {
    super.initState();
    _controller.addListener((){
      if (_controller.position.pixels == _controller.position.maxScrollExtent){
        _loadMoreItems();
      }
    });
  }

  void _loadMoreItems() {
    setState(() {
      items.addAll(List.generate(10, (index) => index));
    });
  }


  @override
  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tag),
          actions: <Widget>[
            IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close_rounded))
          ],
        ),
        body: GridView.builder(
          controller: _controller,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 4
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15))
              ),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  const Row(
                    children: [
                      Icon(Icons.stacked_bar_chart_sharp),
                      Column(
                        children: <Widget>[
                          Text("CV Review",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("29.11.2024")
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      const Text("00:05"),
                      const Text("Some text like we need to correct our costs"),
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          borderRadius: const BorderRadius.all(Radius.circular(20))
                        ),
                        child: Text(
                          "#${widget.tag}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      )
    );
  }
}

class NewNoteCreation extends StatefulWidget {
  const NewNoteCreation({super.key});

  @override
  State<StatefulWidget> createState() => _NewNoteCreationState();
}

class _NewNoteCreationState extends State<NewNoteCreation> {
  Future<PermissionStatus> microphonePermission = Permission.microphone.request();
  Icon playingIcon = const Icon(Icons.play_arrow_rounded, size: 43,);
  final AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;

  Future<bool> _requestMicrophonePermission() async{
    try {
      microphonePermission = Permission.microphone.request();
      if (await microphonePermission.isDenied){
        return Future.value(false);
      }
      else {return Future.value(true);}
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }

  Future<void> startPlay() async {
    if ((await microphonePermission).isDenied) {
      if (! (await _requestMicrophonePermission())) {
        return;
      }
    }
    else {await _record.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100
      ),
      path: "audio_${DateTime.now()}"
    );

    setState((){
      playingIcon = const Icon(Icons.pause_rounded);
      _isRecording = true;
      return;
    });}
  }

  Future<void> stopPlay() async{
    _record.pause();
    setState(() {
      playingIcon = const Icon(Icons.play_arrow_rounded); 
      _isRecording = false;
    });
  }

  @override
  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("New Note"),
          actions: <Widget>[
            IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close_rounded))
          ],
        ),
        body: Container(),
        bottomSheet: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          height: MediaQuery.of(context).size.height * 0.2,
          width: double.infinity,
          child: FloatingActionButton(
            onPressed: (){
              _isRecording? stopPlay(): startPlay();
            },
            shape: const CircleBorder(
              eccentricity: 0
            ),
            backgroundColor: Colors.blue.shade600,
            child: playingIcon,
          ),
        ),
      ),
    );
  }
}

class NoteReview extends StatefulWidget {
  final String data;
  final List<int> mylst = List<int>.generate(10, (index)=>index);
  NoteReview({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => _NoteReviewState();
}

class _NoteReviewState extends State<NoteReview> {
  bool _isFavourite = false;
  Icon favouriteIcon = const Icon(Icons.favorite_border);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                onPressed: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const ShareAndExport(data: "MyData")
                    )
                  );
                },
                icon: const Icon(Icons.more_horiz_rounded)
              )
            ],
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: (){},
                      icon: const Icon(Icons.mic)
                    ),
                    hintText: "Search in the note"
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  const Icon(Icons.stacked_bar_chart),
                  Text(
                    widget.data, 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  Expanded(flex: 4, child: Container()),
                  IconButton(
                    onPressed: (){
                      setState(() {
                        if (!_isFavourite) {
                          favouriteIcon = const Icon(Icons.favorite);
                          _isFavourite = true;
                        }
                        else {
                          favouriteIcon = const Icon(Icons.favorite_border);
                          _isFavourite = false; 
                        }
                      });
                    }, 
                    icon: favouriteIcon
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  const Icon(Icons.calendar_today_rounded),
                  const Text("Oct 2, 2024"),
                  Expanded(flex: 1, child: Container()),
                  const Icon(Icons.watch_later_outlined),
                  const Text("52:24"),
                  Expanded(flex: 4, child: Container()),
                ],
              ),
              const TabBar(tabs: [
                Tab(text: "Summary"),
                Tab(text: "Transcript"),
              ]),
              const Expanded(
                child: TabBarView(
                  children: <Widget>[
                    Center(child: Icon(Icons.summarize)),
                    Center(child: Icon(Icons.transcribe))
                  ]
                ),
              )
            ],
          ),
          bottomSheet: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("00:00"),
                      Expanded(
                        child: Divider(color: Colors.grey,)
                      ),
                      Text("52:17")
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: (){}, 
                        icon: const Icon(Icons.replay_10_rounded)
                      ),
                      FloatingActionButton(
                        onPressed: (){},
                        backgroundColor: Colors.blue,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.play_arrow_rounded)
                      ),
                      IconButton(
                        onPressed: (){}, 
                        icon: const Icon(Icons.forward_10_rounded)
                      ),
                    ],
                  )
                ],
              ),
            ),
        ),
      ),
    );
  }
}

class ShareAndExport extends StatefulWidget {
  final String data;
  const ShareAndExport({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => _ShareAndExportState();
}

class _ShareAndExportState extends State<ShareAndExport> {
  bool switchShare = false;

  @override
  Widget build(context) {
    return SafeArea(
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Share&Export",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              )
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black87, 
                      tabs: const <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: Tab(text: 'Share')
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Tab(text: 'Export')
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: 10,
                children: <Widget>[
                  const Text("File link"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text("https://app.notiva.ai/share/${widget.data}"),
                        const Icon(Icons.copy),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      const Text("Anyone can access web link"),
                      Switch(
                        value: switchShare, 
                        onChanged: (value){
                          setState(() {
                            switchShare = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.greenAccent.shade700,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                      )
                    ],
                  ),
                  const Text("Sharing options"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Share note summary"),
                        const Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Share note transcript"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Share audio"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  const Text("Integration"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Notion"),
                        Icon(Icons.note_rounded),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Google Docs"),
                        Icon(Icons.edit_document),
                      ],
                    ),
                  ),
                ],
              ),
              GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: 10,
                children: <Widget>[
                  const Text("Audio"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export audio"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  const Text("Text"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export as TXT"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export as PDF"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export as DOCX"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export as STR"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export as EXCEL"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  ],
              ),
            ]
          ),
        ),
      )
    );
  }
}
