import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PanicDetectorScreen(),
    );
  }
}

class PanicDetectorScreen extends StatefulWidget {
  const PanicDetectorScreen({super.key});

  @override
  State<PanicDetectorScreen> createState() =>
      _PanicDetectorScreenState();
}

class _PanicDetectorScreenState
    extends State<PanicDetectorScreen> {

  NoiseMeter? noiseMeter;

  StreamSubscription<NoiseReading>? subscription;

  double soundLevel = 0;

  String status = "AI Panic Detector";

  int panicCount = 0;

  bool isRunning = false;

  bool emergencyTriggered = false;

  String emergencyNumber = "9390170946";

  @override
  void initState() {
    super.initState();

    noiseMeter = NoiseMeter();

    requestPermissions();
  }

  Future<void> requestPermissions() async {

    await Permission.microphone.request();

    await Permission.phone.request();

    await Permission.location.request();
  }

  Future<String> getLocation() async {

    try {

      Position position =
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return
        "https://maps.google.com/?q=${position.latitude},${position.longitude}";

    } catch (e) {

      return "Location unavailable";
    }
  }

  Future<void> sendEmergencySMS() async {

    try {

      String location =
      await getLocation();

      String message =
          "EMERGENCY! Panic detected.\n"
          "Location: $location";

      final Uri smsUri = Uri.parse(
        "sms:$emergencyNumber"
            "?body=${Uri.encodeComponent(message)}",
      );

      await launchUrl(smsUri);

    } catch (e) {

      debugPrint("SMS ERROR: $e");
    }
  }

  Future<void> makeEmergencyCall() async {

    try {

      final Uri callUri = Uri(
        scheme: 'tel',
        path: emergencyNumber,
      );

      await launchUrl(callUri);

    } catch (e) {

      debugPrint("CALL ERROR: $e");
    }
  }

  Color getStatusColor() {

    if (status.contains("Panic")) {
      return Colors.red;
    }

    else if (status.contains("Anxiety")) {
      return Colors.orange;
    }

    else if (status.contains("Calm")) {
      return Colors.green;
    }

    return Colors.black;
  }

  void startDetection() {

    if (isRunning) return;

    isRunning = true;

    emergencyTriggered = false;

    status = "Listening...";

    subscription =
        noiseMeter!.noise.listen(

              (NoiseReading noiseReading) {

            double decibel =
                noiseReading.meanDecibel;

            if (!mounted) return;

            if (DateTime.now().millisecond % 5 != 0) {
              return;
            }

            setState(() {

              soundLevel = decibel;

              if (decibel > 85) {

                panicCount++;

                status = "🚨 Panic Noise";

                if (panicCount >= 3 &&
                    !emergencyTriggered) {

                  emergencyTriggered = true;

                  sendEmergencySMS();

                  makeEmergencyCall();

                  status =
                  "🚨 Emergency Triggered";
                }
              }

              else if (decibel > 60) {

                status = "😟 Anxiety";
              }

              else {

                panicCount = 0;

                status = "🙂 Calm";
              }
            });
          },

          onError: (e) {

            debugPrint("MIC ERROR: $e");
          },
        );
  }

  void stopDetection() {

    subscription?.cancel();

    isRunning = false;

    setState(() {

      status = "Stopped";
    });
  }

  @override
  void dispose() {

    subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF3EEF5),

      appBar: AppBar(
        title: const Text(
          "AI Panic Detector",
        ),
        backgroundColor:
        Colors.deepPurple,
      ),

      body: Center(

        child: Padding(

          padding:
          const EdgeInsets.all(20),

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              Icon(
                Icons.mic,
                size: 120,
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 30),

              Text(

                status,

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 32,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  getStatusColor(),
                ),
              ),

              const SizedBox(height: 30),

              Text(

                "${soundLevel.toStringAsFixed(1)} dB",

                style: const TextStyle(
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: 20),

              LinearProgressIndicator(
                value:
                (soundLevel / 100)
                    .clamp(0, 1),
                minHeight: 15,
              ),

              const SizedBox(height: 50),

              ElevatedButton(

                onPressed:
                startDetection,

                style:
                ElevatedButton
                    .styleFrom(

                  backgroundColor:
                  Colors.deepPurple,

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                ),

                child: const Text(
                  "Start Detection",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(

                onPressed:
                stopDetection,

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  Colors.red,
                ),

                child: const Text(
                  "Stop",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}