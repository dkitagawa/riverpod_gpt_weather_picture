# 🎯 技術的コンテクストと設計制約 - 別スレッド実装時の必須参照

## ⚠️ 重要：技術判断の背景と制約

このドキュメントは、別スレッドでの実装において、本スレッドで慎重に検討した技術的判断基準と設計制約が無視されることを防ぐための**技術的コンテクスト集**です。

## 🏗️ アーキテクチャ選択の確定事項

### **確定：MVVM + レイヤードアーキテクチャ採用**
```
❌ 提案禁止：Clean Architecture の全面採用
❌ 提案禁止：Hexagonal Architecture
❌ 提案禁止：DDD (Domain Driven Design)
✅ 確定採用：MVVM + Repository + 段階的Domain層追加
```

### **選択理由（変更不可）**
1. **学習適性**: 現在のRiverpodスキルレベルに最適
2. **市場価値**: 国内Flutter求人の85%がMVVM/レイヤード要求
3. **公式準拠**: Flutter 2024公式ガイドがMVVM推奨
4. **実装可能性**: Clean Architectureは概念的ハードル⭐⭐⭐⭐⭐で学習困難

## 📊 学習レベルに応じた実装制約

### **Phase 1: 絶対に導入してはならない概念**
- ❌ Domain Entity の完全な抽象化
- ❌ Repository Interface の複雑な継承構造
- ❌ Use Case の厳密な依存関係逆転
- ❌ DI Container (get_it等) の導入
- ❌ 複雑なState Management パターン

### **Phase 1: 導入すべき概念（段階的）**
- ✅ Repository Pattern の基本形
- ✅ Model クラスによるデータ構造化
- ✅ Riverpod による基本的な依存性注入
- ✅ 単一責任原則の実践レベル理解

### **学習難易度の上限設定**
```
Phase 1: ⭐⭐⭐ (現在のスキルレベル+1段階まで)
Phase 2: ⭐⭐⭐⭐ (Domain層追加、Interface基礎)
Phase 3: ⭐⭐⭐⭐ (テスト導入、モック活用)
Phase 4: ⭐⭐⭐⭐⭐ (Clean Architecture理論学習のみ)
```

## 🎯 具体的な実装レベル指針

### **Repository Pattern の実装レベル**
```dart
// ❌ 過度に抽象化（Clean Architecture的）
abstract class BaseRepository<T> {
  Future<Either<Failure, T>> execute<P>(P params);
}

// ✅ 適切なレベル（MVVM + Repository）
abstract class WeatherRepository {
  Future<String> getWeatherText(String area, DateTime date);
  Future<String> getWeatherImage(String area, DateTime date);
}

class WeatherRepositoryImpl implements WeatherRepository {
  // 具体的実装
}
```

### **State Management の実装レベル**
```dart
// ❌ 過度に複雑（Clean Architecture的）
@riverpod
class WeatherViewModel extends _$WeatherViewModel {
  WeatherViewModel(this._getWeatherUseCase, this._weatherStateMapper);
  // 複雑なUse Case注入
}

// ✅ 適切なレベル（MVVM）
@riverpod
class WeatherViewModel extends _$WeatherViewModel {
  WeatherViewModel(this._repository); // Repository直接注入
  // シンプルな構造
}
```

### **Error Handling の実装レベル**
```dart
// ❌ 過度に抽象化
sealed class Failure {
  const Failure();
}
class ServerFailure extends Failure {}
class NetworkFailure extends Failure {}

// ✅ 適切なレベル
class WeatherException implements Exception {
  final String message;
  final String? code;
  WeatherException(this.message, [this.code]);
}
```

## 🚫 設計判断での禁止事項

### **アーキテクチャレベル**
- ❌ Clean Architectureの同心円図の厳密な実装
- ❌ Domain層の完全な独立性（Phase 1-2では不要）
- ❌ Infrastructure層の完全分離（Phase 1-2では過剰）
- ❌ Application Service層の導入（複雑度過多）

### **実装パターンレベル**
- ❌ Factory Pattern の複雑な活用
- ❌ Strategy Pattern の抽象化
- ❌ Observer Pattern の手動実装（Riverpodで十分）
- ❌ Command Pattern の導入（Phase 1-2では不要）

### **テストレベル（Phase 3以降）**
- ❌ Architecture Test (import制約テスト) の導入
- ❌ Contract Test の実装
- ❌ Property-based Testing
- ❌ 過度なMock化（可読性を損なう）

## ✅ 各Phaseでの技術的到達目標

### **Phase 1: MVVM基礎**
```
到達目標：
- ViewModel と View の分離理解
- Repository Pattern の基礎実装
- Riverpod による簡単な依存性注入
- Model クラスによるデータ構造化

実装制約：
- Interface は最小限（WeatherRepository のみ）
- Entity/Model の区別は不要
- Use Case は未導入
```

### **Phase 2: レイヤード拡張**
```
到達目標：
- Domain層の基本的役割理解
- Use Case Pattern の基礎実装
- Repository Interface/Implementation 分離
- ビジネスロジックの適切な配置

実装制約：
- 依存関係逆転の完全適用は不要
- Entity は基本的データクラスレベル
- 複雑なDomain Service は不要
```

### **Phase 3: テスト導入**
```
到達目標：
- 各層の独立テスト手法
- モック活用の基礎
- テストピラミッドの実践
- リファクタリング支援としてのテスト理解

実装制約：
- 100%カバレッジは不要
- 複雑なテストダブルは避ける
- Integration Test は主要フローのみ
```

## 🎓 学習効果最大化のための制約

### **段階的複雑性の遵守**
```
Phase 1: 具体→抽象（Repository Pattern習得）
Phase 2: 分離→統合（Layer間責任理解）
Phase 3: 検証→改善（Test導入効果実感）
Phase 4: 比較→判断（Architecture選択基準）
```

### **実務適用性の優先**
- 国内Flutter案件での即戦力性重視
- 理論的完璧性より実装可能性優先
- チーム開発での保守性重視
- コードレビューしやすい設計優先

## 📋 技術選択での判断基準

### **ライブラリ選択基準**
```
採用OK：
- Riverpod/Flutter Hooks (公式推奨)
- HTTP package (標準)
- Mocktail (テスト用、シンプル)
- build_runner (コード生成用)

採用NG：
- get_it (DI Container - 複雑度過多)
- injectable (アノテーション複雑)
- dartz (Either型 - 学習コスト高)
- freezed (Phase 1-2では過剰)
```

### **設計パターン適用基準**
```
Phase 1適用OK：
- Repository Pattern (基礎レベル)
- Factory Constructor (基本的なもの)
- Singleton (Provider経由で)

Phase 1適用NG：
- Abstract Factory
- Builder Pattern (複雑なもの)
- Decorator Pattern
- Adapter Pattern (必要性が低い)
```

## ⚠️ 別スレッド実装時の必須チェック

実装提案前に必ず確認：

- [ ] 提案する実装は学習レベル上限（⭐⭐⭐）を超えていないか
- [ ] Clean Architecture要素を過度に取り入れていないか
- [ ] 実務での即戦力性を損なう理論的実装になっていないか
- [ ] 現在のPhaseで必要のない抽象化を行っていないか
- [ ] 国内Flutter市場での価値を考慮した提案か

## 🚨 このコンテクストを無視した場合

1. **学習効果の大幅減少**（理解困難な実装）
2. **実務適用性の喪失**（市場価値のない技術習得）
3. **プロジェクト失敗**（実装不可能な複雑度）
4. **時間の浪費**（本来の学習目標からの逸脱）

**技術的判断において、このコンテクストは最優先で考慮すること。**