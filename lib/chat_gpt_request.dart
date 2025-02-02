import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'chat_gpt_request.g.dart';

@riverpod
class ChatGPTRequest extends _$ChatGPTRequest {
  static const String domain = 'api.openai.com';
  static const String path = 'v1/chat/completions';
  static const String model = 'gpt-4o';

  @override
  Future<String> build() async {
    return '';
  }

  Future<void> getWeatherText(String area, DateTime date) async {
    var prompt = "$areaの、$dateの天気予報、最高／最低気温、降水確率を簡潔に教えて下さい。";

    state = const AsyncValue.loading();
    try {
      await dotenv.load(fileName: ".env");

      final apiKey = dotenv.env['API_KEY'];  // APIキーを取得
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API_KEY is missing or empty");
      }

      http.Response response = await http.post(  // APIリクエスト
        Uri.https(domain, path),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(<String, dynamic>{
          // モデル
          "model": model,
          // 指示メッセージ
          "messages": [
            {
              "role": "user",
              "content": [
                {
                "type": "text",
                "text": prompt,
                }
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        String responseData = utf8.decode(response.bodyBytes).toString();
        final responseJsonData = jsonDecode(responseData);
        final responceMessage = responseJsonData['choices'][0]['message']['content'];
        state = AsyncValue.data(responceMessage);
      } else {
        throw Exception('Failed to load sentence on $model');
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
