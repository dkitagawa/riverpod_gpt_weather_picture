import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_gpt_weather_picture/area_for_search.dart';
import 'package:riverpod_gpt_weather_picture/date_for_search.dart';

class Response extends Notifier<String> {
  @override
  String build(){
    return '';
  }
  void clear() {
    state = '';
  }
  void modify(String url) {
    state = url;
  }
}

final responseProvider = NotifierProvider<Response, String>(
  () {
    return Response();
  }
);

// DALL·E 3 API実行
Future<void> apiRequest(String message, WidgetRef ref) async {
  String responseUrl;
  final providerNotifier = ref.watch(responseProvider.notifier);
  // 取得したAPIキーを入れる
  const apiKey = 'REMOVED';
  const domain = 'api.openai.com';
  const path = 'v1/images/generations';
  // モデルの指定
  const model = 'dall-e-3';

  // APIリクエスト
  http.Response response = await http.post(
    Uri.https(domain, path),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode(<String, dynamic>{
      // モデル
      "model": model,
      // 指示メッセージ
      "prompt": message,
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
    responseUrl = responseJsonData['data'][0]['url'];
    providerNotifier.modify(responseUrl);
  } else {
    throw Exception('Failed to load sentence');
  }
}

void loadWeatherImage(String area, String date, WidgetRef ref)  {
  var prompt = "天気を、地域のシンボリックな建物を主役にして地上目線で表現してください。指定された地域名、日付、最高気温、最低気温、降水確率を個別に取得してから画像生成を始めてください。指定された地域名と日付を大きく記載してください。最高／最低気温と降水確率は一箇所にコンパクトにまとめて表記してください。対象地域の名産品や名物を、生成するイメージに少しだけ盛り込んでください。";

  prompt = "$dateの$areaの$prompt";
  apiRequest(prompt, ref);
}

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherPicture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'WeatherPicture'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
              ),
              // 生成された画像の表示
              child: const WeatherImage(),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
              ),
              child: InputRow(),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherImage extends ConsumerWidget {
  const WeatherImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerValue = ref.watch(responseProvider);
    return providerValue == ''
        ? const Text('')
        : Image.network(providerValue);
  }
}

class InputRow extends ConsumerWidget {
  InputRow({super.key});
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerNotifier = ref.watch(responseProvider.notifier);
    final String areaForSearch = ref.watch(areaForSearchProvider);
    final String dateForSearch = ref.watch(dateForSearchProvider);

    loadWeatherImage(areaForSearch, dateForSearch, ref);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            maxLines: 1,
            decoration: const InputDecoration(
              hintText: '地域を入力',
              hintStyle: TextStyle(color: Colors.black54),
            ),
          ),
        ),
        ElevatedButton(
          child: const Text('AI画像生成'),
          onPressed: () {
            final String area = _messageController.text.trim();

            if (area.isEmpty) {
              _messageController.clear();
              return;
            }

            ref.read(areaForSearchProvider.notifier).setArea(area);
            //ref.read(dateForSearchProvider.notifier)a.setDate(date);

            providerNotifier.clear();
            loadWeatherImage(areaForSearch, dateForSearch, ref);
          },
        ),
      ]
    );
  }
}

