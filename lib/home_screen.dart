import 'dart:io';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:audio_recorder_flutter/color_constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecording = false;
  bool _isPlaying = false;
  Recording _recording;
  String pathFile;
  String tempFilename = "TempRecording";
  File defaultAudioFile;
  AudioPlayer audioPlayer = new AudioPlayer();

  @override
  void initState() {
    _handleAudioPlayerState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AudioRecorder.isRecording,
      builder: _getAudioCardBuilder,
    );
  }

  Widget _getAudioCardBuilder(
      BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        return Container();
      default:
        _isRecording = snapshot.data;
        return new Card(
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(flex: 1),
                Container(
                  width: 120.0,
                  height: 120.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 14.0,
                    valueColor: _isRecording
                        ? AlwaysStoppedAnimation<Color>(ColorConstant.enabledColor)
                        : AlwaysStoppedAnimation<Color>(ColorConstant.disabledColor),
                    value: _isRecording ? null : 100.0,
                  ),
                ),
                Spacer(),
                buildButtonsRow(),
                Spacer(),
              ],
            ),
          ),
        );
    }
  }

  Widget buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new FloatingActionButton(
          child: _isRecording
              ? new Icon(Icons.stop, size: 36.0)
              : new Icon(Icons.mic, size: 36.0),
          disabledElevation: 0.0,
          backgroundColor: _isPlaying? ColorConstant.disabledColor: ColorConstant.enabledColor,
          onPressed: _isPlaying? null : _isRecording ? stopRecording : startRecording,
        ),
        SizedBox(width: 50,),
        FloatingActionButton(
          child: _isPlaying
              ? new Icon(Icons.pause, size: 36.0)
              : new Icon(Icons.play_arrow, size: 36.0),
          disabledElevation: 0.0,
          backgroundColor: _isRecording? ColorConstant.disabledColor: ColorConstant.enabledColor,
          onPressed: _isRecording || defaultAudioFile == null ? null : togglePlayAudio,
        )
      ],
    );
  }

  startRecording() async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      String newFilePath = p.join(docDir.path, this.tempFilename);
      File tempAudioFile = File(newFilePath + '.m4a');
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Recording."),
        duration: Duration(milliseconds: 1400),
      ));
      if (await tempAudioFile.exists()) {
        await tempAudioFile.delete();
      }
      if (await AudioRecorder.hasPermissions) {
        await AudioRecorder.start(
            path: newFilePath, audioOutputFormat: AudioOutputFormat.AAC);
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Error! Audio recorder lacks permissions.")));
      }
      bool isRecording = await AudioRecorder.isRecording;
      setState(() {
        _recording = new Recording(duration: new Duration(), path: newFilePath);
        _isRecording = isRecording;
        defaultAudioFile = tempAudioFile;
      });
    } catch (e) {
      print(e);
    }
  }

  stopRecording() async {
    _recording = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;
    Directory docDir = await getApplicationDocumentsDirectory();

    setState(() {
      _isRecording = isRecording;
      defaultAudioFile = File(p.join(docDir.path, this.tempFilename + '.m4a'));
    });
  }

  togglePlayAudio() async {
    if (_isPlaying) {
      await audioPlayer.stop();
      return;
    }
    await audioPlayer.play(this._recording.path, isLocal: true);
  }

  _handleAudioPlayerState() {
    audioPlayer.onPlayerStateChanged.listen((event) {
      switch (event) {
        case AudioPlayerState.STOPPED:
          _isPlaying = false;
          break;
        case AudioPlayerState.PLAYING:
          _isPlaying = true;
          break;
        case AudioPlayerState.PAUSED:
          _isPlaying = false;
          break;
        case AudioPlayerState.COMPLETED:
          _isPlaying = false;
          break;
      }
      // TO CHANGE PLAY / PAUSE ICON
      setState(() {});
    });
  }
}
