---
description: docs/hypotheses/ を走査して仮説ボードを表示する。ステータス別の一覧、検証期限超過の警告、直近の learning、検証待ちキューを表示する
argument-hint: "[省略可]"
---

# /hdd:status — 仮説ボード表示

`docs/hypotheses/` を走査し、現在の仮説の状態を一覧表示します。

## Step 1: 仮説カードの走査

`docs/hypotheses/*.md`（`README.md` と `LEARNINGS.md` を除く）を全て読み、各カードの frontmatter（`id` / `status` / `created` / `owner` / `related_issues`）と検証計画テーブルの「期限」「検証手法」、検証結果セクションの「実施日」を抽出する。

カードが 1 件も無い場合は「仮説カードがまだありません。`/hdd:grill` または `/hdd:issue` から始めてください」とだけ出力して終了する。

## Step 2: ステータス別集計

`status` ごとにグルーピングして件数と一覧を出す。

```markdown
## 仮説ボード（<件数> 件）

| status | 件数 |
|---|---|
| draft | n |
| verifying | n |
| validated | n |
| invalidated | n |
| withdrawn | n |
```

## Step 3: 期限超過の警告

`status: verifying` のカードのうち、検証計画テーブルの「期限」が本日（実行日）より過去のものを抽出し、レポート冒頭に警告として表示する。期限が 7 日以内に迫っているものは別枠で「まもなく期限」として警告する。

```markdown
### ⚠️ 期限超過（要判断: persevere / pivot / kill）

| カード | 期限 | 経過日数 | owner |
|---|---|---|---|
| 003-xxx.md | 2026-06-01 | 48 日 | @xxx |

### まもなく期限（7 日以内）

| カード | 期限 | owner |
|---|---|---|
| 007-xxx.md | 2026-07-24 | @xxx |
```

該当が無いセクションは表示しない。

## Step 4: 検証待ちキュー

以下のいずれかに該当するカードを「検証待ち」として一覧化する。

- `status: draft` かつ検証計画（検証方法・成功基準）が埋まっている（＝あとは着手するだけ）
- `status: verifying` だが検証結果の「実施日」が空欄（＝計画はあるが未着手）

```markdown
### 検証待ちキュー

| カード | 検証方法 | 期限 |
|---|---|---|
| 005-xxx.md | ファイクドアテスト | 2026-08-01 |
```

## Step 5: 直近の learning

`docs/hypotheses/LEARNINGS.md` が存在すれば末尾から直近 5 件を表示する。存在しなければ「learning の記録なし（/hdd:learn 未実行）」と表示する。

```markdown
### 直近の learning

- 2026-07-10 [validated] <1 行サマリー>（003-xxx.md）
```

## Step 6: トラッカー連携（利用可能な場合）

`docs/hypotheses/README.md` の設定でトラッカーが検出済みなら、各カードの `related_issues` に紐づくチケットの状態（open/closed 等）を取得して該当カードの行に併記する。トラッカーが markdown フォールバックの場合はこの Step をスキップする。

## 出力フォーマット（全体）

Step 3（該当があれば）→ Step 2 → Step 4 → Step 5 の順に結合し、1 つのレポートとして出力する。Step 6 の情報は各表に列を追加する形で反映する。
