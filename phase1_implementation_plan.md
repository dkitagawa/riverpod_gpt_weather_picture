# Phase 1A-1 実装計画 - WeatherImage から開始

## 🎯 Task 1: WeatherImage責任明確化

### **現状分析**
```dart
// 現在のWeatherImage (lib/main.dart:70-91)
class WeatherImage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(chatGPTRequestProvider);
    
    return weatherState.when(
      data: (state) => state.weatherImageUrl.isNotEmpty
          ? Image.network(state.weatherImageUrl)
          : const Text('天気情報がありません'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('エラーが発生しました: $err'),
    );
  }
}
```

### **問題点**
1. **UI表示責任の混在**: 画像表示 + エラー表示 + ローディング表示が同一レベル
2. **エラーハンドリングの重複**: 他のウィジェットと同様のエラー表示ロジック
3. **責任境界不明確**: 「画像表示」の責任が曖昧

### **改善目標**
1. UI表示責任を「画像表示」のみに限定
2. エラー表示ロジックの統一化
3. ローディング表示の改善
4. コードコメントで責任範囲を明記

### **期待効果**
- **単一責任原則の体験**: 1つのウィジェットが1つの責任を持つ
- **保守性向上**: バグ修正・機能追加時の影響範囲明確化
- **再利用性向上**: 他の画面でも使用可能な汎用的なウィジェット

## 🚀 次のステップ

このTask 1完了後：
1. **動作確認**: 画像表示機能の正常動作確認
2. **コミット**: `refactor(ui): clarify WeatherImage widget responsibility`
3. **Task 2開始**: WeatherText責任明確化へ進行

## 📋 実装準備完了

codeモードで具体的なdiff提示と実装指導を開始します。