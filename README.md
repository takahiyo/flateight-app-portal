# FLATEIGHT App Portal

FLATEIGHTアプリ紹介サイト（静的HTML/CSS/JS、ビルド不要）。

## 内容

- `public/index.html` : 一般公開トップページ
- `public/style.css` : レスポンシブデザイン
- `public/app.js` : 表示・非表示とカテゴリ表示
- `public/apps.json` : 公開アプリ一覧の唯一の設定元
- `tools/editor.html` : ローカル用公開状態エディター（デプロイ対象外）

## 簡単に試す

```powershell
cd .\flateight-app-portal\public
py -m http.server 8000
```

ブラウザで `http://localhost:8000` にアクセス。`file://` 直接表示は JSON 読み込みに失敗する場合があります。

## アプリの公開・非公開

1. `tools/editor.html` をブラウザで開く
2. `public/apps.json` を読み込む
3. 各アプリの「サイトに表示」をON/OFF、公開状態・URLを設定
4. JSONを保存し、`public/apps.json` を置き換えてコミット
5. PagesとのGit連携後、サイトが自動更新される

JSONの `visible: false` は一覧から除外します。これは**サイトからの非表示のみ**であり、アプリURLやGitHubソースへのアクセス制御ではありません。アクセス自体を止めるには対象サービス側の停止・認証設定・リポジトリのPrivate化等が必要です。

`status: "available"` かつ有効な `url` の場合にだけ「アプリを開く」リンクを表示。未公開のアプリは案内だけ表示します。`featured` は将来の並べ替え拡張用フラグです。

## GitHub + Cloudflare Pages

1. GitHubに新しいリポジトリ（例: `flateight-app-portal`）を作成して、このフォルダーの中身をpush。
2. Cloudflare > Workers & Pages > Create application > Pages > Connect to Git でそのリポジトリを選択。
3. Build command は空、Build output directory は `public`、production branch は `main` に設定。
4. `apps.flateight.jp` をCustom Domainsに登録。既存の `flateight.jp` には変更を加えない。
5. `public/apps.json` を更新してpushすると再デプロイ。

## 商用化に必要な未設定事項

問い合わせ用メールアドレスは暫定的に `contact@flateight.jp` と記述しています。**存在・受信確認前に公開しないこと。** 必要ならHTMLを更新してください。利用規約・プライバシーポリシー・特商法表示は、事業者情報と実際の販売条件が確定するまで架空の内容で公開しません。

有料化時は必ず、事業者情報、提供する商品・サービス、料金（税込）、決済方法・時期、提供時期、サブスク更新・解約、返金方針、利用規約、プライバシーポリシー、問い合わせ窓口を確認し、購入の最終確認画面にも適切な表示をしてください。

この雛形に課金・ログイン機能は含みません。有料利用権はサーバー側で検証し、決済Webhookは署名検証・冪等性を実装してください。

## セキュリティ

`tools` は `public` の外側です。CloudflareのBuild output directoryを `public` にすることで管理エディターを外部公開しません。なおエディター自体に管理権限・GitHub認証・トークンはありません。外部CDN依存はGoogle Fontsのみです。外部フォントが不要であればCSSの `@import` を削除できます。

## 正式公開・法務ページ（2026-10-16）
`public/terms.html`、`public/privacy.html`、`public/commerce.html` は **noindex 付きの未確定草案** です。正式公開前に実態に合わせて確定する必要があります。`PUBLICATION_CHECKLIST.md` を参照してください。トップの追加CSSは `public/compact.css` です。

## 商用ポータル v3
方針: アプリ別料金・全アプリ共通アカウント・買い切り商品は購入前無料体験・`apps.flateight.jp`。`ARCHITECTURE.md` と `schema.sql` に設計を記載。`public/account.html` は認証未接続の準備ページで、販売・ログインはできません。公開カタログは名称・カテゴリ・料金体系で絞り込みできます。`public/apps.json` の `sale` 情報は表示用のみです。
