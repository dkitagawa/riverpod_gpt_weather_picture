// =============================================================================
// ERROR MESSAGES
// =============================================================================
// This file contains user-friendly error messages for the application.
// These messages are designed to be more helpful to end users than
// technical error messages.

import 'package:flutter/foundation.dart';

class ErrorMessages {
  // Network level errors
  static const String apiConnectionError = "天気予報の取得に失敗しました。インターネット接続を確認してください。";  //Failed to get weather forecast. Please check your internet connection.
  
  static const String apiKeyMissingError = "アプリの設定が不完全です。管理者にお問合せください。";  //The app is not properly configured. Please contact the administrator.

  // ChatGPT responce specific errors
  static const String chatGptError = "天気予報テキストの生成に失敗しました。後でもう一度お試しください。";  //Failed to generate weather forecast text. Please try again later.

  // Dall-E responce specific errors
  static const String dalleError = "天気予報画像の生成に失敗しました。後でもう一度お試しください。";  //Failed to generate weather forecast image. Please try again later.

  static String createDetailedError(String userMessage, dynamic technicalError) {
    if (kDebugMode) {
      // コンソール出力※ロギング用
      debugPrint('API Error Details: $technicalError');

      // 画面出力
      return '$userMessage\n\n[Debug Info]: $technicalError'; 
    }
    return userMessage; // プロダクションでは簡潔なメッセージのみ
  }

  // HTTP応答コード別の具体的メッセージ
  static String getHttpErrorMessage(int statusCode, String apiName) {
    switch (statusCode) {
      case 401:
        return 'APIキーの認証に失敗しました。設定を確認して下さい。';
      case 429:
        return 'API使用量の上限に達しました。後でお試し下さい。';
      case 500:
        return '$apiNameサービスに問題が発生しています。後でもう一度お試し下さい。';
      default:
        return '$apiName APIでエラーが発生しました。(HTTP $statusCode)';
    }
  }
}

