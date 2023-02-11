import 'package:ai_chat_bot/api_services.dart';
import 'package:ai_chat_bot/colors.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../chat_model.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  SpeechToText speechToText = SpeechToText();
  var text = "Hold the button and  start speaking";
  var isListening = false;
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
          'Speech to Text',
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
            speechToText.stop();
            setState(() {
              message.add(ChatModel(text: text, type: ChatMessageType.user));
            });
            var msg = await ApiServices.sendMessage(text);

            print(msg);
            setState(() {
              message.add(ChatModel(text: msg, type: ChatMessageType.bot));
            });
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
            Text(
              text,
              style: TextStyle(
                color: isListening ? Colors.black : Colors.black45,
                fontWeight: FontWeight.bold,
                fontSize: 20,
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
                child: ListView.builder(
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
        const CircleAvatar(
          backgroundColor: bgColor,
          child: Icon(
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
            margin: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                )),
            child: Text("$chatText",
                style: const TextStyle(
                  color: chatBgColor,
                  fontWeight: FontWeight.w400,
                )),
          ),
        ),
      ],
    );
  }
}
