// =============================================================================
// ERROR MESSAGES
// =============================================================================
// This file contains user-friendly error messages for the application.
// These messages are designed to be more helpful to end users than
// technical error messages.

class ErrorMessages {
  // API error messages
  static const String apiConnectionError = "天気予報の取得に失敗しました。インターネット接続を確認してください。";  //Failed to get weather forecast. Please check your internet connection.
  
  static const String apiKeyMissingError = "アプリの設定が不完全です。管理者にお問合せください。";  //The app is not properly configured. Please contact the administrator.

  // ChatGPT specific errors
  static const String chatGptError = "天気予報テキストの生成に失敗しました。後でもう一度お試しください。";  //Failed to generate weather forecast text. Please try again later.

  // Dall-E specific errors
  static const String dalleError = "天気予報画像の生成に失敗しました。後でもう一度お試しください。";  //Failed to generate weather forecast image. Please try again later.
}
