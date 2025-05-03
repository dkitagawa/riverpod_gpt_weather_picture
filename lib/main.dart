import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_gpt_weather_picture/chat_gpt_request.dart';

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
    final weatherState = ref.watch(chatGPTRequestProvider);

    return weatherState.when(
      data: (state) {
        return state.weatherImageUrl.isNotEmpty
            ? Image.network(state.weatherImageUrl)
            : const Text('天気情報がありません');
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, stack) {
        return Text('エラーが発生しました: $err');
      },
    );
  }
}

class WeatherText extends ConsumerWidget {
  const WeatherText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(chatGPTRequestProvider);

    return weatherState.when(
      data: (state) {
        return Text(
          state.weatherText,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 19,
          ),
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, stack) {
        return Text('エラーが発生しました: $err');
      },
    );
  }
}

class InputColumn extends ConsumerStatefulWidget {
  const InputColumn({super.key});

  @override
  ConsumerState<InputColumn> createState() => _InputColumnState();
}

class _InputColumnState extends ConsumerState<InputColumn> {
  final TextEditingController _areaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // build()メソッドで直接データを取得するため、ここでの呼び出しは不要
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(chatGPTRequestProvider);

    return weatherState.when(
      data: (state) {
        return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(state.date),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    state.area,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 15,),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: WeatherText(),
                  ),
                ],
              ),
              const SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _datePicker(context, state.date, ref);
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
                      _areaController.text = state.area;
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
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
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final String area = _areaController.text
                                        .trim();
                                    if (area.isEmpty) {
                                      _areaController.clear();
                                      return;
                                    }
                                    ref.read(chatGPTRequestProvider.notifier).updateArea(area);
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
                      ref.read(chatGPTRequestProvider.notifier).refreshWeatherData();
                    },
                    child: const Icon(
                      Icons.camera_alt,
                    ),
                  ),
                ],
              ),
            ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('エラーが発生しました: $err'),
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
      ref.read(chatGPTRequestProvider.notifier).updateDate(datePicked);
    }
  }
}
