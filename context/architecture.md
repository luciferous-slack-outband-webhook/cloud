# アーキテクチャ

## 技術スタック

- Python 3.13
  - モジュール管理にはuvを使用する
  - ソースコードは `src/` ディレクトリに置く
    - この中身は全てLambdaのDeploy Packageに含める
- タスクランナーにはMakefileを使用する
  - PythonのLinterとFormatterにはruffを使用する
- バックエンドはAWSにデプロイする
- IaCにはTerraformを使用する
  - ソースコードは次の二つに置く
    - `terraform.tf`: Terraformのルートモジュール
    - `terraform_modules/`: Terraformのモジュールを定義している
- CDにはGithub Actionsを使用する
  - こちらは自分で書く
  - Claude Codeでは書かないでください
    - 明示的に編集を依頼したときのみ編集してください

## AWS

- Regionはap-northeast-1を使う
- API GatewayとLambdaで処理をする
  - HTTP APIを使用する
  - Slack AppのEvent Subscriptionで受け取ったデータをそのまま転送する
- DynamoDBに転送先に関するデータを置く
  - idはUUIDを使用する
  - 検索ではScanを使用し、FilterExpressionで絞り込む

## 使用ライブラリ

### Lambda

- AWS Lambda Powertools
  - 公式で用意されているLambda Layerを使用する
  - このライブラリの情報はcontext7を使用して検索する
    - `context7CompatibleLibraryID`: `/aws-powertools/powertools-lambda-python`
- Boto3
  - LambdaのPython Runtimeにはじめから含まれているものを使用する
  - このライブラリの情報はcontext7を使用して検索する
    - `context7CompatibleLibraryID`: `/boto/boto3`
- boto3-stubs
  - boto3の型アノテーションに使用する
  - このライブラリの情報はWeb検索で行う
- pydantic (& pydantic-settings)
  - AWS Lambda Powertoolsと一緒にインストールされるライブラリ
  - Pythonの標準ライブラリのdataclassの代わりに使用する
  - 環境変数の取得には pydantic-settingsを使用する
  - このライブラリの情報はcontext7を使用して検索する
    - pydantic
      - `context7CompatibleLibraryID`:
        - `/context7/pydantic_dev` (こっちの方が豊富なコードと高い信頼スコア)
        - `/pydantic/pydantic` (公式リポジトリベースのドキュメント)
    - pydantic-settings
      - `context7CompatibleLibraryID`: `/pydantic/pydantic-settings`

### Terraform

- AWS Provider
  - 公式で提供されているものを使用する
  - このライブラリの情報はcontext7を使用して検索する
    - `context7CompatibleLibraryID`: `/hashicorp/terraform-provider-aws`

## タスクランナー

- Makefileで定義する
- 自分で書くのでClaude Codeは編集しないでください
  - 明示的に編集を依頼したときのみ編集してください

### 定義済みタスク

- `make fmt-python`
  - Pythonのコードをフォーマットする
- `make fmt-terraform`
  - Terraformのコードをフォーマットする