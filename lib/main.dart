import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

void main() {
  OpenAI.apiKey = 'REMOVED';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherPicture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'WeatherPicture'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

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

Future<void> generateImage(String prompt) async {
  String? imageUrl = '';

  try {
    final image = await OpenAI.instance.image.create(
      prompt: prompt,
      n: 1,
      size: OpenAIImageSize.size1024,
      responseFormat: OpenAIImageResponseFormat.url,
    );
    imageUrl = image.data.first.url;

    setState((){
      imageUrl;
    });

  } catch (e) {
    print('エラーが発生しました: $e');
  }
}