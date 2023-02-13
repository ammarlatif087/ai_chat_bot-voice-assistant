import 'package:ai_chat_bot/api_Services/api_services.dart';
import 'package:ai_chat_bot/utils/tts.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../model/chat_model.dart';
import '../utils/colors.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  SpeechToText speechToText = SpeechToText();
  var text = "Hold the button and  start speaking";
  var isListening = false;
  late bool isLoading;
  final List<ChatModel> message = [];
  var scrollController = ScrollController();

  scrollMethod() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        centerTitle: true,
        elevation: 0.0,
        leading: const Icon(
          Icons.sort_rounded,
          color: textColor,
        ),
        title: const Text(
          'AI chat bot',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 75.0,
        animate: isListening,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        glowColor: bgColor,
        repeatPauseDuration: const Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details) async {
            TextToSpeech.tts.stop();
            if (!isListening) {
              var available = await speechToText.initialize();
              if (available) {
                setState(() {
                  isListening = true;
                  speechToText.listen(onResult: ((result) {
                    setState(() {
                      text = result.recognizedWords;
                    });
                  }));
                });
              }
            }
          },
          onTapUp: (details) async {
            setState(() {
              isListening = false;
            });
            await speechToText.stop();
            if (text.isNotEmpty &&
                text != "Hold the button and  start speaking") {
              setState(() {
                isLoading = true;
                message.add(ChatModel(text: text, type: ChatMessageType.user));
              });
              var msg = await ApiServices.sendMessage(text);
              if (msg != null) {
                msg = msg.trim();
              }
              setState(() {
                isLoading = false;
                isListening = false;
                message.add(ChatModel(text: msg, type: ChatMessageType.bot));
              });
              Future.delayed(const Duration(microseconds: 500), () {
                TextToSpeech.speak(msg, context);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Failed to process ...Try again!'),
                  duration: Duration(seconds: 1)));
            }
          },
          child: CircleAvatar(
            backgroundColor: bgColor,
            radius: 35,
            child: isListening
                ? const Icon(
                    Icons.mic,
                    color: textColor,
                  )
                : const Icon(Icons.mic_none),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isListening ? Colors.black : Colors.black45,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                    color: chatBgColor,
                    borderRadius: BorderRadius.circular(22)),
                child: Column(
                  children: [
                    Visibility(
                      visible: message.isEmpty,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          "How may i help you today?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: bgColor),
                        )),
                      ),
                    ),
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: scrollController,
                      itemCount: message.length,
                      shrinkWrap: true,
                      itemBuilder: ((context, index) {
                        var chat = message[index];
                        return chatBubble(
                          chatText: chat.text,
                          type: chat.type,
                        );
                      }),
                    ),
                    Visibility(
                      visible: isLoading,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: progressIndicator(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatBubble({required chatText, required ChatMessageType? type}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: bgColor,
          child: type == ChatMessageType.bot
              ? const Icon(
                  Icons.adb_outlined,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
                color: type == ChatMessageType.user ? Colors.white : bgColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                )),
            child: Text("$chatText",
                style: TextStyle(
                  color: type == ChatMessageType.user ? bgColor : Colors.white,
                  fontWeight: type == ChatMessageType.bot
                      ? FontWeight.w600
                      : FontWeight.w400,
                )),
          ),
        ),
      ],
    );
  }

  Widget progressIndicator() {
    return Center(
      child: SpinKitWave(
        itemCount: 3,
        size: 30,
        itemBuilder: (context, index) {
          return const DecoratedBox(
              decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
          ));
        },
      ),
    );
  }
}
