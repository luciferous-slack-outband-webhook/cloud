# Architecture

## 概要

Lambda関数のエラーログをCloudWatch Logsから取得し、整形してSlackへ通知するエラー監視・通知システム。
加えて、サブスクリプション管理用のパブリックHTTPエンドポイントを提供する(開発中)。

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| 言語 | Python 3.14 |
| クラウド | AWS (ap-northeast-1) |
| IaC | Terraform 1.9+ |
| AWSサービス | Lambda, CloudWatch Logs, EventBridge, SNS, S3, SSM Parameter Store, IAM |
| Pythonライブラリ | AWS Lambda Powertools v3.25.0, boto3 |
| パッケージ管理 | uv |
| CI/CD | GitHub Actions |
| ローカルテスト | Docker Compose + LocalStack |

## ディレクトリ構成

```
.
├── src/
│   ├── handlers/
│   │   ├── error_processor/              # CloudWatch Logs → Slack通知
│   │   │   └── error_processor.py
│   │   └── subscription_to_outband/      # HTTPエンドポイント (開発中)
│   │       └── subscription_to_outband.py
│   └── utils/
│       ├── aws/                          # boto3クライアント/リソース生成
│       ├── dataclasses/                  # 環境変数のデータクラス読み込み
│       └── logger/                       # ロギングユーティリティ・デコレータ
├── tests/unit/                           # ユニットテスト (pytest)
├── terraform_modules/
│   ├── common/                           # メインインフラ定義
│   ├── lambda_function_basic/            # Lambda基本デプロイモジュール
│   ├── lambda_function/                  # Lambda拡張モジュール (ログサブスクリプション付き)
│   └── events_slack_webhook_destination/ # EventBridge → Slack連携
├── terraform.tf                          # ルートTerraform設定
├── Makefile                              # 開発コマンド
├── pyproject.toml                        # Python依存関係・テスト設定
└── docker-compose.yml                    # LocalStack設定
```

## Lambda関数

### error_processor

CloudWatch Logsのサブスクリプションフィルタ経由で呼び出され、エラーログをSlack用に整形してEventBridgeへ送信する。

- **ハンドラ:** `handlers/error_processor/error_processor.handler`
- **ランタイム:** Python 3.14 (ARM64)
- **メモリ:** 256 MB / **タイムアウト:** 120秒

**主な処理:**
1. CloudWatch Logsイベントをgzip解凍・Base64デコード
2. ログメッセージからエラー詳細(メッセージ、リクエストID、スタックトレース)を抽出
3. Slackブロック形式のペイロードを生成(Lambdaコンソール・CloudWatch Logsへの直リンク付き)
4. EventBridgeへイベントを送信(10件ずつバッチ処理)

### subscription_to_outband

パブリックHTTPエンドポイント。Lambda Function URLで公開。現在はリクエストをエコーバックするテンプレート実装。

- **ハンドラ:** `handlers/subscription_to_outband/subscription_to_outband.handler`
- **認証:** なし (公開エンドポイント)
- **URL:** SSMパラメータ `/SlackOutbandWebhook/Cloud/Outputs/UrlSubscriptionToOutband` に格納

## データフロー

```
Lambda実行エラー
    ↓
CloudWatch Logs
    ↓
サブスクリプションフィルタ
  ({ $.level = "ERROR" } / タイムアウト / ImportModuleError)
    ↓
error_processor Lambda
    ↓
EventBridge (error_notifier バス)
    ↓
EventBridge APIデスティネーション + InputTransformer
    ↓
Slack Incoming Webhook → Slackチャンネル
```

## Terraformモジュール構成

### common

メインインフラを定義。Lambda関数、IAMロール、EventBridge、S3、CloudWatch、SNS、SSMを管理。

### lambda_function_basic

Lambda関数の基本デプロイ単位。関数本体、CloudWatch Log Group (14日保持)、エイリアスを作成。
AWS Lambda Powertools レイヤーを共通で付与。

### lambda_function

`lambda_function_basic`をラップし、CloudWatch Logsサブスクリプションフィルタ(ERRORログ・予期しないエラー)を追加。
エラーログをerror_processorへルーティングする。

### events_slack_webhook_destination

EventBridgeルール + APIデスティネーションでSlack Webhookへイベントを送信。
InputTransformerで`detail.blocks`フィールドをSlack形式に変換。

## IAMロール

| ロール | 信頼先 | 権限 |
|---|---|---|
| error_processor用 | Lambda | CloudWatch Logs基本 + EventBridge PutEvents |
| subscription_to_outband用 | Lambda | CloudWatch Logs基本のみ |
| EventBridge → APIデスティネーション用 | EventBridge | APIデスティネーション呼び出し |

## ユーティリティ

### ロガー (`src/utils/logger/`)

- AWS Lambda Powertoolsベースの構造化JSON logging
- `@logging_handler` : Lambdaハンドラ用デコレータ (イベント・例外のログ出力)
- `@logging_function` : 一般関数用デコレータ (実行時間の計測)
- カスタムJSONシリアライザ (dataclass, bytes, Decimal, Pydantic等対応)

### 環境変数ローダー (`src/utils/dataclasses/`)

データクラスの型定義に基づいて環境変数を自動読み込みする `load_environments()` 関数。

### AWSクライアント (`src/utils/aws/`)

boto3クライアント/リソースのファクトリ。デフォルトタイムアウト5秒、標準リトライモード。

## CI/CD

**トリガー:** masterブランチへのプッシュ、またはタグ (v*) のプッシュ

| ステップ | 内容 |
|---|---|
| plan | 全プッシュで `terraform plan` を実行 |
| apply | タグプッシュ時のみ `terraform apply -auto-approve` を実行 |

AWS認証はOIDC (GitHub Actions → IAMロール) を使用。

## 監視

- **CloudWatch Alarm:** error_processor Lambdaのエラー数 > 0 で発火
- **SNS通知:** アラーム発火時にSNSトピック `catch_error_lambda_error_processor` へ通知
- **ログ保持:** 全Lambda関数のログを14日間保持

## 開発コマンド (Makefile)

| コマンド | 内容 |
|---|---|
| `make format` | Terraform + Pythonコードフォーマット |
| `make lint` | isort + black によるリント |
| `make test-unit` | pytestによるユニットテスト実行 |
| `make compose-up/down` | LocalStack起動/停止 |
| `make terraform-init` | Terraformバックエンド初期化 |
