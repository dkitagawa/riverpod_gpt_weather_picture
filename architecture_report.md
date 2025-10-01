以下、採用市場・学習コスト・保守性・テスト容易性・CI/CD 適合度を軸に MVVM／レイヤード／クリーンアーキテクチャを比較し、国内の実務事情を踏まえて最終提案をまとめました。

⸻

1 | 比較早見表（5 段階評価）

観点	MVVM	レイヤード（三層）	クリーンアーキテクチャ
学習コスト / 採用しやすさ	★★★★☆	★★★★☆	★★☆☆☆
国内エンジニア募集量*	★★★★☆	★★★★☆	★★☆☆☆
保守性（中長期）	★★★☆☆	★★★★☆	★★★★★
テスト容易性	★★★★☆	★★★★☆	★★★★★
初期実装速度	★★★★☆	★★★☆☆	★★☆☆☆
CI/CD 設計負荷	★★★★☆	★★★☆☆	★★☆☆☆
*Indeed の求人では MVVM/レイヤード（MVC/MVP 含む）の記載が多く、Clean は限定的（求人例に “MVVM / Clean Architecture の理解” と併記される程度） ￼。			


⸻

2 | 各アーキテクチャの実務検証

2-1 MVVM（＋Repository パターン）
	•	公式推奨に格上げ
2024 末に公開された Architecting Flutter apps ガイドは UI 層を MVVM 前提で解説。設計例・テスト例・DI 例までそろい、公式ドキュメントを教材にそのままレビュー基準を作れるのが強み。 ￼ ￼
	•	学習コスト低め × 採用市場広め
Android 経験者（Kotlin + MVVM）や iOS SwiftUI の ObservableObject 実務者が横展開しやすく、国内求人でも MVVM 経験が最も多い。 ￼
	•	テストと CI/CD
ViewModel は純 Dart で書けるためユニットテストが高速。Widget テストと組み合わせても 3 層で完結するので、CI 実行時間を抑えられる。 ￼
	•	弱点
ドメインロジックが肥大すると ViewModel が太りがち。Use-Case 層を後付けで挿し込む拡張余地を残す設計ガイドラインを事前に決めておく必要がある。

2-2 レイヤード（三層：Presentation / Domain / Data）
	•	現場で「暗黙のデフォルト」
Flutter でも従来ネイティブの流儀を引き継いだ三層構造が多く、「MVVM を Presentation 層で使い Domain を Service / Repository へ分離」という形で実装されがち。
	•	中庸な選択肢
Clean ほど厳密に依存逆転を徹底しなくても各層が分かれるので、ドメイン知識が散らばりにくい。CI/CD では層ごとにテストジョブを分割しやすく、ボイラープレートも過剰にならない。
	•	弱点
レイヤー間の依存方向を明文化せずコードレビューが甘いと「何でもあり」化して陳腐化する。静的解析ルール（import_lint, dart_code_metrics 等）でガードを推奨。

2-3 クリーンアーキテクチャ
	•	テストしやすさと長期保守の王道
ドメイン／アプリ／インフラ層を完全分離するため、仕様変更・テスト分離には最も強い。
	•	日本の Flutter 案件ではまだ少数派
ブログ記事でも「中小規模ならオーバースペック」と評されることが多く、学習コストの高さ・初期ボイラープレートが障壁になりやすい。 ￼
	•	採用上のリスク
Clean をフルで書ける Flutter エンジニアはまだ限られ、育成コスト or 高単価化は避けにくい。

⸻

3 | 最終提案 ― 「MVVM × レイヤード」を基盤に、必要に応じて段階的に Clean 要素を導入

フェーズ	推奨アプローチ	具体策
開発初期（スピード重視）	MVVM ＋ Repository	* Riverpod/Provider で DI* ViewModel に UI ロジック集約* repository_test.dart で DB/API をモック
機能増加・保守フェーズ	Domain/Use-Case 層を追加（Clean に近づける）	* 複数 Repository を組み合わせる処理は UseCase クラスへ分離* dart_code_metrics の architecture-checker を導入し、内→外への依存のみ許可
長期スケール	部分的 Clean 移行	* 複雑機能だけ Clean 同心円を採用し、その他は MVVM のまま* 技術負債の低減コストと開発速度を都度比較して判断

理由
	1.	採用とオンボーディングの効率
MVVM / 三層を経験している国内 Flutter 人材が最も多く、転職市場での充足率も高い（求人票記載量で裏付け）。スキルセットを合わせることで立ち上がりを短縮できる。 ￼
	2.	公式ドキュメントとの親和性
Flutter チーム自身が MVVM + Repository をケーススタディとして公開しており、コード規約・テスト戦略を転用しやすい。 ￼
	3.	漸進的な拡張
MVVM で始めてもドメイン層 (Use-Case) を後付け可能。中規模でスタートし、ユーザ数や機能が増えて複雑化した時点で「Clean へ一部改修」という段階的戦略が取れる。
	4.	CI/CD のバランス
レイヤード＋MVVM はユニット・Widget テスト比率が高く、モバイル CI のボトルネックであるエミュレータ依存テストを減らせる。
	5.	不要な過剰設計を避ける
クリーンアーキテクチャ全面採用は、少人数チームでは初期開発スピードを殺しやすい。学習・実装コストに見合うかはアプリのドメイン複雑度で判断し、現時点（中規模＆数名体制）では過剰。 ￼

⸻

4 | 実装時のチェックリスト
	1.	ディレクトリ標準化

lib/
  ui/        // View & Widgets
  viewmodel/ // State & logic
  domain/    // Optional UseCases（後付け）
  data/      // Repositories, DTO, DataSource


	2.	静的解析
	•	dart_code_metrics + import_lint で層間禁止依存のルールを CI に組み込む
	3.	テスト戦略
	•	ViewModel = 純 Dart ユニットテスト
	•	Repository = Mocktail で外部 IO をモック
	•	Golden / Integration テストは主要画面のみ自動化
	4.	CI/CD
	•	GitHub Actions で PR ごとに flutter test → Docker 上で flutter build apk --debug
	•	main ブランチマージ時に Firebase App Distribution + TestFlight へ自動配信
	5.	ドキュメントとリファクタ指針
	•	ADR（Architecture Decision Record）に「MVVM × Layered 基盤、ドメイン層は必要に応じ追加」と明文化
	•	3 か月ごとにリファクタ負債レビューを実施

⸻

結論

現状ベストは「MVVM を UI レイヤに採用し、Repository でデータ境界を切るレイヤード構成」。
小〜中規模チームでも立ち上げやすく、Flutter 公式と採用市場の両方に寄り添える。後に複雑度が増した部分だけ Clean 的レイヤを増設する漸進策で、過剰設計のリスクと長期保守コストのバランスを取るのが最も実務的です。