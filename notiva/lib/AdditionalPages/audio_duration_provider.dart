import 'package:flutter/cupertino.dart';

class AudioDurationWidget extends StatefulWidget {
  const AudioDurationWidget({super.key});

  @override
  State<AudioDurationWidget> createState() => _AudioDurationWidgetState();
}

class _AudioDurationWidgetState extends State<AudioDurationWidget> {
  Duration _audioDuration = Duration.zero;
  Duration _lastUpdated = Duration.zero;

  void updateAudioDurationWith(Duration duration) {
    _audioDuration += duration;

    if (_audioDuration.inSeconds > _lastUpdated.inSeconds) {
      _lastUpdated = _audioDuration;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// ⏳ Форматуємо тривалість у `MM:SS`
  String get formattedDuration {
    String minutes = "${_audioDuration.inMinutes % 60}".padLeft(2, "0");
    String seconds = "${_audioDuration.inSeconds % 60}".padLeft(2, "0");
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formattedDuration,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: CupertinoColors.secondaryLabel,
      ),
    );
  }
}
