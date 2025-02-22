import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';

class AIMessengerPage extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  final int noteId;
  const AIMessengerPage({super.key, required this.secureStorage, required this.noteId});

  @override
  State<AIMessengerPage> createState() => _AIMessengerPageState();
}

class _AIMessengerPageState extends State<AIMessengerPage> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  List<Message> _messages = <Message>[];
  final ScrollController _scrollController = ScrollController();  
  late ServiceAPI requestProvider;

  // Animation controller for new messages
  late final AnimationController _messageAnimationController;
  
  @override
  void initState() {
    super.initState();
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
    requestProvider.handleRequest(getMessages, context);
    _messageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _messageAnimationController.dispose();
    super.dispose();
  }

  Future<int> getMessages() async {
    final response = await http.get(
      Uri.parse("http://localhost:8080/ai/chat"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': await widget.secureStorage.read(key: 'access_token') ?? '',
        'note_id': widget.noteId.toString(),
      },
    );

    List<dynamic> messagesOnServer = jsonDecode(response.body);

    if (!messagesOnServer.isEmpty) {
      setState(() {
        _messages = messagesOnServer.map((message) => Message.fromJson(message)).toList();
      });
    }

    return response.statusCode;
  }

  Future<int> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return 0;
    
    final message = Message(
      text: text,
      isUser: true,
      // timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _textController.clear();
    });

    final response = await http.post(
      Uri.parse("http://localhost:8080/ai/chat"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': await widget.secureStorage.read(key: 'access_token') ?? '',
        'note_id': widget.noteId.toString(),
      },
      body: jsonEncode({'message': message.text}),
    );

    if (response.statusCode != 200) {
      return response.statusCode;
    }
    
    Map<String, dynamic> answear = jsonDecode(response.body);

    setState(() {
      _messages.where((message) => message.isUser == true).last.isReaded = true;
      _messages.add(Message.fromJson(answear));
    });
    
    // Scroll to bottom after adding message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
    
    // Trigger message animation
    _messageAnimationController.forward(from: 0.0);

    return 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation with AI',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You can ask questions, get explanations, or have a friendly chat!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _MessageBubble(message: message);
        // return SlideTransition(
        //   position: Tween<Offset>(
        //     begin: const Offset(0, 1),
        //     end: Offset.zero,
        //   ).animate(CurvedAnimation(
        //     parent: _messageAnimationController,
        //     curve: Curves.easeOut,
        //   )),
        //   child: _MessageBubble(message: message),
        // );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () async {
              await requestProvider.handleRequest(
                () async {return await _handleSubmitted(_textController.text);}, 
              context);
            },
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final bool isUser;
  // final DateTime timestamp;
  bool isReaded;

  Message({
    required this.text,
    required this.isUser,
    // required this.timestamp,
    this.isReaded = false,
  });

  Message.fromJson(Map<String, dynamic> json)
      : text = json['message'],
        isUser = json['sender'],
        // timestamp = DateTime.parse(json['timestamp']),
        isReaded = true;
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.blueGrey[700],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
