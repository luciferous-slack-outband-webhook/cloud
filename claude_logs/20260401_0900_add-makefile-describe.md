# Makefile に describe コマンドを追加

## ユーザーのプロンプト（原文）

Makefileにdescribeというコマンドを作ってください。
`/SlackOutbandWebhook/Cloud/Outputs`というPrefixのSSM Parameterを取得して、Parameter NameとValueを表示してください。
AWS CLIで作ってください。

## 会話履歴（概要）

1. ユーザーから Makefile に describe コマンド追加の依頼
2. Makefile の既存構造を確認
3. 計画を作成（`--with-decryption` を含めていた）
4. ユーザーから `--with-decryption` は不要とのフィードバック
5. 計画を修正し、承認を得て実装

## 作業の理由

SSM Parameter Store の `/SlackOutbandWebhook/Cloud/Outputs` 配下のパラメータを簡単に確認できるようにするため。

## 計画内容

- Makefile に `describe` ターゲットを追加
- `aws ssm get-parameters-by-path` で指定プレフィックス配下のパラメータを再帰取得
- `--query` で Name と Value のみ抽出し、`--output table` でテーブル表示
- `.PHONY` に `describe` を追加

## 作業の内容

- `Makefile` に `describe` ターゲットを追加
- `.PHONY` リストに `describe` を追加
