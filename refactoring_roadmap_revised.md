# Simplified Refactoring Roadmap for Weather Picture App

## Step 1: Create constants.dart and Update chat_gpt_request.dart

### 1. Update `lib/constants.dart` to fix linting errors

The current implementation has linting errors related to constant naming conventions and documentation. Let's fix those:

```dart
// API関連の定数
// OpenAI APIとの通信に使用する定数を定義します。

// OpenAI API関連の定数
const String apiDomain = 'api.openai.com';

// ChatGPT関連の定数
const String apiPathChatGpt = 'v1/chat/completions';
const String apiModelChatGpt = 'gpt-4o';

// DALL-E関連の定数
const String apiPathDalle = 'v1/images/generations';
const String apiModelDalle = 'dall-e-3';

// アプリケーションのデフォルト値
const String defaultArea = "東京";
```

Changes made:
1. Changed the triple-slash comment (`///`) to a regular double-slash comment (`//`) to avoid the "dangling library doc comments" error
2. Renamed all constants to use lowerCamelCase instead of UPPER_SNAKE_CASE to follow Dart conventions:
   - `API_DOMAIN` → `apiDomain`
   - `API_PATH_CHAT_GPT` → `apiPathChatGpt`
   - `API_MODEL_CHAT_GPT` → `apiModelChatGpt`
   - `API_PATH_DALLE` → `apiPathDalle`
   - `API_MODEL_DALLE` → `apiModelDalle`
   - `DEFAULT_AREA` → `defaultArea`

### 2. Update `lib/chat_gpt_request.dart` to use the renamed constants

Now we need to update the chat_gpt_request.dart file to use these renamed constants:

```diff
@@ -1,6 +1,7 @@
 import 'package:riverpod_annotation/riverpod_annotation.dart';
 import 'package:flutter_dotenv/flutter_dotenv.dart';
 import 'dart:convert';
 import 'dart:async';
 import 'package:http/http.dart' as http;
+import 'constants.dart';  // 相対パスでインポート
 
 part 'chat_gpt_request.g.dart';
@@ -44,17 +45,6 @@
 
 @riverpod
 class ChatGPTRequest extends _$ChatGPTRequest {
-  // OpenAI API関連の定数
-  static const String _apiDomain = 'api.openai.com';
-  
-  // ChatGPT関連の定数
-  static const String _apiPathChatGpt = 'v1/chat/completions';
-  static const String _apiModelChatGpt = 'gpt-4o';
-  
-  // DALL-E関連の定数
-  static const String _apiPathDalle = 'v1/images/generations';
-  static const String _apiModelDalle = 'dall-e-3';
-  
-  // アプリケーションのデフォルト値
-  static const String _defaultArea = "東京";
 
   bool _isEnvLoaded = false; // .env のロード状態を管理
@@ -70,7 +60,7 @@
   // 初期状態を作成する専用メソッド
   ChatGPTRequestState _createDefaultState() {
     return ChatGPTRequestState(
-      area: _defaultArea,
+      area: defaultArea,
       date: DateTime.now(),
     );
   }
@@ -136,8 +126,8 @@
     final prompt = _createWeatherPrompt(area, date);
 
     http.Response response = await http.post(  // APIリクエスト
-      Uri.https(_apiDomain, _apiPathChatGpt),
+      Uri.https(apiDomain, apiPathChatGpt),
       headers: _createHeaders(apiKey),
       body: jsonEncode(_createChatGPTRequest(prompt)),
     );
 
@@ -150,8 +140,8 @@
 
     //imageUrlからのコピーコード
     http.Response response = await http.post(  // APIリクエスト
-      Uri.https(_apiDomain, _apiPathDalle),
+      Uri.https(apiDomain, apiPathDalle),
       headers: _createHeaders(apiKey),
       body: jsonEncode(_createDallERequest(prompt)),
     );
 
@@ -218,7 +208,7 @@
   //ChatGPTリクエストの作成
   Map<String, dynamic> _createChatGPTRequest(String prompt) {
     return <String, dynamic>{
-      "model": _apiModelChatGpt,
+      "model": apiModelChatGpt,
       "messages": [
         {
           "role": "user",
@@ -236,7 +226,7 @@
   //DALL-Eリクエストの作成
   Map<String, dynamic> _createDallERequest(String prompt) {
     return <String, dynamic>{
-      "model": _apiModelDalle,
+      "model": apiModelDalle,
       "prompt": prompt,
       "n": 1,
       "size": "1024x1024",
@@ -252,7 +242,7 @@
       final responseMessage = responseJsonData['choices'][0]['message']['content'];
       return responseMessage;
     } else {
-      throw Exception('Failed to load sentence on $_apiModelChatGpt : ${response.statusCode}');
+      throw Exception('Failed to load sentence on ${apiModelChatGpt} : ${response.statusCode}');
     }
   }
 
@@ -264,7 +254,7 @@
       final imageUrl = responseJsonData['data'][0]['url'];
       return imageUrl;
     } else {
-      throw Exception('Failed to load sentence on $_apiModelDalle : ${response.statusCode}');
+      throw Exception('Failed to load sentence on ${apiModelDalle} : ${response.statusCode}');
     }
   }
 }
```

## Implementation Steps

1. First, update the constants.dart file to use lowerCamelCase for constant names and regular comments
2. Then update chat_gpt_request.dart to use these renamed constants
3. Run the app to ensure everything works correctly
4. If everything works, commit the changes

## Next Steps

After implementing these changes and confirming they work, we'll move on to the next step: adding clear section comments to the existing files.

## Full Refactoring Plan (For Reference)

### Phase 1: Code Organization and Documentation

1. **Add Clear Section Comments**
   - Add detailed section comments in the existing files
   - Improve method documentation

2. **Extract Constants** (Current Step)
   - Create a simple `lib/constants.dart` file ✅
   - Move API-related constants from `chat_gpt_request.dart` to this file ✅
   - Update `chat_gpt_request.dart` to use these constants ⏳

3. **Improve Error Handling and Loading States**
   - Enhance error messages to be more user-friendly
   - Improve loading indicators for better user experience
   - Add proper error recovery mechanisms

### Phase 2: Gradual Component Extraction

1. **Create a Widgets File**
   - Create a single `lib/widgets.dart` file
   - Move widgets from `main.dart` to this file one at a time

2. **Create a Simple Service Layer**
   - Create a single `lib/services.dart` file
   - Extract API-related methods from `chat_gpt_request.dart`

### Phase 3: Basic Folder Structure (Optional)

1. **Create Basic Folders**
   - Create a minimal folder structure
   - Move files to appropriate folders

2. **Split Widget File (Optional)**
   - Split `widgets.dart` into individual files
   - Create a barrel file

3. **Split Services File (Optional)**
   - Split `services.dart` into individual files
   - Create a barrel file

### Phase 4: Simple Architecture Improvements (Optional)

1. **Introduce a Basic Repository**
   - Create a simple repository that sits between the UI and services

2. **Refine State Management**
   - Improve the Riverpod implementation with more focused providers