# Refactoring Roadmap for Weather Picture App

This document outlines a step-by-step approach to refactor the Weather Picture application to follow Clean Architecture principles. The refactoring will be done in phases to ensure the application remains functional throughout the process.

## Current Application Structure

The application currently has a simple structure:

- **UI Components** (in `main.dart`)
  - MyApp, MyHomePage (structural components)
  - WeatherImage, WeatherText (display components)
  - InputColumn (interactive component)

- **State Management & API Logic** (in `chat_gpt_request.dart`)
  - ChatGPTRequestState (data model)
  - ChatGPTRequest (Riverpod notifier with API calls)
  - API interaction with OpenAI (ChatGPT and DALL-E)

## Phase 1: Method Extraction and Initial Refactoring

This phase focuses on improving the current codebase without changing the overall architecture.

### 1.1 Extract UI Components

1. Create a `widgets` directory under `lib`
2. Extract each widget into its own file:
   - `widgets/weather_image.dart`
   - `widgets/weather_text.dart`
   - `widgets/input_column.dart`
3. Update imports in `main.dart`

### 1.2 Extract API Services

1. Create a `services` directory under `lib`
2. Create service classes:
   - `services/chat_gpt_service.dart` - For ChatGPT API interactions
   - `services/dalle_service.dart` - For DALL-E API interactions
3. Move API-specific code from `chat_gpt_request.dart` to these services
4. Update `chat_gpt_request.dart` to use these services

### 1.3 Improve State Management

1. Refine `ChatGPTRequestState` to be more focused
2. Improve error handling in the Riverpod provider
3. Add proper loading states

## Phase 2: Clean Architecture Implementation

This phase introduces the Clean Architecture layers while maintaining the existing functionality.

### 2.1 Domain Layer

1. Create the domain layer structure:
   ```
   lib/domain/
   ├── entities/
   ├── repositories/
   └── usecases/
   ```

2. Create core business entities:
   - `domain/entities/weather_forecast.dart` - Core weather data entity
   - `domain/entities/location.dart` - Location entity

3. Define repository interfaces:
   - `domain/repositories/weather_repository.dart` - Interface for weather data access

4. Implement use cases:
   - `domain/usecases/get_weather_forecast.dart` - Get weather forecast for a location and date
   - `domain/usecases/update_location.dart` - Update the selected location
   - `domain/usecases/update_date.dart` - Update the selected date

### 2.2 Data Layer

1. Create the data layer structure:
   ```
   lib/data/
   ├── datasources/
   │   ├── local/
   │   └── remote/
   ├── models/
   └── repositories/
   ```

2. Create data models:
   - `data/models/weather_forecast_model.dart` - Implementation of the weather entity
   - `data/models/location_model.dart` - Implementation of the location entity

3. Create data sources:
   - `data/datasources/remote/chat_gpt_datasource.dart` - ChatGPT API interactions
   - `data/datasources/remote/dalle_datasource.dart` - DALL-E API interactions

4. Implement repositories:
   - `data/repositories/weather_repository_impl.dart` - Implementation of the weather repository

### 2.3 Presentation Layer

1. Create the presentation layer structure:
   ```
   lib/presentation/
   ├── pages/
   ├── providers/
   ├── viewmodels/
   └── widgets/
   ```

2. Create view models:
   - `presentation/viewmodels/weather_viewmodel.dart` - Business logic for the UI

3. Create providers:
   - `presentation/providers/weather_providers.dart` - Riverpod providers

4. Reorganize UI components:
   - Move widgets from `lib/widgets/` to `lib/presentation/widgets/`
   - Create `presentation/pages/home_page.dart` for the main screen

### 2.4 Core Layer

1. Create the core layer structure:
   ```
   lib/core/
   ├── constants/
   ├── errors/
   ├── utils/
   └── widgets/
   ```

2. Add common utilities:
   - `core/constants/api_constants.dart` - API-related constants
   - `core/errors/failures.dart` - Error handling
   - `core/utils/date_formatter.dart` - Date formatting utilities

## Phase 3: Dependency Injection and Configuration

1. Implement dependency injection using Riverpod:
   - `lib/injection_container.dart` - Configure all dependencies

2. Update `main.dart` to use the new architecture:
   - Initialize dependency injection
   - Use the new page structure

## Phase 4: Testing and Refinement

1. Add unit tests:
   - Test domain use cases
   - Test repository implementations
   - Test data sources

2. Add widget tests:
   - Test UI components
   - Test integration with providers

3. Refine and optimize:
   - Improve error handling
   - Optimize performance
   - Reduce code duplication

## Implementation Timeline

1. **Phase 1 (Method Extraction)**: 1-2 days
   - Focus on improving the current codebase without changing the architecture
   - Make small, incremental changes to reduce risk

2. **Phase 2 (Clean Architecture)**: 3-5 days
   - Implement the core architecture components
   - Gradually migrate functionality to the new architecture

3. **Phase 3 (Dependency Injection)**: 1-2 days
   - Set up proper dependency injection
   - Ensure all components work together

4. **Phase 4 (Testing and Refinement)**: 2-3 days
   - Add tests and documentation
   - Refine the implementation based on feedback

## Detailed Implementation Guide

### Phase 1.1: Extract UI Components

#### Step 1: Create Widget Files

Create the following files:

**lib/widgets/weather_image.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_gpt_weather_picture/chat_gpt_request.dart';

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
```

**lib/widgets/weather_text.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_gpt_weather_picture/chat_gpt_request.dart';

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
```

**lib/widgets/input_column.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_gpt_weather_picture/chat_gpt_request.dart';
import 'package:riverpod_gpt_weather_picture/widgets/weather_text.dart';

class InputColumn extends ConsumerStatefulWidget {
  const InputColumn({super.key});

  @override
  ConsumerState<InputColumn> createState() => _InputColumnState();
}

class _InputColumnState extends ConsumerState<InputColumn> {
  final TextEditingController _areaController = TextEditingController();

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
```

#### Step 2: Update main.dart

Update `main.dart` to use the extracted widgets:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_gpt_weather_picture/widgets/weather_image.dart';
import 'package:riverpod_gpt_weather_picture/widgets/input_column.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
```

### Phase 1.2: Extract API Services

#### Step 1: Create Service Files

**lib/services/api_constants.dart**
```dart
class ApiConstants {
  // OpenAI API関連の定数
  static const String apiDomain = 'api.openai.com';
  
  // ChatGPT関連の定数
  static const String apiPathChatGpt = 'v1/chat/completions';
  static const String apiModelChatGpt = 'gpt-4o';
  
  // DALL-E関連の定数
  static const String apiPathDalle = 'v1/images/generations';
  static const String apiModelDalle = 'dall-e-3';
}
```

**lib/services/chat_gpt_service.dart**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_gpt_weather_picture/services/api_constants.dart';

class ChatGPTService {
  Future<String> fetchWeatherForecast(String area, String date) async {
    final String apiKey = _getApiKey();
    final prompt = _createWeatherPrompt(area, date);

    http.Response response = await http.post(
      Uri.https(ApiConstants.apiDomain, ApiConstants.apiPathChatGpt),
      headers: _createHeaders(apiKey),
      body: jsonEncode(_createChatGPTRequest(prompt)),
    );

    return _handleChatGPTResponse(response);
  }

  String _getApiKey() {
    final String apiKey = dotenv.env['API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('API_KEY is missing or empty. Please check your .env file.');
    }
    return apiKey;
  }

  Map<String, String> _createHeaders(String apiKey) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  String _createWeatherPrompt(String area, String date) {
    return "$areaの、$dateの天気予報、最高／最低気温、降水確率を簡潔に教えて下さい。";
  }

  Map<String, dynamic> _createChatGPTRequest(String prompt) {
    return <String, dynamic>{
      "model": ApiConstants.apiModelChatGpt,
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
    };
  }

  String _handleChatGPTResponse(http.Response response) {
    if (response.statusCode == 200) {
      String responseData = utf8.decode(response.bodyBytes).toString();
      final responseJsonData = jsonDecode(responseData);
      final responseMessage = responseJsonData['choices'][0]['message']['content'];
      return responseMessage;
    } else {
      throw Exception('Failed to load sentence on ${ApiConstants.apiModelChatGpt} : ${response.statusCode}');
    }
  }
}
```

**lib/services/dalle_service.dart**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_gpt_weather_picture/services/api_constants.dart';

class DalleService {
  Future<String> fetchWeatherImage(String area, String date) async {
    final String apiKey = _getApiKey();
    final prompt = _createImagePrompt(area, date);

    http.Response response = await http.post(
      Uri.https(ApiConstants.apiDomain, ApiConstants.apiPathDalle),
      headers: _createHeaders(apiKey),
      body: jsonEncode(_createDallERequest(prompt)),
    );

    return _handleDallEResponse(response);
  }

  String _getApiKey() {
    final String apiKey = dotenv.env['API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('API_KEY is missing or empty. Please check your .env file.');
    }
    return apiKey;
  }

  Map<String, String> _createHeaders(String apiKey) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  String _createImagePrompt(String area, String date) {
    return "対象地域：$area。対象日付：$date。指定された地域の、指定された日付の天気予報を表現する画像を生成してください。【コンセプト】空撮ではなく地上に立つ人間の視点で対象地域を天気予報の通りの状態で描きます。対象地域のシンボリックな建物・名産品・名物・人間を盛り込み、マンガか映画の有名なシーンを大胆にオマージュしてください。人物が後ろ姿にならないよう注意して、生き生きとした人物の表情や活動をダイナミックに描くことを出力するイメージ全体の最優先事項としてください。【各情報の表示サイズ】情報の表示サイズは以下の順：地域名>>日付（MM/dd形式に変換して表示）>>>>>>>>>>>>対象日付の最高／最低気温と降水確率";
  }

  Map<String, dynamic> _createDallERequest(String prompt) {
    return <String, dynamic>{
      "model": ApiConstants.apiModelDalle,
      "prompt": prompt,
      "n": 1,
      "size": "1024x1024",
      "quality": "standard"
    };
  }

  String _handleDallEResponse(http.Response response) {
    if (response.statusCode == 200) {
      String responseData = utf8.decode(response.bodyBytes).toString();
      final responseJsonData = jsonDecode(responseData);
      final imageUrl = responseJsonData['data'][0]['url'];
      return imageUrl;
    } else {
      throw Exception('Failed to load sentence on ${ApiConstants.apiModelDalle} : ${response.statusCode}');
    }
  }
}
```

#### Step 2: Update ChatGPTRequest to use services

**lib/chat_gpt_request.dart** (Updated)
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:riverpod_gpt_weather_picture/services/chat_gpt_service.dart';
import 'package:riverpod_gpt_weather_picture/services/dalle_service.dart';

part 'chat_gpt_request.g.dart';

class ChatGPTRequestState {
  final String area;
  final DateTime date;
  final String weatherText;
  final String weatherImageUrl;
  final AsyncValue? resultOfChatGPT;
  final AsyncValue? resultOfDallE;

  ChatGPTRequestState({
    required this.area,
    required this.date,
    this.weatherText = "初期化中…",
    this.weatherImageUrl = "",
    this.resultOfChatGPT,
    this.resultOfDallE,
  });

  ChatGPTRequestState copyWith({
    String? area,
    DateTime? date,
    String? weatherText,
    String? weatherImageUrl,
    AsyncValue? resultOfChatGPT,
    AsyncValue? resultOfDallE,
  }) {
    return ChatGPTRequestState(
      area: area ?? this.area,
      date: date ?? this.date,
      weatherText: weatherText ?? this.weatherText,
      weatherImageUrl: weatherImageUrl ?? this.weatherImageUrl,
      resultOfChatGPT: resultOfChatGPT ?? this.resultOfChatGPT,
      resultOfDallE: resultOfDallE ?? this.resultOfDallE,
    );
  }
}

@riverpod
class ChatGPTRequest extends _$ChatGPTRequest {
  // Services
  late final ChatGPTService _chatGPTService;
  late final DalleService _dalleService;
  
  // アプリケーションのデフォルト値
  static const String _defaultArea = "東京";

  bool _isEnvLoaded = false; // .env のロード状態を管理
  
  // `.env` のロードを確実に1回だけ実行
  Future<void> ensureEnvLoaded() async {
    if (!_isEnvLoaded) {
      await dotenv.load(fileName: ".env");
      _isEnvLoaded = true;
    }
  }
  
  // 初期状態を作成する専用メソッド
  ChatGPTRequestState _createDefaultState() {
    return ChatGPTRequestState(
      area: _defaultArea,
      date: DateTime.now(),
    );
  }

  @override
  Future<ChatGPTRequestState> build() async {
    // Initialize services
    _chatGPTService = ChatGPTService();
    _dalleService = DalleService();
    
    // 環境変数の読み込みを確実に行う
    await ensureEnvLoaded();
    
    // 初期状態を作成
    final initialState = _createDefaultState();
    
    // データ取得と状態更新を行う共通メソッドを呼び出す
    return _fetchWeatherData(initialState);
  }

  // エリアを更新
  void updateArea(String newArea) {
    // 現在の状態を取得
    final currentState = state.valueOrNull;
    if (currentState != null) {
      // 新しい状態を作成
      final newState = currentState.copyWith(area: newArea);
      // 状態を更新
      state = AsyncValue.data(newState);
    }
  }

  // 日付を更新
  void updateDate(DateTime newDate) {
    // 現在の状態を取得
    final currentState = state.valueOrNull;
    if (currentState != null) {
      // 新しい状態を作成
      final newState = currentState.copyWith(date: newDate);
      // 状態を更新
      state = AsyncValue.data(newState);
    }
  }
  
  // データ取得の共通ロジック
  Future<ChatGPTRequestState> _fetchWeatherData(ChatGPTRequestState baseState) async {
    try {
      // APIからデータを取得
      final chatGPTFuture = _chatGPTService.fetchWeatherForecast(
        baseState.area, 
        baseState.date.toString()
      );
      
      final dallEFuture = _dalleService.fetchWeatherImage(
        baseState.area, 
        baseState.date.toString()
      );
      
      final results = await Future.wait([chatGPTFuture, dallEFuture]);
      
      // 結果を反映した状態を返す
      return baseState.copyWith(
        weatherText: results[0],
        weatherImageUrl: results[1],
      );
    } catch (e) {
      // エラーが発生した場合は再スロー
      rethrow;
    }
  }

  // 天気データを更新するメソッド
  Future<ChatGPTRequestState> refreshWeatherData() async {
    // 明示的にloading状態に設定
    state = const AsyncValue.loading();
    
    try {
      // 環境変数の読み込みを確実に行う
      await ensureEnvLoaded();
      
      // 最後に保存された状態またはデフォルト値を使用（万が一のフォールバック）
      final currentState = state.valueOrNull ?? _createDefaultState();
      
      // データ取得と状態更新を行う共通メソッドを呼び出す
      final newState = await _fetchWeatherData(currentState);
      
      // 状態を明示的に更新
      state = AsyncValue.data(newState);
      return newState;
    } catch (e, stackTrace) {
      // エラーが発生した場合
      state = AsyncValue.error(e, stackTrace);
      return state.valueOrNull ?? _createDefaultState();
    }
  }
}
```

## Next Steps for Clean Architecture Implementation

After completing Phase 1, you'll have a more modular codebase that's easier to refactor into a Clean Architecture structure. The next steps would involve:

1. Creating the domain layer with entities and use cases
2. Implementing the data layer with repositories and data sources
3. Refactoring the presentation layer to use the domain layer
4. Setting up proper dependency injection

Each of these steps is detailed in Phase 2 of the roadmap.

## Benefits of This Approach

1. **Incremental Improvement**: You can make changes gradually without breaking existing functionality
2. **Maintainability**: Clear separation of concerns makes the code easier to understand and maintain
3. **Testability**: Proper abstractions make it easier to write unit tests
4. **Scalability**: The architecture can easily accommodate new features
5. **Learning**: You'll gain practical experience with Clean Architecture principles

## Pragmatic Considerations

While Clean Architecture provides many benefits, it's important to apply it pragmatically:

1. **Avoid Over-Engineering**: For simpler features, a full Clean Architecture implementation might be excessive
2. **Balance Abstraction**: Too many abstractions can make the code harder to understand
3. **Focus on Business Logic**: Apply the most rigorous architecture to your core business logic
4. **Adapt to Your Needs**: Modify the architecture to suit your specific requirements

By following this roadmap, you'll be able to refactor your application to follow Clean Architecture principles while maintaining its functionality and learning valuable software design skills.