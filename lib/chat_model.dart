enum ChatMessageType { user, bot }

class ChatModel {
  ChatModel({required this.text, required this.type});

  String? text;
  ChatMessageType? type;
}
