# 003_create_dummy_function.md

## 概要

- バックエンドに使用するLambda FunctionのPythonコードを書いてください
  - 今回は正式な実装ではなく、ダミーとしてAPIが動くことを確認するための一時的なものです
- `src/handlers/subscription_to_outband/subscription_to_outband.py` というファイルに書いてください
- API GatewayのLambda統合Proxy V2形式で、JSON形式でLambdaに渡されたeventの中身を返してください


## 2025-09-19 00:37:30

### 作業内容

- `src/handlers/subscription_to_outband/` ディレクトリを作成
- `src/handlers/subscription_to_outband/subscription_to_outband.py` ファイルを作成
- API Gateway Lambda Proxy V2形式でeventの内容をJSON形式で返すダミー関数を実装
  - handler関数でeventをjson.dumps()してbodyに格納
  - statusCode: 200, Content-Type: application/jsonで返却

### 実装したファイル

- `src/handlers/subscription_to_outband/subscription_to_outband.py`
  - API動作確認用のダミーLambda関数
  - 受け取ったeventをそのままJSON形式で返す実装

