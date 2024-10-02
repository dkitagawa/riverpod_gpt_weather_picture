import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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
final responseProvider = NotifierProvider<Response, String>(() {
  return Response();
});


// DALL·E 3 API実行
Future<void> apiRequest(String message, WidgetRef ref) async {
  String responseUrl;
  final providerNotifier = ref.watch(responseProvider.notifier);
  // 取得したAPIキーを入れる
  const apiKey = '{OpenAIのAPIキー}';
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
      home: MyHomePage(title: 'WeatherPicture'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  final _messageController = TextEditingController();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _area = "新宿";
  final String imageUrl = '';

  generateImage('A cute cat playing with a ball of yarn');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              imageUrl,
            ),
            const FloatingActionButton(
              backgroundColor: Colors.yellow,
              onPressed: null,
              child: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }
}
