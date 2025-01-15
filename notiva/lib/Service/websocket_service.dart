import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;
  bool isConnected = false;

  WebSocketService(this.url) {
    print('Initializing WebSocket with URL: $url'); // Debug log
  }

  Future<void> connect() async {
    if (!isConnected) {
      try {
        print('Attempting to connect to WebSocket...'); // Debug log
        _channel = WebSocketChannel.connect(Uri.parse(url));
        isConnected = true;
        print('WebSocket connected successfully');
      } catch (e) {
        print('WebSocket connection failed: $e');
        isConnected = false;
        rethrow;
      }
    }
  }

  Future<void> sendPlay() async {
    if (_channel != null && isConnected) {
      try {
        print('Sending play command...');
        _channel!.sink.add(
          jsonEncode({
            'command': 'play'
          })
        );
        print('Play command sent successfully');
      } catch (e) {
        print('Error sending play command: $e');
        rethrow;
      }
    } else {
      print('Cannot send play command - WebSocket not connected');
      throw Exception('WebSocket not connected');
    }
  }

  void dispose() {
    _channel?.sink.close();
    isConnected = false;
    print('WebSocket disposed');
  }

    Future<void> sendPause() async {
    if (_channel != null) {
        _channel!.sink.add(
          jsonEncode({
            'command': 'pause'
          })
        );
    }
  }

    Future<void> sendStop() async {
    if (_channel != null) {
        _channel!.sink.add(
          jsonEncode({
            'command': 'stop'
          })
        );
    }
    // _channel!.sink.close();
  }

  Future<void> listen(Function(String) onMessage) async {
    if (_channel != null) {
      _channel!.stream.listen((message) {
        onMessage(message);
      });
    }
  }

}
