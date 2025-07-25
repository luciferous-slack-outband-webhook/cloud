# Terraform Modules

- Terraformのモジュール定義

## `terraform_modules/lambda_function_basic`

- Lambda関数を定義するためのTerraform Module
- Lambda関数とAlias, CloudWatch LogsのLogGroupを作成する
- LambdaのCPU ArchitectureはARMを使用する
- Lambda Layerとして、AWS Lambda Powertools for PythonのPublic Layerを使用する
- 明示的に指示しない限り、Claude Codeが編集することを禁じます

### `terraform_modules/lambda_function_basic/variables.tf`

このモジュールに設定しているvariables

- `s3_bucket_deploy_package`
  - type: string
  - required
  - Deploy Packageを置くS3 Bucketの名前
- `s3_key_deploy_package`
  - type: string
  - required
  - Deploy Packageを置くS3のKey
- `source_code_hash`
  - type: string
  - required
  - Deploy Packageのハッシュ値
  - `data "archive_file"`のoutput_base64sha256の値を使用する
- `identifier`
  - type: string
  - required
  - Lambda関数を識別するための識別子
- `system_name`
  - type: string
  - required
  - 作成しているSystem, プロダクトの名前
  - System, プロダクトを識別するのに使う
- `role_arn`
  - type: string
  - required
  - Lambda関数に渡すIAM RoleのARN
- `runtime`
  - type: string
  - default value: `python3.13`
  - Lambda関数のランタイム
- `handler`
  - type: string
  - required
  - Lambda関数のHandler
- `memory_size`
  - type: number
  - default value: 256
  - MB単位でLambda関数のメモリ量を指定する
- `layers`
  - type: list(string)
  - Lambad関数で使用するLambda LayerのARNを配列で渡す
  - 最大4個まで指定する
    - AWS Lambda Powertools for PythonのPublic Layerを最初から使用しているため
- `reserved_concurrent_executions`
  - type: number
  - Lambda関数に設定する 予約された同時実行数を指定する
- `region`
  - type: string
  - required
  - 使用するRegion
  - リソースの名前を作成する際に使用する
- `environment_variables`
  - type: map(string)
  - Lambda関数に設定する環境変数
- `alias`
  - type: string
  - Lambda関数に設定するAliasの名前を指定する

### `terraform_modules/lambda_function_basic/outputs.tf`

このモジュールに設定しているOutputs

- `function_name`
  - type: string
  - Lambda関数の名前
- `function_arn`
  - type: string
  - Lambda関数のARN
- `function_alias_name`
  - type: string
  - Lambda関数のAliasの名前
- `function_alias_arn`
  - type: string
  - Lambda関数のAliasのARN
- `log_group_name`
  - type: string
  - Lambda関数がログ出力するLogGroupの名前
- `log_group_arn`
  - type: string
  - Lambda関数がログ出力するLogGroupのARN

## `terraform_modules/lambda_function`

- Lambda関数を定義しながらエラー通知の設定も同時に行うモジュール
- Lambda関数の定義には、理由がなければこっちを使用する
- `terraform_modules/lambda_function_basic`モジュールのラッパーとして実装
  - `terraform_modules/lambda_function_basic`のモジュールのvaribales.tfをほぼ踏襲
  - エラー通知用のLambda関数のARNを追加している
  - Outputは `terraform_modules/lambda_function_basic`と同じ
- エラー通知はLogGroupに対してSubscription Filterを設定し、エラーログを処理用のLambda関数に渡す
- 明示的に指示しない限り、Claude Codeが編集することを禁じます

### `terraform_modules/lambda_function/variables.tf`

このモジュールで追加されたVariableのみ記載。
他のVariablesは `terraform_modules/lambda_function_basic`と同じ。

- `subscription_destination_lambda_arn`
  - type: string
  - required
  - エラー処理用のLambda関数のARN
  - LogGroupのSubscription FilterのDestinationに設定する

### `terraform_modules/lambda_function/outputs.tf`

定義内容は `terraform_modules/lambda_function_basic`と同じ

## `terraform_modules/events_slack_webhook_destination`

- Slack通知のためのリソースを定義するモジュール
- SlackのIncoming Webhookに、EventBridgeのAPI Destinationを使用して投げる
- 指定したEventBusにSlackにPostするメッセージを投入し、それを検知してAPI Destinationを動かす
- Slackに投げるメッセージはBlockの使用を前提としている
- 明示的に指示しない限り、Claude Codeが編集することを禁じます

### `terraform_modules/events_slack_webhook_destination/variables.tf`

- `event_bus_name`
  - type: string
  - required
  - Slackへの通知内容を流してもらうEventBus
- `iam_role_arn`
  - type: string
  - required
  - `aws_cloudwatch_event_target`に渡すIAM RoleのARN
  - API Destinationを動かすための権限を付与する必要がある
- `connection_arn_slack_dummy`
  - type: string
  - required
  - API Destinationに渡すConnection
  - SlackのIncoming Webhookでは認証が必要ないため本来は必要ないが、API Destinationでは必須になるためダミーの値を設定する
- `slack_incoming_webhook_url`
  - type: string
  - required
  - SlackのIncoming WebhookのURL
- `api_destination_name`
  - type: string
  - required
  - API Destinationリソースに設定する名前

## `terraform_modules/common`

- AWSのリソースを定義するモジュール
- このモジュールを更新して、AWSのリソースを管理していく
  - 他の上記モジュールをこのcommonモジュールで使っていくイメージ
- 基本的にAWSのサービス毎にtfファイルを分ける
- VariablesはRootモジュールから受け取る値
  - 内部で使い回す値はLocalsを使用する

### `terraform_modules/common/variables.tf`

- `system_name`
  - type: string 
  - required
  - 作成しているSystem, プロダクトの名前
  - System, プロダクトを識別するのに使う
- `region`
  - type: string
  - required
  - 使用するRegion
  - リソースの名前を作成する際に使用する
- `slack_incoming_webhook_error_notifier_01`
  - type: string
  - required
  - Lambda関数のエラー通知に使用するSlackのIncoming WebhookのURL