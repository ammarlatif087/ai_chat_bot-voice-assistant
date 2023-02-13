import 'dart:async';

import 'package:ai_chat_bot/speech_screen/speech_screen.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      // Navigate to home screen after 2 seconds
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SpeechScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
              height: 200,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
