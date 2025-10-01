import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_gpt_weather_picture/chat_gpt_request.dart';
import 'constants.dart';
import 'error_messages.dart';

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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //天気情報表示
            WeatherContentContainer(),
            SizedBox(height: 30),
            //入力UI（日付・地域選択・更新ボタン）
            InputColumn(),
          ],
        ),
      ),
    );
  }
}

/// 天気情報表示コンテナ
/// 責任：Provider監視、エラー管理、画像・テキストの表示
class WeatherContentContainer extends ConsumerWidget {
  const WeatherContentContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(chatGPTRequestProvider);

    return weatherState.when(
      //正常時、画像URLがあれば画像表示、なければプレースホルダー
      data: (state) => _buildContentDisplay(state),
      loading: () => _buildLoadingDisplay(),
      error: (err, stack) => _buildErrorDisplay(err),
    );
  }

  Widget _buildContentDisplay(ChatGPTRequestState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:25),
      child: Column(
        children: [
          // 画像表示部分
          state.weatherImageUrl.isNotEmpty
            ? _buildWeatherImage(state.weatherImageUrl)
            : _buildNoImagePlaceholder(),
          const SizedBox(height: 20),
          _buildLocationInfo(state),
          const SizedBox(height: 15),
          // テキスト表示部分
          _buildWeatherText(state.weatherText),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(ChatGPTRequestState state) {
    return Row(
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
      ],
    );
  }

  Widget _buildWeatherText(String weatherText) {
    return Text(
      weatherText,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 16,
      ),
    );
  }

  Widget _buildLoadingDisplay() {
    return Container (
      padding: const EdgeInsets.symmetric(horizontal:25),
      child: const Column(
        children: [
          Center(
            child: CircularProgressIndicator(),
          ),
          SizedBox(height: 20),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
        
  Widget _buildWeatherImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        final errorMessage = ErrorMessages.createDetailedError(
          ErrorMessages.dalleError,
          error,
        );
        return Text(
          errorMessage,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 14,
          ),
        );
      },
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      width: 200,
      height: 200,
      color: Colors.grey.shade100,
      child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: Colors.grey,
          ),
        ),
      );
    }

  Widget _buildErrorDisplay(Object error) {
    final errorString = error.toString();
    String baseMessage;

    // Exception形式の場合、既にchat_gpt_request.dartで適切なメッセージが設定されている
    if (errorString.contains('Exception: ')) {
      // 既にErrorMessagesで処理されたメッセージを抽出
      baseMessage = errorString.replaceFirst('Exception: ', '');
    } else {
      baseMessage = ErrorMessages.createDetailedError(
        ErrorMessages.apiConnectionError,
        error,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal:25),
      child: Column(
        children: [
          // エラーバナー表示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.shade200,
                  ),
                ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      baseMessage,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
          ),
          const SizedBox(height: 20),
          _buildNoImagePlaceholder(),
        ],
      ),
    );
  }
}

/// 入力UIコンポーネント
/// 責任：日付選択、地域選択、更新ボタンの管理
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
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(chatGPTRequestProvider);

    // エラー時でも入力UIは常に表示
    final state = weatherState.valueOrNull ??
      ChatGPTRequestState(
          area: defaultArea,
          date: DateTime.now()
        );

      return Container(
        padding: const EdgeInsets.symmetric(horizontal:25),
        child: _buildInputUI(state),
      );
  }

  Widget _buildInputUI(ChatGPTRequestState state) {
    return Row(
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
    );
  }

  void _datePicker(BuildContext context, DateTime dateTime, WidgetRef ref) async {
    final DateTime? datePicked = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(dateTime.year - 1, dateTime.month, dateTime.day),
        lastDate: DateTime(dateTime.year + 1, dateTime.month, dateTime.day)
    );
    if (datePicked != null && datePicked != dateTime) {
      ref.read(chatGPTRequestProvider.notifier).updateDate(datePicked);
    }
  }
}
