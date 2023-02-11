import 'dart:convert';

import 'package:http/http.dart' as http;

String apiKey = "<----your Api Key----->";
// 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

class ApiServices {
  static var baseUrl = Uri.parse("https://api.openai.com/v1/completions");

  static Map<String, String> header = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey'
  };
  static sendMessage(String? message) async {
    var res = await http.post(
      baseUrl,
      headers: header,
      body: jsonEncode({
        "model": "text-davinci-003",
        "prompt": "Say this is a test",
        "temperature": 0,
        "max_tokens": 500
      }),
    );
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body.toString());

      var msg = data['choices'][0]['text'];
      return msg;
    } else {
      print(res.statusCode);
      print('Failed to fetch data');
    }
  }
}
