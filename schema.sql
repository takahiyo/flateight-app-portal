-- FLATEIGHT共通アカウント・販売基盤（設計用、未デプロイ）
PRAGMA foreign_keys=ON;
CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY, auth_provider TEXT NOT NULL, provider_subject TEXT NOT NULL, email TEXT, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, UNIQUE(auth_provider,provider_subject));
CREATE TABLE IF NOT EXISTS products (id TEXT PRIMARY KEY, name TEXT NOT NULL, published INTEGER NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS prices (id TEXT PRIMARY KEY, product_id TEXT NOT NULL REFERENCES products(id), model TEXT NOT NULL CHECK(model IN ('one_time','subscription')), currency TEXT NOT NULL DEFAULT 'jpy', amount INTEGER NOT NULL CHECK(amount>=0), interval TEXT CHECK(interval IN ('month','year') OR interval IS NULL), stripe_price_id TEXT UNIQUE, active INTEGER NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS subscriptions (stripe_subscription_id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id), product_id TEXT NOT NULL REFERENCES products(id), status TEXT NOT NULL, current_period_end INTEGER, updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS entitlements (id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id), product_id TEXT NOT NULL REFERENCES products(id), source TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 0, expires_at INTEGER, updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE INDEX IF NOT EXISTS entitlements_user_product ON entitlements(user_id,product_id,active);
CREATE TABLE IF NOT EXISTS payment_events (stripe_event_id TEXT PRIMARY KEY, received_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, processed_at TEXT, status TEXT NOT NULL DEFAULT 'pending');
CREATE TABLE IF NOT EXISTS trials (user_id TEXT NOT NULL REFERENCES users(id), product_id TEXT NOT NULL REFERENCES products(id), started_at INTEGER NOT NULL, ends_at INTEGER NOT NULL, PRIMARY KEY(user_id,product_id));
