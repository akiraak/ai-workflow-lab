# CLAUDE.md の実例調査

## 概要

公開リポジトリで実際に使われている CLAUDE.md の記述例を収集・分析し、プロジェクト種別ごとの記述傾向と共通パターンを整理する。

---

## 実例一覧

### 1. anthropics/claude-code-action（Anthropic 公式）

| 項目 | 内容 |
|------|------|
| プロジェクト種別 | GitHub Action（CI/CD ツール） |
| 言語 | TypeScript (Bun ランタイム) |
| 規模 | 中規模 |
| CLAUDE.md の長さ | 約60行 |

**記述内容**:
- **Commands**: `bun test`, `bun run typecheck`, `bun run format` 等の基本コマンド
- **What This Is**: プロジェクトの目的を1段落で説明
- **How It Runs**: アーキテクチャのフロー（エントリポイント → 処理 → クリーンアップ）
- **Key Concepts**: 認証の優先順位、モードのライフサイクル、プロンプト構築の仕組み
- **Things That Will Bite You**: 開発者がハマりやすい6つの罠（TypeScript 厳格モード、ユニオン型の扱い、トークンライフサイクル等）
- **Code Conventions**: ランタイム（Bun）、モジュール解決、リトライロジックの規約

**特徴**: 「Things That Will Bite You」セクションが特徴的。コードから読み取りにくい「罠」を明示的に列挙している。Anthropic 自身のプロジェクトであり、CLAUDE.md の模範例と言える。

---

### 2. tldraw/make-real

| 項目 | 内容 |
|------|------|
| プロジェクト種別 | Web アプリケーション（AI プロトタイピングツール） |
| 言語 | TypeScript (Next.js 14) |
| 規模 | 中規模 |
| CLAUDE.md の長さ | 約120行 |

**記述内容**:
- **Project Overview**: 1段落でプロジェクトの目的を説明
- **Development Commands**: yarn コマンド一覧。テストスイートが存在しないことも明記
- **Architecture**: コアフロー（ユーザー操作 → AI 呼び出し → HTML レンダリング）を番号付きで説明
- **Key Components**: 主要な Hook・コンポーネント・設定システムの詳細
- **API Routes**: 各 AI プロバイダのルート設定（温度、シード値等の詳細）
- **Code Patterns**: 新しい AI プロバイダの追加手順、プロンプト変更手順、設定マイグレーション手順
- **Environment Variables**: 環境変数の一覧と用途
- **Technology Stack**: 使用技術の一覧

**特徴**: 「Code Patterns」セクションで新機能追加の手順をステップバイステップで記載している。API ルートの設定詳細（モデルごとの温度・シード値の違い）が具体的。比較的長いが、AI プロバイダの切り替え設定など、コードだけでは把握しにくい情報が中心。

---

### 3. ArthurClune/claude-md-examples（テンプレート集）

| 項目 | 内容 |
|------|------|
| プロジェクト種別 | CLAUDE.md テンプレート集 |
| 対象 | Hugo, Python, Terraform |
| スター数 | 119 |

**収録テンプレート**:
- `hugo-CLAUDE.md` — Hugo 静的サイト向け
- `python-CLAUDE.md` — Python プロジェクト向け
- `python2-CLAUDE.md` — Python 2 プロジェクト向け
- `terraform-CLAUDE.md` — Terraform インフラ向け

**特徴**: modelcontextprotocol/python-sdk、p33m5t3r/vibecoding、saaspegasus/pegasus-docs から編集・マージされた実用的なテンプレート。言語/フレームワーク別に分類。

---

### 4. Zenn 記事の ShopFront 例（farstep）

| 項目 | 内容 |
|------|------|
| プロジェクト種別 | Web アプリケーション（EC サイト） |
| 言語 | TypeScript (Next.js 16) |
| CLAUDE.md の長さ | 約30行 |

**記述内容**:
```markdown
# ShopFront
Next.js 16 の EC アプリ。App Router、Turbopack、Stripe 決済、Prisma ORM、Tailwind CSS を使用。

## コードスタイル
- TypeScript strict モード。any 型は禁止
- default export ではなく named export を使用
- CSS は Tailwind ユーティリティクラスのみ
- コードスタイルは ESLint と Prettier で強制

## コマンド
- pnpm dev / pnpm test / pnpm test:e2e / pnpm lint / pnpm db:migrate / pnpm db:seed

## アーキテクチャ
- /app: App Router のページとレイアウト
- /app/api: API ルート（すべて /api/v1 プレフィックス）
- /components/ui: 再利用可能な UI コンポーネント
- /lib: ユーティリティと共有ロジック
- /prisma: データベーススキーマとマイグレーション

## 注意事項
- IMPORTANT: Next.js 16 ではデータ取得がデフォルトでキャッシュされない
- Stripe の webhook ハンドラは署名検証が必須
- 商品画像は Cloudinary に保存
- 認証フローの詳細は @docs/auth-flow.md を参照
```

**特徴**: 約30行と非常に簡潔。「Claude がコードから読み取れない情報」に絞った模範例。`IMPORTANT` で強調された注意事項、`@` による外部ドキュメント参照を活用。

---

### 5. ranthebuilder.cloud の実践例（Ran Isenberg）

| 項目 | 内容 |
|------|------|
| プロジェクト種別 | 複数プロジェクト（Web サイト、Mac アプリ、CLI ツール） |
| 著者 | AWS Serverless Hero、Palo Alto Networks |

**CLAUDE.md の共通構成**:
1. プロジェクト概要とターゲットユーザー
2. 技術スタック・フレームワークバージョン
3. ビルド・テスト・デプロイコマンド
4. プロジェクト構造ドキュメント
5. コーディング規約
6. 重要ルール（シークレット禁止、アクセシビリティ等）

**特徴**: 200行以内を厳守。必要なスキルは import リンクで参照。「ドメイン知識がボトルネック」という洞察に基づき、プロジェクト固有の知識を重視。

---

### 6. Boris Cherny のアプローチ（Claude Code 作者）

| 項目 | 内容 |
|------|------|
| プロジェクト種別 | Anthropic 内部プロジェクト |
| CLAUDE.md の長さ | 約100行（2.5k トークン） |

**特徴**:
- チーム全員が git にコミットして共同管理
- PR レビューで `@.claude` タグを使って学びを追加
- "My setup might be surprisingly vanilla!" — 派手な設定より規律を重視
- PostToolUse フックで自動フォーマット
- `/permissions` で安全なコマンドを事前許可

---

## プロジェクト種別ごとの記述傾向

### Web アプリケーション（Next.js / React）

- **必須セクション**: 開発コマンド、アーキテクチャ（ディレクトリ構造）、コードスタイル
- **特徴的な記述**: フレームワーク固有の注意事項（キャッシュ挙動、データ取得パターン）、CSS ルール（Tailwind のみ等）
- **傾向**: UI コンポーネントの規約、状態管理の方針、API ルートの設計規約が含まれることが多い

### CLI ツール / GitHub Action

- **必須セクション**: コマンド、エントリポイントの説明、テスト方法
- **特徴的な記述**: ランタイム環境の指定（Bun vs Node）、型システムの厳格度、エラーハンドリングの方針
- **傾向**: 「Things That Will Bite You」のような罠リストが有用

### ライブラリ / SDK

- **必須セクション**: パブリック API の方針、テスト戦略、バージョニング
- **特徴的な記述**: 後方互換性のルール、エクスポートパターン
- **傾向**: コードスタイルよりもAPI設計の制約を重視

### インフラ / IaC（Terraform 等）

- **必須セクション**: デプロイ手順、環境別設定、状態管理
- **特徴的な記述**: 破壊的変更の禁止ルール、プラン実行の手順
- **傾向**: 安全性に関するルール（`terraform destroy` 禁止等）が重要

---

## 共通パターンと特徴的なパターン

### 多くのプロジェクトに共通する記述

1. **開発コマンド**: ビルド、テスト、リント、開発サーバー起動コマンドはほぼ全プロジェクトに存在
2. **プロジェクト概要**: 1-2行でプロジェクトの目的を説明
3. **アーキテクチャ / ディレクトリ構造**: 主要ディレクトリの役割を簡潔に記述
4. **コードスタイル**: デフォルトと異なるルールのみ（TypeScript strict、export スタイル等）
5. **テスト方法**: テストフレームワーク、テストファイルの配置場所

### 特徴的なパターン（参考になるもの）

1. **「Things That Will Bite You」セクション**（claude-code-action）
   - 開発者がハマりやすい罠を具体的に列挙
   - コードを読むだけでは気づきにくい落とし穴に焦点

2. **「Code Patterns」セクション**（make-real）
   - 新機能追加・変更の手順をステップバイステップで記載
   - Claude が既存パターンに沿った実装を行いやすくする

3. **Progressive Disclosure 構成**（farstep）
   - CLAUDE.md → .claude/rules/ → .claude/skills/ の3層構造
   - トップレベルは30行に抑え、詳細は必要時にのみ読み込む

4. **`@` インポートによる外部参照**
   - `@docs/auth-flow.md` のように外部ドキュメントを参照
   - CLAUDE.md 自体を短く保ちながら詳細情報にアクセス可能

5. **IMPORTANT / MUST による強調**
   - 本当に重要な数項目のみに使用
   - フレームワークの非自明な挙動の警告に有効

6. **チーム共同管理**（Boris Cherny）
   - CLAUDE.md を git にコミットして共有
   - PR レビューから学びを追加する運用

---

## まとめ

CLAUDE.md を書く際の参考ポイント:

### 構成の基本

1. **プロジェクト概要**（1-2行）
2. **開発コマンド**（ビルド、テスト、リント、開発サーバー）
3. **アーキテクチャ**（主要ディレクトリの役割）
4. **コードスタイル**（デフォルトと異なるもののみ）
5. **注意事項**（プロジェクト固有の罠・ゴッチャ）

### 量と質のバランス

- **30-100行が理想的**（Boris Cherny: 100行、ShopFront 例: 30行）
- **200行を上限として厳守**（公式推奨）
- 超える場合は Progressive Disclosure で分離

### 判断基準

- 各行に「この行を削除したら Claude がミスするか？」を自問
- コードから読み取れることは書かない
- リンターで強制できることはリンターに任せる
- 頻繁に変わる情報は Auto Memory に任せる

### 運用のポイント

- `/init` で出発点を作り、手作業で精査する
- PR レビューから学びを追加するフィードバックループ
- 月次で棚卸しして古い内容を削除
- チームで共有し、CLAUDE.local.md で個人設定を分離

---

## 参考資料

- [anthropics/claude-code-action CLAUDE.md](https://github.com/anthropics/claude-code-action/blob/main/CLAUDE.md) — Anthropic 公式 GitHub Action
- [tldraw/make-real CLAUDE.md](https://github.com/tldraw/make-real/blob/main/CLAUDE.md) — AI プロトタイピングツール
- [ArthurClune/claude-md-examples](https://github.com/ArthurClune/claude-md-examples) — 言語別テンプレート集
- [効果的なCLAUDE.mdの書き方 — Zenn (farstep)](https://zenn.dev/farstep/articles/how-to-write-a-great-claude-md) — 設計原則とProgressive Disclosure
- [Your CLAUDE.md Is Probably Wrong — devopsn.cloud](https://www.devopsn.cloud/en/blogs/your-claude-md-is-probably-wrong-7-mistakes-boris-cherny-never-makes) — Boris Cherny のアプローチ分析
- [Claude Code Best Practices: Lessons From Real Projects — ranthebuilder.cloud](https://ranthebuilder.cloud/blog/claude-code-best-practices-lessons-from-real-projects) — 実プロジェクトからの教訓
- [みんなどう書いてる？人気のCLAUDE.md — note.com](https://note.com/aiwakaruman/n/n1cc2cbed8883) — 人気 CLAUDE.md の分析
- [ChrisWiles/claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase) — 包括的な設定例
