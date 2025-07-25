# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 開発コマンド

### Python開発
- **コード整形**: `make format` (PythonとTerraformの両方を整形)
- **Python専用整形**: `make fmt-python` (ruffを使用してimport整理と整形)
- **リント**: `make lint` (PythonとTerraformの両方をリント)
- **Python専用リント**: `make lint-python` (ruffを使用してリント)
- **単体テスト実行**: `make test-unit` (pytestをテスト環境設定付きで実行)
- **特定テストファイル実行**: `uv run python -m pytest tests/unit/handlers/test_error_processor.py -v`
- **単一テスト実行**: `uv run python -m pytest tests/unit/handlers/test_error_processor.py::test_function_name -v`

### Terraform開発
- **Terraform整形**: `make fmt-terraform` (全Terraformモジュールを整形)
- **Terraformリント**: `make lint-terraform` (Terraformの整形をチェック)

### ローカル開発環境
- **LocalStack開始**: `make compose-up` (ローカルAWSサービスエミュレーション用LocalStackを開始)
- **LocalStack停止**: `make compose-down`

### 依存関係管理
- Pythonパッケージマネージャーとして`uv`を使用
- 依存関係は`pyproject.toml`の`[dependency-groups]`で定義
- ランタイム依存関係は最小限、開発依存関係にはAWS SDK、テストツール、リントツールを含む

## アーキテクチャ概要

CloudWatch Logsを監視し、EventBridge webhookを介してSlackに通知を送信するAWS Lambdaベースのエラー処理システム。

### 処理フロー
1. CloudWatch Logsからログイベントを受信
2. AWS Lambda Powertools形式の構造化ログを解析
3. エラー情報とスタックトレースを抽出
4. CloudWatch LogsとLambdaコンソールへのURLを生成
5. Slack通知用ブロック形式のペイロードを作成
6. EventBridgeに送信して非同期処理

### 主要コンポーネント

**エラープロセッサLambda** (`src/handlers/error_processor/`)
- CloudWatch Logsイベントを処理するメインハンドラー
- 構造化ログ（AWS Lambda Powertools形式）を解析
- CloudWatch LogsとLambdaコンソールURLを含むSlack通知ペイロードを作成
- 疎結合処理のためEventBridge経由で通知を送信

**ユーティリティモジュール** (`src/utils/`)
- `logger/`: 構造化ログと圧縮機能付きカスタムロガー
- `aws/`: AWSクライアント作成ユーティリティ
- `dataclasses/`: データクラス検証付き環境変数読み込み

**インフラストラクチャ** (`terraform_modules/`)
- 再利用可能なコンポーネントによるモジュラーTerraform設定
- `common/`: 共有AWSリソース（IAM、S3、SNS、CloudWatchなど）
- `lambda_function/`と`lambda_function_basic/`: Lambdaデプロイメントモジュール
- `events_slack_webhook_destination/`: EventBridge webhook設定

### 主要パターン

**構造化ログ**: 複雑なオブジェクトのカスタムJSONシリアライゼーション付きAWS Lambda Powertoolsを使用した一貫性のあるログ形式

**環境管理**: 型検証付きデータクラスベースの環境変数読み込み

**エラーハンドリング**: スタックトレース抽出機能付きCloudWatch Logsからの包括的なエラー解析

**イベント駆動アーキテクチャ**: 疎結合な通知配信のためEventBridgeを使用

**テスト**: AWSサービスモッキング用LocalStack、Lambdaコンテキストシミュレーション用pytestフィクスチャによる単体テスト
- テスト実行時は自動的にダミーAWS認証情報を設定（`AWS_ACCESS_KEY_ID=dummy`など）
- EventBridgeのテストにはLocalStackのエンドポイント（`http://localhost:4566`）を使用

## 開発ガイドライン

- Python 3.13+が必要
- 全Pythonコマンドに`uv run`プレフィックスを使用
- コミット前に全コード整形・リントが通過する必要がある
- テストではLocalStackを使用してAWS認証情報をモック
- Terraformモジュールは機能別に整理され、環境間で再利用される
