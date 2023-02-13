import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  static FlutterTts tts = FlutterTts();
  static initTTS() {
    tts.setLanguage("en-US");
  }

  static speak(String msg, BuildContext context) async {
    await tts.awaitSpeakCompletion(true);
    tts.setErrorHandler((message) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error ...Try again!'),
          duration: Duration(seconds: 1)));
    });

    tts.setStartHandler(() {
      print("TTS IS STARTED...");
    });

    tts.setCompletionHandler(() {
      print("TTS IS COMPLETED...");
    });

    tts.speak(msg);
  }

  static stopSpeak() {
    tts.stop();
  }
}
