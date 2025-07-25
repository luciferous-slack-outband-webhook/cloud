# Pythohn Modules

- 事前に定義しているPythonのモジュールやコード
- 明示的に指示しない限り、編集を行わないでください

## `src/utils/aws`

- boto3のClientやService Resourceを作成する関数を定義している

### `from utils.aws import create_client` (`src/utils/aws/aws.py:15-19`)

- boto3のClientを作成する関数
- 第一引数でAWSのサービスネームを渡す

### `from utils.aws import create_resource` (`src/utils/aws/aws.py:22-28`)

- boto3のServiceResourceを作成する関数
- 第一引数でAWSのサービスネームを渡す

## `src/utils/logger`

- Lambda用のロガーを独自に拡張している
- ベースにはAWS Lambda Powertools for Pythonのロガーを使用している、

### `from utils.logger import create_logger` (`src/utils/logger/create_logger.py:44-47`)

- Loggerインスタンスを生成する関数
- 第一引数にロガーの名前を入れる
  - ここには原則 `__name__`を入れる
    - どのファイルのログかどうかを識別するため

### `from utils.logger import logging_function` (`src/utils/logger/logging_function.py:9-68`)

- 関数の開始と終了をロギングするためのデコレーター
- 第一引数にロガーのインスタンスを渡す
- 名前付き引数で挙動を制御する
  - `write`
    - type: `bool`
    - default value: `False`
    - ログ出力するかしないかのフラグ
    - エラー時には、Falseにしていてもログ出力を行う
  - `with_return`
    - type: `bool`
    - default value: `False`
    - 関数終了時のログに関数の返値を含めるかどうかのフラグ
  - `with_args`
    - type: `bool`
    - default value: `False`
    - ログ出力に引数を含めるかどうかのフラグ
    - エラー時には、Falseにしていても含める

### `from utils.logger import logging_handler` (`src/utils/logger/logging_handler.py:21-59`)

- LambdaのHandlerに設定する関数のためのデコレーター
- 機能
  - 環境変数やHandlerに渡されたEventをログ出力する
  - エラー時にはエラーログを出力する
- 第一引数にロガーのインスタンスを渡す
- 名前付き引数で挙動を制御する
  - `with_return`
    - type: `bool`
    - default value: `False`

## `src/handlers/error_processor/error_processor.py`

- Lambda関数のエラー通知用のLambda関数
- LogGroupのSubscription FilterのDestinationに設定するLambda関数
- Slack通知用にBlockを組み立て、JSON文字列にしてEventBridgeのEventBusに流す
