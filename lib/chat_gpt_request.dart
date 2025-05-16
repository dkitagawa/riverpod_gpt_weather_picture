import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

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
  // OpenAI API関連の定数
  static const String _apiDomain = 'api.openai.com';
  
  // ChatGPT関連の定数
  static const String _apiPathChatGpt = 'v1/chat/completions';
  static const String _apiModelChatGpt = 'gpt-4o';
  
  // DALL-E関連の定数
  static const String _apiPathDalle = 'v1/images/generations';
  static const String _apiModelDalle = 'dall-e-3';
  
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

  Future fetchFromChatGPT(String area, String date) async {
    final String apiKey = _getApiKey();

    final prompt = "$areaの、$dateの天気予報、最高／最低気温、降水確率を簡潔に教えて下さい。";

    http.Response response = await http.post(  // APIリクエスト
      Uri.https(_apiDomain, _apiPathChatGpt),
      headers: _createHeaders(apiKey),
      body: jsonEncode(<String, dynamic>{
        // モデル
        "model": _apiModelChatGpt,
        // 指示メッセージ
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
      }),
    );

    if (response.statusCode == 200) {
      String responseData = utf8.decode(response.bodyBytes).toString();
      final responseJsonData = jsonDecode(responseData);
      final responseMessage = responseJsonData['choices'][0]['message']['content'];
      return responseMessage;
    } else {
      throw Exception('Failed to load sentence on $_apiModelChatGpt : ${response.statusCode}');
    }
  }

  Future fetchFromDallE(String area, String date) async {
    final String apiKey = _getApiKey();

    var prompt = "対象地域：$area。対象日付：$date。指定された地域の、指定された日付の天気予報を表現する画像を生成してください。【コンセプト】空撮ではなく地上に立つ人間の視点で対象地域を天気予報の通りの状態で描きます。対象地域のシンボリックな建物・名産品・名物・人間を盛り込み、マンガか映画の有名なシーンを大胆にオマージュしてください。人物が後ろ姿にならないよう注意して、生き生きとした人物の表情や活動をダイナミックに描くことを出力するイメージ全体の最優先事項としてください。【各情報の表示サイズ】情報の表示サイズは以下の順：地域名>>日付（MM/dd形式に変換して表示）>>>>>>>>>>>>対象日付の最高／最低気温と降水確率";

    //imageUrlからのコピーコード
    http.Response response = await http.post(  // APIリクエスト
      Uri.https(_apiDomain, _apiPathDalle),
      headers: _createHeaders(apiKey),
      body: jsonEncode(<String, dynamic>{
        // モデル
        "model": _apiModelDalle,
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
      return imageUrl;
    } else {
      throw Exception('Failed to load sentence on $_apiModelDalle : ${response.statusCode}');
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

  // APIキーの取得と検証
  String _getApiKey() {
    final String apiKey = dotenv.env['API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw _createApiKeyException();
    }
    return apiKey;
  }

  // APIキーが空の場合の例外
  Exception _createApiKeyException() {
    return Exception('API_KEY is missing or empty. Please check your .env file.');
  }

  // HTTPヘッダーの作成
  Map<String, String> _createHeaders(String apiKey) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }
}
