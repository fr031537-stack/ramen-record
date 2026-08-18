# ラーメン記録アプリ（GitHub Pages + Supabase）

Excel「ラーメン記録.xlsx」の **32店 / 26件の既存訪問記録** を初期データとして取り込んだ版です。

## できること
- 店一覧・地域絞り込み・検索
- 訪問日ごとの「メニュー / スープ / 麺 / 再訪 / コメント」記録
- 1回の訪問に写真を最大5枚追加
- 同じ店へ何度でも訪問記録を追加
- Supabaseログインで自分のデータだけを表示
- GitHub Pagesで公開
- PWA用 manifest / service worker / アイコン入り
- JSONバックアップ出力

## 最初に行うこと（4段階）

### 1. Supabaseで新しいProjectを作る
Supabaseにログインし、New project から空のProjectを1つ作ります。

### 2. `supabase.sql` を実行する
Supabaseの **SQL Editor** を開き、このフォルダの `supabase.sql` の内容を全部貼り付けて Run します。
これで「店」「訪問」「写真」の保存場所と、自分のデータだけを見られる安全設定が作られます。

### 3. `config.js` に2つ貼る
Supabase Project Settings / API で表示される Project URL と anon/public key を、`config.js` の次の2行へ貼ります。

```js
export const SUPABASE_URL = 'ここにProject URL';
export const SUPABASE_ANON_KEY = 'ここにanon/public key';
```

※ anon/public key はブラウザ用のキーです。RLS（supabase.sqlの安全設定）を有効にした状態で使います。`service_role` key は絶対に入れないでください。

### 4. GitHubへこのフォルダの中身を保存してPagesをONにする
1. GitHubで新しいRepository（例 `ramen-record`）を作る
2. このフォルダの中身をすべてアップロード
3. Repositoryの Settings → Pages
4. Deploy from a branch → `main` / `(root)` を選択
5. GitHub PagesのURLをスマホで開く
6. Supabaseの Authentication → URL Configuration で、Site URL（またはRedirect URL）にそのGitHub Pages URLを登録する

## 最初のログイン
アプリ画面の「新規登録」でメールアドレスとパスワードを登録します。
Supabase側でメール確認がONなら、届いた確認メールのリンクを開いてからログインします。
**初めてログインしたユーザーには、Excelの初期データが自動で1回だけ入ります。**

## PWAとしてホーム画面へ
GitHub Pages公開後、スマホのブラウザで開いて「ホーム画面に追加」を使います。
`manifest.webmanifest` と `sw.js` はすでに入っています。

## Excelの「回数」について
元Excelで「回数=2」と書かれていた店（三田製麺所、来来）は、その数字を `legacy_count` として保存しています。
過去2回分の日付・メニューがExcelには1件分しかないため、存在しない履歴は作っていません。今後の訪問は日付ごとの履歴として追加されます。

## ファイルの役割
- `index.html` : 画面
- `styles.css` : 見た目
- `app.js` : アプリの動作
- `seed.js` : Excelから取り込んだ初期データ
- `config.js` : Supabase接続先
- `supabase.sql` : Supabase側の保存場所・安全設定
- `manifest.webmanifest` / `sw.js` : PWA用
- `icons/` : ホーム画面アイコン

## 注意
GitHub Pagesは静的ファイルの公開に使い、データと写真はSupabaseに保存します。
写真URLは1時間有効の署名付きURLをアプリが都度作る方式です。
