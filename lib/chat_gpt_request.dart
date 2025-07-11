// =============================================================================
// IMPORTS AND DEPENDENCIES
// =============================================================================
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'error_messages.dart';

part 'chat_gpt_request.g.dart';

// =============================================================================
// STATE MANAGEMENT
// =============================================================================
// ChatGPTRequestState represents the immutable state for weather data
// It contains area, date, weather text, image URL, and async results

class ChatGPTRequestState {
  final String area;
  final DateTime date;
  final String weatherText;
  final String weatherImageUrl;
  final AsyncValue? resultOfChatGPT;
  final AsyncValue? resultOfDallE;

  // Constructor with default values
  ChatGPTRequestState({
    required this.area,
    required this.date,
    this.weatherText = "初期化中…",
    this.weatherImageUrl = "",
    this.resultOfChatGPT,
    this.resultOfDallE,
  });

  // Immutable state update method that creates a new instance with updated values
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

// =============================================================================
// RIVERPOD PROVIDER
// =============================================================================
// ChatGPTRequest is a Riverpod provider that manages weather data fetching
// It handles API communication with OpenAI for both text and image generation
@riverpod
class ChatGPTRequest extends _$ChatGPTRequest {
  bool _isEnvLoaded = false; // .env のロード状態を管理
  // `.env` のロードを確実に1回だけ実行

  // =============================================================================
  // INITIALIZATION AND CONFIGURATION
  // =============================================================================
  
  // Ensures .env file is loaded only once
  Future<void> ensureEnvLoaded() async {
    if (!_isEnvLoaded) {
      await dotenv.load(fileName: ".env");
      _isEnvLoaded = true;
    }
  }
  
  // Creates default state with predefined values
  ChatGPTRequestState _createDefaultState() {
    return ChatGPTRequestState(
      area: defaultArea,
      date: DateTime.now(),
    );
  }

  // Initial build method called by Riverpod
  @override
  Future<ChatGPTRequestState> build() async {
    // 環境変数の読み込みを確実に行う
    await ensureEnvLoaded();
    
    // 初期状態を作成
    final initialState = _createDefaultState();
    
    // データ取得と状態更新を行う共通メソッドを呼び出す
    return _fetchWeatherData(initialState);
  }

  // =============================================================================
  // STATE UPDATE METHODS
  // =============================================================================
  
  // Updates the geographic area and refreshes state
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

  // Updates the date and refreshes state
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
  
  // =============================================================================
  // DATA FETCHING METHODS
  // =============================================================================
  
  // Core method to fetch weather data from both APIs
  Future<ChatGPTRequestState> _fetchWeatherData(ChatGPTRequestState baseState) async {
    try {
      // APIからデータを取得
      final chatGPTFuture = fetchFromChatGPT(baseState.area, baseState.date.toString());
      final dallEFuture = fetchFromDallE(baseState.area, baseState.date.toString());
      
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

  // Fetches weather text from ChatGPT API
  Future fetchFromChatGPT(String area, String date) async {
    final String apiKey = _getApiKey();
    final prompt = _createWeatherPrompt(area, date);

    try {
      http.Response response = await http.post(  // APIリクエスト
        Uri.https(apiDomain, apiPathChatGpt),
        headers: _createHeaders(apiKey),
        body: jsonEncode(_createChatGPTRequest(prompt)),
      );
      return _handleChatGPTResponse(response);
    } catch (e) {
      throw Exception(ErrorMessages.apiConnectionError);
    }
  }

  // Fetches weather image from DALL-E API
  Future fetchFromDallE(String area, String date) async {
    final String apiKey = _getApiKey();
    final prompt = _createImagePrompt(area, date);

    try {
      http.Response response = await http.post(  // APIリクエスト
        Uri.https(apiDomain, apiPathDalle),
        headers: _createHeaders(apiKey),
        body: jsonEncode(_createDallERequest(prompt)),
      );
      return _handleDallEResponse(response);
    } catch (e) {
      throw Exception(ErrorMessages.apiConnectionError);
    }
  }

  // Public method to manually refresh weather data
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

  // =============================================================================
  // API HELPER METHODS
  // =============================================================================
  
  // Retrieves and validates API key from environment variables
  String _getApiKey() {
    final String apiKey = dotenv.env['API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw _createApiKeyException();
    }
    return apiKey;
  }

  // Creates exception for missing API key
  Exception _createApiKeyException() {
    return Exception(ErrorMessages.apiKeyMissingError);
  }

  // Creates HTTP headers for API requests
  Map<String, String> _createHeaders(String apiKey) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  // =============================================================================
  // PROMPT GENERATION METHODS
  // =============================================================================
  
  // Creates prompt for weather text generation
  String _createWeatherPrompt(String area, String date) {
    return "$areaの、$dateの天気予報、最高／最低気温、降水確率を簡潔に教えて下さい。";
    }

  // Creates detailed prompt for weather image generation
  String _createImagePrompt(String area, String date) {
    return "対象地域：$area。対象日付：$date。指定された地域の、指定された日付の天気予報を表現する画像を生成してください。【コンセプト】空撮ではなく地上に立つ人間の視点で対象地域を天気予報の通りの状態で描きます。対象地域のシンボリックな建物・名産品・名物・人間を盛り込み、マンガか映画の有名なシーンを大胆にオマージュしてください。人物が後ろ姿にならないよう注意して、生き生きとした人物の表情や活動をダイナミックに描くことを出力するイメージ全体の最優先事項としてください。【各情報の表示サイズ】情報の表示サイズは以下の順：地域名>>日付（MM/dd形式に変換して表示）>>>>>>>>>>>>対象日付の最高／最低気温と降水確率";
  }

  // =============================================================================
  // REQUEST FORMATTING METHODS
  // =============================================================================
  
  // Creates properly formatted request body for ChatGPT API
  Map<String, dynamic> _createChatGPTRequest(String prompt) {
    return <String, dynamic>{
      "model": apiModelChatGpt,
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
  
  // Creates properly formatted request body for DALL-E API
  Map<String, dynamic> _createDallERequest(String prompt) {
    return <String, dynamic>{
      "model": apiModelDalle,
      "prompt": prompt,
      "n": 1,
      "size": "1024x1024",
      "quality": "standard"
    };
  }

  // =============================================================================
  // RESPONSE HANDLING METHODS
  // =============================================================================
  
  // Processes ChatGPT API response and extracts weather text
  String _handleChatGPTResponse(http.Response response) {
    if (response.statusCode == 200) {
      String responseData = utf8.decode(response.bodyBytes).toString();
      final responseJsonData = jsonDecode(responseData);
      final responseMessage = responseJsonData['choices'][0]['message']['content'];
      return responseMessage;
    } else {
      throw Exception(ErrorMessages.chatGptError);
    }
  }

  // Processes DALL-E API response and extracts image URL
  String _handleDallEResponse(http.Response response) {
    if (response.statusCode == 200) {
      String responseData = utf8.decode(response.bodyBytes).toString();
      final responseJsonData = jsonDecode(responseData);
      final imageUrl = responseJsonData['data'][0]['url'];
      return imageUrl;
    } else {
      throw Exception(ErrorMessages.dalleError);
    }
  }
}
