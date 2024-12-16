import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_gpt_weather_picture/area_for_search.dart';
import 'package:riverpod_gpt_weather_picture/date_for_search.dart';
import 'package:riverpod_gpt_weather_picture/image_url.dart';

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
      home: const MyHomePage(title: '天気予創'),
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
              ),
              child: const InputColumn(),
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
    final imageUrl = ref.watch(imageUrlProvider);

    return imageUrl.when(
      data: (imageUrl) => imageUrl == ''
          ? const CircularProgressIndicator()
          : Image.network(imageUrl),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('エラーが発生しました: $err'),
    );
  }
}

class InputColumn extends ConsumerStatefulWidget {
  const InputColumn({super.key});

  @override
  ConsumerState<InputColumn> createState() => _InputColumnState();
}

class _InputColumnState extends ConsumerState<InputColumn> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final String areaForSearch = ref.read(areaForSearchProvider);
      final DateTime dateForSearch = ref.read(dateForSearchProvider);
      ref.read(imageUrlProvider.notifier).getImageUrl(
          areaForSearch, dateForSearch);
    });
  }

  final TextEditingController _areaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String areaForSearch = ref.watch(areaForSearchProvider);
    final DateTime dateForSearch = ref.watch(dateForSearchProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('yyyy-MM-dd').format(dateForSearch),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              areaForSearch,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 30,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _datePicker(context, dateForSearch, ref);
              },
              child: const Icon(
                Icons.calendar_month,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              child: const Icon(
                Icons.pin_drop,
              ),
              onPressed: () {
                _areaController.text = areaForSearch;
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('対象エリアの指定'),
                    content: TextField(
                      controller: _areaController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: '地域を入力',
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          final String area = _areaController.text.trim();
                          if (area.isEmpty) {
                            _areaController.clear();
                            return;
                          }
                          ref.read(areaForSearchProvider.notifier).setArea(area);
                          Navigator.pop(context, 'OK');
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 10,),
            ElevatedButton(
              onPressed: () {
                if (areaForSearch.isEmpty) {
                  return;
                }
                ref.read(imageUrlProvider.notifier).getImageUrl(areaForSearch, dateForSearch);
              },
              child: const Icon(
                Icons.camera_alt,
              ),
            ),
          ],
        ),
      ]
    );
  }

  void _datePicker(BuildContext context, DateTime dateTime, WidgetRef ref) async {
    final DateTime? datePicked = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030)
    );
    if (datePicked != null && datePicked != dateTime) {
      ref.read(dateForSearchProvider.notifier).setDate(datePicked);
    }
  }
}
