import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'image_url.g.dart';

@riverpod
class ImageUrl extends _$ImageUrl {
  static const String domain = 'api.openai.com';
  static const String path = 'v1/images/generations';
  static const String model = 'dall-e-3';

  @override
  Future<String> build() async {
    return '';
  }

  Future<void> getImageUrl(String area, DateTime date) async {
    var prompt = "対象地域：$area。対象日付：$date。指定された地域の、指定された日付の天気予報を表現する画像を生成してください。【コンセプト】空撮ではなく地上に立つ人間の視点で対象地域を天気予報の通りの状態で描きます。対象地域のシンボリックな建物・名産品・名物・人間を盛り込み、マンガか映画の有名なシーンを大胆にオマージュしてください。人物描写が印象的だと良いです。【各情報の表示サイズ】情報の表示サイズは以下の順：地域名>>日付（MM/dd形式に変換して表示）>>>>>>>>>>>>対象日付の最高／最低気温と降水確率";

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
          "prompt": prompt,
          // 生成枚数
          "n" : 1,
          // 画像サイズ
          "size": "1024x1024",
          // クオリティ
          "quality": "standard"
        }),
      );
      
      if (response.statusCode == 200) {
        String responseData = utf8.decode(response.bodyBytes).toString();
        final responseJsonData = jsonDecode(responseData);
        final imageUrl = responseJsonData['data'][0]['url'];
        state = AsyncValue.data(imageUrl);
      } else {
        throw Exception('Failed to load sentence on $model');
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
