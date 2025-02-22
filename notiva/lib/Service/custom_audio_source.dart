import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

// Don't need file 

class CustomAudioSource extends StreamAudioSource {
  final String url;
  final String accessToken;
  final String noteId;
  int? _contentLength;
  bool _isFullyBuffered = false;

  CustomAudioSource(this.url, this.accessToken, this.noteId);

  int get contentLength => _contentLength ?? -1;
  bool get isFullyBuffered => _isFullyBuffered;

@override
Future<StreamAudioResponse> request([int? start, int? end]) async {

  final response = await http.get(Uri.parse(url), headers: {
    'access_token': accessToken,
    'note_id': noteId,
  });

  print(response.statusCode);
  print(response.headers);
  print(response.body);

  
  return StreamAudioResponse(
      sourceLength: _contentLength ?? -1,
      contentLength: response.contentLength ?? -1,
      offset: start ?? 0, // Dynamically calculated offset
      stream: Stream.value(response.bodyBytes),
      contentType: response.headers['content-type'] ?? 'audio/mpeg',);

  // try {
  //   print("sending request");

  //   final response = await http.get(
  //     Uri.parse(url),
  //     headers: {
  //       'access_token': accessToken,
  //       'note_id': noteId,
  //       'range': 'bytes=${start ?? 0}-${end ?? ''}', // Always include Range header
  //     }
  //   );

  //   print("get response");

  //   if (response.statusCode != 200 && response.statusCode != 206) {
  //     throw Exception('Failed to load audio: HTTP ${response.statusCode}');
  //   }

  //   // Parse headers for Content-Length and Content-Range
  //   final contentRange = response.headers['content-range'];
  //   if (contentRange != null) {
  //     _contentLength ??= int.tryParse(
  //         contentRange.split('/').last); // Total file length from Content-Range
  //   }

  //   print("Response Headers: ${response.headers}");
  //   print("Content Length: ${_contentLength}");

  //   return StreamAudioResponse(
  //     sourceLength: _contentLength ?? -1,
  //     contentLength: response.contentLength ?? -1,
  //     offset: start ?? 0, // Dynamically calculated offset
  //     stream: Stream.value(response.bodyBytes),
  //     contentType: response.headers['content-type'] ?? 'audio/mpeg',
  //   );
  // } catch (e) {
  //   throw Exception('Audio request failed: $e');
  // }
}

}
