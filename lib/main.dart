import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_gpt_weather_picture/area_for_search.dart';
import 'package:riverpod_gpt_weather_picture/date_for_search.dart';
import 'package:riverpod_gpt_weather_picture/dall_e_api_request.dart';

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
              child: InputColumn(),
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
        ? const CircularProgressIndicator()
        : Image.network(providerValue);
  }
}

class InputColumn extends ConsumerWidget {
  InputColumn({super.key});
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerNotifier = ref.watch(responseProvider.notifier);
    final String areaForSearch = ref.watch(areaForSearchProvider);
    final DateTime dateForSearch = ref.watch(dateForSearchProvider);

    loadWeatherImage(areaForSearch, dateForSearch, ref);
    _areaController.text = areaForSearch;
    _dateController.text = DateFormat('yyyy-MM-dd').format(dateForSearch);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _dateController.text = DateFormat('yyyy-MM-dd').format(dateForSearch),
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
              child: const Icon(
                Icons.pin_drop,
              ),
              onPressed: () {
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
                _datePicker(context, dateForSearch, ref);
              },
              child: const Icon(
                Icons.calendar_month,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final String area = _areaController.text.trim();
                if (area.isEmpty) {
                  _areaController.clear();
                  return;
                }
                ref.read(areaForSearchProvider.notifier).setArea(area);

                final String date = _dateController.text;
                if (date.isEmpty) {
                  _dateController.clear();
                  return;
                }
                ref.read(dateForSearchProvider.notifier).setDate(DateTime.parse(date));

                providerNotifier.clear();
                loadWeatherImage(areaForSearch, dateForSearch, ref);
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

  void loadWeatherImage(String area, DateTime date, WidgetRef ref)  {
    var prompt = "指定された地域の、指定された日付の天気予報を表現する画像を生成してください。【コンセプト】空撮ではなく地上に立つ人間の視点で対象地域を天気予報の通りの状態で描きます。対象地域のシンボリックな建物・名産品・名物・人間を盛り込み、マンガか映画の有名なシーンを大胆にオマージュしてください。人物描写が印象的だと良いです。【各情報の表示サイズ】情報の表示サイズは以下の順：地域名>>日付（MM/dd形式に変換して表示）>>>>>>>>>>>>対象日付の最高／最低気温と降水確率";

    prompt = "対象地域：$area。対象日付：$date。$prompt";
    dallEApiRequest(prompt, ref);
  }

}
