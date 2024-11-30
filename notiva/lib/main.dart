import 'package:flutter/material.dart';
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
      child: Scaffold(
      
        appBar:  AppBar(
          title: const Text('MyNotes'),
          actions: <Widget>[
            IconButton(onPressed: (){},
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
      
        body: GridView.count(
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
                      onPressed: (){},
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
                      onPressed: (){},
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
                      onPressed: (){},
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
                      onPressed: (){},
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
      
        bottomNavigationBar: const DefaultTabController(
          length: 3,
          child: TabBar(
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
        )
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
  final AudioRecorder _record = AudioRecorder();
  Icon playingIcon = const Icon(Icons.play_arrow_rounded);

  Future<void> startPlay() async {
    if (await _record.hasPermission()){
      await _record.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100
        ),
        path: "audio_${DateTime.now()}"
      );
      setState(()=> playingIcon = const Icon(Icons.pause_rounded));
    }
  }

  Future<void> stopPlay() async{
    _record.stop();
    setState(() => playingIcon = const Icon(Icons.play_arrow_rounded));
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
              
            },
            shape: const CircleBorder(
              eccentricity: 1
            ),
            backgroundColor: Colors.blue.shade600,
            child: playingIcon,
          ),
        ),
      ),
    );
  }
}
