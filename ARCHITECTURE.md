# FLATEIGHT 販売基盤設計 (2026-10-16)

## 決定事項
- `https://apps.flateight.jp` がポータル。既存ルート `flateight.jp` は変更しない。
- 全アプリ共通アカウント（現在は未実装）。既存BookReader等の認証移行は段階実施。
- 価格はアプリごとに独立。無料・買い切り・サブスクの混在を許す。無料体験版を選択可能。
- 買い切り商品は購入前の無料体験を基本方針とする。ただし返金不可の無条件保証は設定しない。
- 掲載切替 `visible` とサービス利用権限は別管理。

## 安全なアーキテクチャ
```text
Cloudflare Pages (public + toolsは配信しない)
  |- apps.json : 公開カタログ（価格が確定してから表示）
  |- Account frontend : Firebase Authentication / Googleなど既存アカウントを統合予定
  |- /api/me : IDトークン署名・issuer・audience・exp検証後、利用権取得
  |- /api/checkout : 認証済みユーザーのみ、サーバー保持のStripe price IDでCheckout Session発行
  |- /api/stripe/webhook : RAW bodyで署名・再送・重複検証 / D1同期
  |- /api/billing/portal : 認証済みユーザーとStripe customerの紐付け検証
  `- D1 : users / products / prices / subscriptions / entitlements / payment_events / trials
```

## 実装前提・禁止事項
1. Stripe秘密鍵とWebhook署名キーはCloudflare Secrets。公開JSON・ブラウザへ配置しない。
2. Firebase IDトークン検証はバックエンドで実施。フロントエンドのuidや任意emailだけで認可しない。
3. Checkoutはクライアントの価格・対象商品を信用せず、DBの販売可・税込額・Stripe price IDを参照。
4. webhookイベントは署名検証、冪等性、イベント順序の逆転、障害時再処理を考慮する。
5. `trial`はサーバー保存しユーザーと製品をキーとして重複利用を制限する。
6. サブスクの解約後・支払失敗・返金処理時の利用権遷移を明文化。
7. 既存アプリは認証の一斉変更を避け、共通利用権APIに段階的に接続する。
8. 購入確定画面には契約内容、税込価格、更新・取消し条件等を明示。
9. デジタル商品の返品・解約条件は各アプリで明記する。法令上の権利は排除しない。
10. 現在のプロジェクトには**実決済・実認証APIがない**。課金可能を装うボタンを表示しない。

## 商品状態の例
- `apps.json`: `visible` は一覧掲載、`status` は製品稼働状態。
- `sale.enabled` は確定した商用価格表示のフラグであって販売開始スイッチではない。
- `sale.model`: `free` / `one_time` / `subscription` / `undecided`。
- `sale.priceJPY`: 税込金額（現段階はnull）。`sale.interval`: month/year。
- 決済提供は将来のDB `prices.active`、システムの本番設定、法務ページ確認とセットで有効化。

## テスト要件
署名不正Webhook拒否、重複イベント、認証なし決済拒否、価格改ざん、退会・失効、体験版繰返し防止、購入後の権限復旧、アプリ非掲載でも既購入権維持を検証。
