# specification

仕様を定義する。

## やりたいこと

- Slack AppのEvent Subscriptionsで受け取ったメッセージを指定したURLにPOSTし、転送する
- 指定したURLはDynamoDBとSSM Parametersに保存する
  - DynamoDBにはSlackのチャンネルとSSM Parameterの名前の組を保存する

## 概要

- Slack AppのEvent Subscriptionsで指定するAPIを作成する
- 転送先の情報についてはSSM Parameterに保存する
  - DynamoDBにはSlackのチャンネルとSSM Parameterの名前の組を保存する
- APIはLambda Function URLs

## Slack AppのEvent Subscriptionsで送信されるデータのPayloadサンプル

Event Subscriptionsでは二種類のデータが送信されるので、そのPayloadのサンプル

### `sample_data/slack_event_subscriptions/challenge_payload.json`

- Event Subscriptionsでデータ送信先として登録する際に、認証用に飛ばされるイベントサンプル
- challenge dataと呼称する

### `sample_data/slack_event_subscriptions/message_payload.json`

- Event Subscriptionsで送信されるデータのサンプル
- message dataと呼称する

## DynamoDB定義

### 概要

- SlackのチャンネルとSSM Parameterの名前の組を保存するためのTableを一つ作成する

### テーブル定義

- GSIを使用することを前提とする
  - 一つのキーで複数の値を取得できるため
- GSIでは全ての写像を作る
  - 1アイテムのサイズが大きくないため
- オンデマンドキャパシティを使用する

#### スキーマ定義
- `pairId`
  - type: string
  - Partition Key
  - uuidを使用する
    - v4を想定
  - SlackのチャンネルとSSM Parameterの名前の組を保持するために使用する
- `slackIdentifier`
  - type: string
  - GSIのPartition Key
  - `{team_id}:{channel}`という形式の文字列とする
    - `team_id`: message dataに含まれるSlackのteam_id (`$.teamId`)
    - `channel`: message dataに含まれるSlackのchannelのID (`$.event.channel`)
- `ssmParameterName`
  - type: string
  - uuidを使用する
    - v4を想定
  - 転送先のURLやヘッダーなどの情報を保存しているSSM Parameterの名前

## SSM Parameterに保存する値について

- 転送先についての情報を保存する
  - JSONテキストで保存する
- API Keyなどの秘匿情報も格納されるためSecure Stringを使用する
  - KMSのキーは独自では生成せず、AWSが持っているものを使用する

### 保存するJSONのスキーマ

JSON Schemaで下に定義する

```json
{
  "type": "object",
  "properties": {
    "url": {
      "type": "string",
      "pattern": "^http(s|):\/\/.+"
    },
    "method": {
      "type": "string",
      "enum": ["GET", "POST", "PUT"]
    },
    "headers": {
      "type": "object"
    }
  },
  "required": ["url", "method"],
  "additionalProperties": false
}
```

## Lambda関数の実装について

- 基本的にHTTPのStatus Codeは200を返す
  - 内部でエラーが起きたときはエラーログは出力する

### 処理フロー

1. AWS Lambda Powertools for Pythonのdata_classでbodyをdictで取得する
1. challenge dataかmessaeg dataかどうかを判定する
   - どちらでもない場合はエラーログを出力しつつ、HTTP STATUS CODE 200を返す
1. challenge dataならJSONで次のデータをHTTP STATUS CODE 200で返す
   - `challenge`
     - type: string
     - value: `$.challenge`
1. message dataからteam_idとchannelを取得する
1. team_idとchannelを使ってDynamoDBからSSM Parameterの名前を取得する
1. 名前を一件も取得できなかった場合、HTTP STATUS CODE 200を返す
1. 取得したSSM Parameterの名前のリストから重複を排除する
1. SSM Parameterの名前から値を取得し、message dataを転送先に投げる
1. HTTP STATUS CODE 200を返す

### 実装方法

#### main関数

- `logging_function`をデコレータとして使用してください
- 引数は`event: LambdaFunctionUrlEvent` (`from aws_lambda_powertools.utilities.data_class.lambda_function_url_event import LambdaFunctionUrlEvent`)
- 処理フローはmain関数の中で行う

#### handler

- Lambda関数のHandlerに指定する関数
- `logging_handler`をデコレーターで設定する
- AWS Lambda Powertools for Pythonのdata_classの `event_source`デコレーターを使用する
  - `@event_source(data_class=LambdaFunctionUrlEvent)` (`from aws_lambda_powertools.utilities.data_class import event_source`)
- main関数にeventを渡す
- handlerの中では、main関数を実行する
  - main関数の返値をhandlerの返値とする
- try-exceptの中でmain関数を実行する
  - `except Exception as e`とする
    - このときエラーログを投げつつ、 `{"message": "ok"}`を返す