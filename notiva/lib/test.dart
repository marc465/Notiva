import 'dart:async';
import 'package:flutter/material.dart';
import 'package:siri_wave/siri_wave.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Audio Waveforms',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  bool value = false;
  double amplitude = 0.1;
  late Timer timer;
  late IOS7SiriWaveformController siri7Controller;
  late IOS9SiriWaveformController siri9Controller;

  @override
  void initState() {
    super.initState();
    siri7Controller = IOS7SiriWaveformController(
      amplitude: amplitude,
      color: Colors.blue.shade100,
      frequency: 4,
      speed: 0.15,
    );

    siri9Controller = IOS9SiriWaveformController(
      amplitude: amplitude,
      speed: 0.15,
    );

    startAmplitudeUpdates();
  }

  void startAmplitudeUpdates() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        double targetAmplitude = amplitude; // тут ти можеш отримати значення з мікрофона
        siri7Controller.amplitude += (targetAmplitude - siri7Controller.amplitude) * 0.1;
        siri9Controller.amplitude += (targetAmplitude - siri9Controller.amplitude) * 0.1;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              value
                  ? SiriWaveform.ios7(
                      controller: siri7Controller,
                      options: const IOS7SiriWaveformOptions(height: 200, width: 400),
                    )
                  : SiriWaveform.ios9(
                      controller: siri9Controller,
                      options: const IOS9SiriWaveformOptions(height: 200, width: 400),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    value = !value;
                  });
                },
                child: const Text("Toggle Waveform"),
              ),
              TextButton(
                onPressed: () {
                  print("in high");
                  print(amplitude);
                  setState(() {
                    amplitude += 0.1;
                    // amplitude = (amplitude < 1.0) ? amplitude + 0.1 : 1.0;
                  });
                  print(amplitude);
                  print("out of high");
                },
                child: const Text("Increase Amplitude"),
              ),
              TextButton(
                onPressed: () {
                  print("in low");
                  print(amplitude);
                  setState(() {
                    amplitude -= 0.1;
                    // amplitude = (amplitude > 0.0) ? amplitude - 0.1 : 0.0;
                  });
                  print(amplitude);
                  print("out of low");
                },
                child: const Text("Decrease Amplitude"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
