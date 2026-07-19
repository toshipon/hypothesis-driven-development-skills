# 学習記録: <タイトル>

<!-- /hdd:learn が仮説カード（docs/hypotheses/NNN-slug.md）の「検証結果（Verification Result）」セクションに
     この内容を反映し、docs/hypotheses/LEARNINGS.md に 1 行サマリーを追記する -->

---
hypothesis: <対象仮説カードへのパス。例: docs/hypotheses/007-xxx.md>
category: insight # validated | invalidated | insight | pattern | risk
decision: pause # persevere | pivot | kill | pause
date: <YYYY-MM-DD>
---

## 観測事実（Fact）

<!-- 解釈・意見を混ぜない。数値・発言・ログなど、実際に観測されたものだけを書く -->

- <例: LP 訪問者 320 人中 26 人が事前登録（CVR 8.1%）>
- <例: インタビュー 6 人中 5 人が「現状は Excel で手動集計している」と回答>

## 解釈（Interpretation）

<!-- 観測事実から導ける解釈。事実セクションと明確に分離する -->

- <例: 価格訴求より時短訴求の LP バリアントの方が反応が良かった>

## 判定（Judgment）

- 成功基準: <検証計画に記載した基準を転記>
- 結果: 支持 | 棄却 | 判定不能
- 判定理由: <基準と観測事実の照合結果を 1〜2 文で>

## 学び（Learning）

<!-- 1〜3 文。単なる結果の要約ではなく、次の仮説につながる形で書く -->

<本文>

**カテゴリ**: `validated` | `invalidated` | `insight` | `pattern` | `risk`

<!--
カテゴリの目安:
- validated:  対象仮説そのものが支持された
- invalidated: 対象仮説そのものが棄却された
- insight:    当落とは別に得られた想定外の発見
- pattern:    過去の学びと照合して見えた繰り返しの傾向
- risk:       今後の意思決定に影響しうるリスクの発見
-->

## 次のアクション（Next Action）

- **意思決定**: persevere（続行） | pivot（方向転換） | kill（中止） | pause（保留）
- **理由**: <1 文>
- **次に検証すべき仮説の種**（pivot / kill の場合）:
  1. <新しい仮説の種 1>
  2. <新しい仮説の種 2>

## 関連

- 対象仮説カード: <パス>
- 関連 issue: <番号 / URL>
- 参照した過去の学び: <LEARNINGS.md 内の関連行があればリンク>
