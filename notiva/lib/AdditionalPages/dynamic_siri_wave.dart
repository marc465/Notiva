import 'package:flutter/material.dart';
import 'package:siri_wave/siri_wave.dart';

class DynamicSiriWave extends StatefulWidget {
  final ValueNotifier<double> amplitudeNotifyer;
  
  const DynamicSiriWave({
    super.key,
    required this.amplitudeNotifyer,
  });

  @override
  State<DynamicSiriWave> createState() => _DynamicSiriWaveState();
}

class _DynamicSiriWaveState extends State<DynamicSiriWave> {
  late IOS9SiriWaveformController controller;
  double _currentAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    controller = IOS9SiriWaveformController(amplitude: 0);
    
    // Додаємо слухача
    widget.amplitudeNotifyer.addListener(_onAmplitudeChanged);
  }

  void _onAmplitudeChanged() {
    setState(() {
      print("-_-_-_-");
      print(widget.amplitudeNotifyer.value);
      _currentAmplitude = widget.amplitudeNotifyer.value;
      controller.amplitude = _currentAmplitude;
      print(_currentAmplitude);
      print(controller.amplitude);
      print("-_-_-_-");
    });
  }

  @override
  void dispose() {
    // Видаляємо слухача
    widget.amplitudeNotifyer.removeListener(_onAmplitudeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SiriWaveform.ios9(
      controller: IOS9SiriWaveformController(amplitude: _currentAmplitude,),
      options: const IOS9SiriWaveformOptions(height: 200, width: 400),
    );
  }
}
