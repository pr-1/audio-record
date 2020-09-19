
import 'package:audio_recorder_flutter/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


void main() => runApp(new AudioRecorder());

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => new _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  @override
  void initState() {
    requestPermissions();
    super.initState();
  }
  requestPermissions() async {
    await [
      Permission.microphone,
      Permission.storage,
    ].request();
  }
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}
