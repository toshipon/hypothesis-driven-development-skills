# HDD — Hypothesis-Driven Development for Claude Code

プロダクト開発に**仮説検証を強制する** Claude Code プラグインです。feature 開発やチケット作成のたびに「その仮説は何か。どう検証するのか」を問い、仮説 → 検証 → 学習 → 意思決定のループをプロダクトチームの所作として定着させます。

対象は PdM とプロダクトエンジニア。特定のプロダクト管理ツールに依存せず、GitHub Issues / JIRA / Linear / 任意の MCP ツール / ただの markdown ファイルのどれでも動きます。

> **HDD (Hypothesis-Driven Development)** is a Claude Code plugin that forces hypothesis validation into your product development workflow. It interrogates your hypotheses before you build (`/hdd:grill`), gates ticket creation with a hypothesis-verification checklist (hooks + skills), and helps you design the data-collection infrastructure (read-only APIs / MCP servers) that lets AI agents verify outcomes autonomously. Tracker-agnostic: works with GitHub Issues, JIRA, Linear, any MCP tool, or plain markdown files.

## 思想

- **不確実性が高いものから検証する** — 一番怖い仮説を最初に潰す
- **つくらずに学ぶ** — 実装は最も高価な検証手段。作る前に安く検証する
- **学びを資産にする** — 検証結果は必ず learning として記録し、次の仮説につなげる

このプラグインは「検証していないなら作るな」とは言いません。「検証していないことを自覚し、記録し、計測を仕込んでから作れ」と言います。

## インストール

Claude Code 内で:

```
/plugin marketplace add toshipon/hypothesis-driven-development-skills
/plugin install hdd@hdd
```

または CLI から:

```bash
claude plugin marketplace add toshipon/hypothesis-driven-development-skills
claude plugin install hdd@hdd
```

## クイックスタート

```
/hdd:init          # プロジェクトに HDD をセットアップ（docs/hypotheses/ 作成、トラッカー検出）
/hdd:grill 新機能のアイデア   # 仮説を問い詰めて仮説カードに落とし込む
/hdd:issue         # 仮説・検証チェックリスト付きでチケット化
# ... 実装（計測イベントの仕込み込み）...
/hdd:verify        # 検証計画の設計・実施記録
/hdd:learn         # 結果から学習を記録し、persevere / pivot / kill / pause を判断
```

## コマンド

| コマンド | 説明 |
|---|---|
| `/hdd:init` | プロジェクトへのセットアップ。`docs/hypotheses/` の作成、トラッカー検出、GitHub issue テンプレートの設置 |
| `/hdd:grill` | 仮説の問い詰め。課題の実在性 → 解決策の妥当性 → 価値 → 検証計画の 4 フェーズで決定木に沿って質問し、仮説カードを完成させる |
| `/hdd:issue` | チケット作成。仮説・検証チェックリストを満たさないチケットはそのまま作らせない。Impact × Confidence × Risk ÷ Effort の優先度スコアで「本当に今やる価値があるか」も問う |
| `/hdd:audit` | 既存チケット/バックログの一括監査。仮説の無いチケットを検出し、仮説ドラフトの追記を提案 |
| `/hdd:verify` | 検証計画の設計。検証手法カタログから最小コストの手法を選定し、成功基準・撤退基準・計測方法を確定 |
| `/hdd:learn` | 検証結果の記録。validated / invalidated / insight / pattern / risk に分類し、次のアクションを判断 |
| `/hdd:data-infra` | 検証用データ収集基盤の設計。既存計測の調査 → ギャップ分析 → 段階的な整備提案（AI がデータを取れる read-only API / MCP サーバー化まで） |
| `/hdd:status` | 仮説ボード。全仮説のステータス、期限超過の警告、直近の学習を一覧表示 |

## 自動で働く仕組み（強制レイヤー）

コマンドを打たなくても、以下が自動で仮説検証を促します。

### Skills（文脈で自動適用）

| Skill | 発動条件 | 動作 |
|---|---|---|
| `hypothesis-first` | feature 追加・機能改善の実装依頼 | 実装前に仮説の有無を確認。無ければ検証を促し、最小検証案を提示。計測の仕込みをスコープに含める |
| `issue-hypothesis-gate` | あらゆる手段でのチケット作成 | 本文をチェックリストで検査し、仮説セクションの追記案を提示 |
| `verification-methods` | 検証手法の選定場面 | 9 つの検証手法カタログと選定マトリクスを提供 |
| `data-collection-design` | 計測・データ収集の設計場面 | イベント設計原則、指標ツリー、AI アクセス経路の設計パターンを提供 |
| `moat-test` | 新機能・新アイデア・プロダクト構想の評価、「これは Moat になるか」の問い | AI 時代の競争優位判定。Claude Test（3 か月でコピーできるか）→ Foundation Model Test（LLM が 10 倍賢くなったら価値が下がるか）→ Moat 7 源泉マップ → Outcome Data 設計 → System of Action での位置づけ → 断定しない出力か、を順に問い、Go / Kill ボードに貼れる形で出力する（[解説記事](https://zenn.dev/toshipon/articles/moat-test-skill-for-ai-era)） |

### Hooks（最終ライン）

`gh issue create` や MCP のチケット作成ツールの実行を検知し、本文に仮説セクション（仮説・検証方法・成功基準）が無ければ**ブロック**します。

- ユーザーが「仮説不要」と明示した場合は `[no-hypothesis]` マーカー付きで作成できます（判断の記録が残ります）
- 無効化: 環境変数 `HDD_HOOK_DISABLE=1`
- jq が無い環境では何もしません（フェイルオープン）

## 仮説の保存先

デフォルトはリポジトリ内の markdown で、外部サービスに依存しません。

```
docs/hypotheses/
├── README.md          # 運用ルールとプロジェクト設定（/hdd:init が生成）
├── LEARNINGS.md       # 学習の時系列インデックス
├── 001-onboarding-dropoff.md   # 仮説カード（課題/解決/価値仮説 + 検証計画 + 結果）
└── 002-....md
```

仮説検証系の MCP ツール（verification / hypothesis / learning 系のツールを持つプロダクト管理ツール。例: [KaizenLab](https://github.com/toshipon/kaizen-lab-plugin)）が接続されていれば、検出して併用します。

## データ収集基盤について

検証は計測できてはじめて成立します。`/hdd:data-infra` は次の 3 段階で「検証できる状態」への最短経路を提案します。

1. **Level 1**: 既存データの活用（DB クエリ、既存ログの分析）
2. **Level 2**: イベント計測の追加（イベント設計表つき）
3. **Level 3**: AI がデータを取れる経路の整備 — read-only API または MCP サーバー化。AI エージェントが検証結果を自律的に取得・判定できるようになり、`/hdd:learn` のループが回り続けます

## FAQ

**Q. 強制がうるさくないか。**
skill は一度問うだけで、ユーザーの判断を尊重します（「検証しない」判断は記録だけ提案）。hooks は `HDD_HOOK_DISABLE=1` で止められます。

**Q. バグ修正にも仮説が要るのか。**
不要です。バグ修正・リファクタリング・CI 修正などの技術タスクはゲート対象外です（技術基盤タスクには「これで何ができるようになるか」の記載だけ求めます）。

**Q. 既存プロジェクトに途中から入れられるか。**
`/hdd:init` でセットアップ後、`/hdd:audit` で既存バックログを一括監査するところから始めてください。

## License

MIT
