# Web サイトへの未掲載コンテンツ追加

## 目的

VitePress サイト（`server.sh` で起動）に載っていない調査・実験情報を追加し、全成果物をブラウザで閲覧できるようにする。

## 背景

現状のサイトには Phase 1〜3 の実験レポート（01〜15）と Web 調査キャッシュ（4セッション）が掲載されているが、以下の情報が欠落している:

1. **16-cross-analysis.md** — Phase 1〜3 の横断分析レポート
2. **Phase 4B 実験結果** — B1〜B6 の実験データ（CSV + raw JSON）および分析

---

## タスク

### Task 1: 横断分析レポートをサイドバーに追加

- **対象ファイル**: `experiments/claude-code-prompting/16-cross-analysis.md`
- **変更箇所**: `.vitepress/config.ts` の sidebar 設定
- **方法**: Phase 3 セクションの末尾、もしくは新規セクション「Phase 1〜3 横断分析」として追加

```ts
// .vitepress/config.ts sidebar に追加
{ text: '横断分析レポート', link: '/experiments/claude-code-prompting/16-cross-analysis' },
```

### Task 2: Phase 4B 実験結果ページの作成

Phase 4B の実験結果は現在 CSV + raw JSON のみで、Markdown ページが存在しない。閲覧用のページを作成する。

#### 2-1. Phase 4B 概要ページの作成

- **作成先**: `experiments/phase-4b/index.md`
- **内容**:
  - Phase 4B の目的・概要
  - 各実験（B1〜B6）へのリンクと結果サマリー
  - 実験環境の説明（sample-project の構成）

#### 2-2. 各実験（B1〜B6）の結果ページ作成

- **作成先**: `experiments/phase-4b/B1.md` 〜 `experiments/phase-4b/B6.md`（計6ファイル）
- **内容の情報源**:
  - 実験結果: `experiments/phase-4b/results/B{1-6}/results.csv`
  - 実験設計: `experiments/claude-code-prompting/` 内の設計書（17-B1〜17-B6 として言及）
  - 結果サマリー: `DONE.md` に記録済みの実験結果
- **各ページの構成**:
  - 実験の目的・仮説
  - 実験条件（使用した CLAUDE.md バリアント、プロンプト等）
  - 結果データ（CSV をテーブル化）
  - 考察・結論

#### 2-3. サイドバーへの追加

```ts
// .vitepress/config.ts sidebar に追加
{
  text: 'Phase 4B: 実証実験',
  items: [
    { text: '概要', link: '/experiments/phase-4b/' },
    { text: 'B1: 事実形式 vs 命令形式', link: '/experiments/phase-4b/B1' },
    { text: 'B2: 否定形 vs 肯定形', link: '/experiments/phase-4b/B2' },
    { text: 'B3: CLAUDE.md 行数と遵守率', link: '/experiments/phase-4b/B3' },
    { text: 'B4: Plan mode 初回成功率', link: '/experiments/phase-4b/B4' },
    { text: 'B5: TDD Bug Fix 効果', link: '/experiments/phase-4b/B5' },
    { text: 'B6: Hooks 品質影響', link: '/experiments/phase-4b/B6' },
  ],
},
```

### Task 3: トップページ（index.md）の更新

- **対象ファイル**: `index.md`
- **変更**: Phase 4B セクションの追加（横断分析へのリンクも含める）

---

## 実装順序

1. Task 1（横断分析追加）— config.ts の1行追加のみ
2. Task 2-1, 2-2（Phase 4B ページ作成）— CSV データの読み込みとページ化
3. Task 2-3（サイドバー追加）— config.ts の更新
4. Task 3（トップページ更新）— index.md の更新
5. 動作確認 — `server.sh` で起動して全ページの表示を確認
