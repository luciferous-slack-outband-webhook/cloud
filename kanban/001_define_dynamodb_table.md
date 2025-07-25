# 001_define_dynamodb_table

## 概要

- SSM Parameterの名前とSlackのchannelの組のデータを保存するTableを作成する

---

## 作業ログ

### 2025-07-25
- DynamoDBテーブル定義完了
- ファイル作成: `terraform_modules/common/dynamodb.tf`
- テーブル名: `{system_name}-slack-outband-webhook-mapping`
- スキーマ:
  - Primary Key: `pairId` (String)
  - GSI: `slackIdentifier-index` (slackIdentifier as Partition Key)
  - 属性: pairId, slackIdentifier, ssmParameterName
- オンデマンド課金、GSI全属性投影で設定
- tags設定を削除（ルートモジュールのdefault_tagsで設定されるため）