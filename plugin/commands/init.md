---
description: プロジェクトに Hypothesis-Driven Development (HDD) をセットアップする。仮説カードの保存先、チケットトラッカーの検出、GitHub issue テンプレートの設置までを行う
argument-hint: "[省略可。トラッカーを明示したい場合は 'github' / 'mcp' / 'markdown' を指定]"
---

# /hdd:init — HDD セットアップ

このプロジェクトに Hypothesis-Driven Development（HDD）の運用基盤を導入します。仮説カードの保存先を用意し、このプロジェクトで使えるチケットトラッカーを検出し、必要なら GitHub issue テンプレートを設置します。「$ARGUMENTS」でトラッカー種別が明示されている場合は、Step 3 の自動検出結果より優先してそれを使用します。

## 共通ルール

- **既存ファイルは上書きしない**。既にあるファイルは内容を読み、追加・変更したい差分を提示したうえで、更新するかどうかを AskUserQuestion ツールで確認してから書き込む
- このコマンドは何度実行しても安全（idempotent）にする。既にセットアップ済みの項目はスキップし、その旨を報告する

## Step 1: 既存セットアップの確認

以下のファイルの存在を確認する。

- `docs/hypotheses/README.md`
- `.github/ISSUE_TEMPLATE/hypothesis-driven.md`

両方が存在し「設定」セクションが埋まっていれば、セットアップ済みと判断し、トラッカー再検出や設定更新を行うかどうかを AskUserQuestion で確認する。ユーザーが「不要」を選んだら Step 2 以降をスキップして完了報告のみ行う。

## Step 2: 仮説カード保存先のセットアップ

`docs/hypotheses/` ディレクトリと `docs/hypotheses/README.md` を作成する（無ければ）。内容は次のテンプレートを使う。既存の README.md がある場合、「原則」「ファイル命名規則」「ステータス」「関連ファイル」セクションは変更せず、「設定」セクションのみ Step 6 で更新する。

```markdown
# 仮説ボード（docs/hypotheses/）

このディレクトリは Hypothesis-Driven Development（HDD）の仮説カードを保存する場所です。

## 原則

- 不確実性が高いものから検証する
- つくらずに学ぶ
- 学びを資産にする

## ファイル命名規則

- 仮説カードは `NNN-slug.md` の連番で保存する（例: `001-onboarding-friction.md`）
- NNN はこのディレクトリ内の既存カードの最大値 + 1（3 桁ゼロ埋め）
- slug は仮説を要約した kebab-case の英語
- カードの形式は hdd プラグインの仮説カードテンプレートに従う（/hdd:grill・/hdd:issue が自動生成するので手書きは不要）

## ステータス

各カードの frontmatter `status`:

| status | 意味 |
|---|---|
| draft | 仮説を記述中 |
| verifying | 検証実施中 |
| validated | 検証により支持された |
| invalidated | 検証により棄却された |
| withdrawn | 着手せず撤回 |

## 関連ファイル

- `LEARNINGS.md` — 学びの時系列インデックス（/hdd:learn が追記）

## 設定（/hdd:init が自動生成・更新。手動編集可）

- **チケットトラッカー**: 未検出（/hdd:init 未実行）
- **計測データソース**: 未検出
- **最終更新**: -
```

## Step 3: チケットトラッカーの検出

能力ベースで検出する。**特定プロダクトの API・ツール名をロジックにハードコードしない。**

1. **gh CLI**: `gh auth status` を実行する。終了コード 0 なら GitHub Issues が使用可能と判定し、`gh repo view --json nameWithOwner` などでリポジトリ名も記録する
2. **接続済み MCP ツール**: 自分（Claude）が現在呼び出せるツールの一覧を確認し、ツール名が `issue` / `ticket` / `backlog` / `hypothesis` / `verification` / `canvas` / `roadmap` / `learning` のいずれかを含むものを探す。該当があれば候補として記録する（例: `mcp__xxx__create_backlog_item` のような名前パターンにマッチするもの。提供元プロダクト名では判定しない）
3. どちらも見つからなければ「markdown ファイル」にフォールバックする（`docs/hypotheses/` 内で仮説カードとチケットを兼用する運用）

候補が複数見つかった場合（例: gh CLI と MCP の両方が使える）は、AskUserQuestion ツールで主として使うトラッカーをユーザーに選ばせる。

## Step 4: GitHub Issue テンプレートの設置提案

Step 3 で GitHub Issues が候補に入った場合のみ実施する。

1. `.github/ISSUE_TEMPLATE/hypothesis-driven.md` の存在を確認する
2. 無ければ、`${CLAUDE_PLUGIN_ROOT}/templates/github-issue-template.md` の内容をコピーして設置することを AskUserQuestion で提案する（選択肢: 「設置する」「今はしない」）
3. 既にある場合は内容を比較し、大きく乖離している場合のみ更新を提案する（軽微な差分では提案しない）

## Step 5: 計測データソースの簡易検出

詳細な計測基盤設計は `/hdd:data-infra` に譲るが、`docs/hypotheses/README.md` の設定欄に記録するため簡易検出だけ行う。

- 依存関係ファイル（`package.json` / `pubspec.yaml` / `requirements.txt` / `Gemfile` 等）を grep し、`analytics` / `amplitude` / `mixpanel` / `segment` / `posthog` / `google-analytics` / `firebase-analytics` 等のキーワードを探す
- `.env.example` やコード内の環境変数名から analytics 系のキーを探す
- 接続済み MCP ツールに `analytics` / `metric` / `report` 系の名前があれば記録する
- 見つかった場合はデータソース名を列挙する。見つからなければ「未検出（/hdd:data-infra で設計可能）」と記録する

## Step 6: 設定の反映

`docs/hypotheses/README.md` の「設定」セクションを、Step 3・Step 5 の結果と実行日で更新する（Edit ツール）。

## 完了報告フォーマット

```markdown
## HDD セットアップ完了

- 仮説カード保存先: docs/hypotheses/（新規作成 | 既存）
- チケットトラッカー: <検出結果>
- GitHub issue テンプレート: <設置した | 既存のまま | 対象外>
- 計測データソース: <検出結果>

### 次のステップ
1. `/hdd:grill` で最初の仮説を問い詰める
2. `/hdd:issue` で仮説付きチケットを作成する
```
