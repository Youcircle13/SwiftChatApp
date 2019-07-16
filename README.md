# 【デベロッパープレビュー版 Swift SDK 公開記念】Swiftでチャットアプリを作ろう！
# はじめに
## セミナー概要
**チャットアプリ** の作成を通して、クラウドデータベースの会員管理とデータ保存、データ取得を学んでいきます。

### 今回習得できる内容
* 会員管理
* データの保存
* データの取得
* メッセージデータと会員の連携

## コンテンツ概要
### 作成できるアプリ
機能
* 新規ユーザー登録
* ログイン
* データ（メッセージ）保存
* データ（メッセージ）取得

チャットルームの中で複数ユーザーがチャットを行うことが可能です。

### 使用したツール
**ニフクラ mobile backend**

にふくら-もばいる-ばっくえんど 【ニフクラ mobile backend】 スマートフォンアプリに必要なバックエンド機能が開発不要で利用できるクラウドサービス。 クラウド上に用意された機能を API で呼び出すだけで利用できます。また、APIを簡単に使うための SDK を用意しています（ iOS / Android / Monaca / Unity ）。mobile Backend as a Service の頭文字を取って、通称 mBaaS と呼ばれます。

### 使用したライブラリ
* ニフクラ mobile backend デベロッパープレビュー版 Swift SDK
* JSQMessagesViewController

# ハンズオン
## 事前準備
* 動作環境
  * Mac
  * Xcode ver.10.x 以上
  * Swift 4.2 以上
* ニフクラ mobile backend の利用登録（無料）
  * [登録ページ](https://mbaas.nifcloud.com/signup.htm)
  * SNSアカウント登録をしてください
## 作業手順目次
### 1. 環境準備
1. mobile backend の準備
1. サンプルプロジェクトの準備
1. mobile backend APIキー設定とSDKの初期化
### 2. コーディングと動作確認
1. コーディングの進め方について
1. 新規ユーザー登録機能
1. ログイン機能
1. ログアウト機能
1. メッセージデータ保存機能
1. メッセージデータ取得機能
### 3. まとめと考察
1. ACLによるデータ管理
1. ロールを活用したグループチャットの作成
1. ファイルストアを活用したアイコン設定
1. ローカルにデータを保持

# 環境準備
## mobile backend の準備
* [mobile backend](https://mbaas.nifcloud.com/) にログインします
* 新しいアプリを作成します
* アプリ名を入力し 「新規作成」 ボタンをクリックします　例）SwiftChatApp
* mobile backend を既に使用したことがある場合は、画面上方のメニューバーにある 「＋新しいアプリ」 をクリックすることで新しいアプリ作成画面が表示されます
* アプリが作成されるとAPIキー（2種類）が発行されます
  * APIキーはあとで使用します
* ここでは使用しないので、「OK」 で閉じます
* 管理画面が開かれ、ダッシュボードが表示されます

これで mobile backend の準備は完了です
## サンプルプロジェクトの準備
* 下記リンクからプロジェクトをローカルフォルダにダウンロードします
  * https://github.com/Youcircle13/SwiftChatApp/archive/seminar.zip
* zipファイルを解凍して内容を確認します
* 今回は使用するSDKやライブラリは導入してあります
* ダウンロードしてあるプロジェクトの `SwiftChatApp.xcworkspace` をダブルクリックします
* Xcode が起動し、プロジェクトが開かれます
**注意**
青いアイコンの `SwiftChatApp.xcodeproj` からXcodeを起動しても動作しません。
必ず白いアイコンの `SwiftChatApp.xcworkspace` から起動してください。
## コーディングの進め方について
* `SwiftChatApp` プロジェクト内のファイルに記述していきます
* 必要なコードが虫食い状態になっていますので、手順ごとに1つずつコーディングしてアプリを完成させます。
```
/***** 【NCMB】SDKの初期化 *****/
        
/***** 【NCMB】SDKの初期化 *****/
```
## mobile backend APIキー設定とSDKの初期化
* `AppDelegate.swift` を開きます
* `YOUR_NCMB_APPLICATION_KEY` と `YOUR_NCMB_CLIENT_KEY` を mobile backend でアプリ作成時に発行された２つの APIキー （アプリケーションキーとクライアントキー）に貼り替えます
```swift
/***** 【NCMB】APIキー *****/
let applicationkey = "YOUR_NCMB_APPLICATION_KEY"
let clientkey = "YOUR_NCMB_CLIENTKEY"
/***** 【NCMB】APIキー *****/
```
* APIキーは mobile backend 管理画面の「アプリ設定」で確認できます
* SDKの初期化を行います
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        /***** 【NCMB】SDKの初期化 *****/
        NCMB.initialize(
            applicationKey: applicationkey,
            clientKey: clientkey)
        /***** 【NCMB】SDKの初期化 *****/
        return true
    }
```
* 書き換えたら必ず保存をしましょう
  * **command + S キー** で保存できます

これでプロジェクトの準備は完了です
# コーディングと動作確認

## 新規ユーザー登録機能
* チャットを行うための会員をクラウドデータベースに保存する処理を実装します
## コーディング
* `CreateAcountViewController.swift` に記述します
* 「Create」ボタンを押したときに実行されるように記述します
```swift
/***** 【NCMB】会員管理 新規登録 *****/

/***** 【NCMB】会員管理 新規登録 *****/
```
* 会員管理を行うためのuserインスタンスを生成します。
```swift
//　Userインスタンスの生成
let user = NCMBUser()
```
* テキストデータに入力されているデータを `user` に設定します
```swift
// ユーザー名・パスワードを設定
user.userName = self.userNameTextField.text!
user.password = self.passwordTextField.text!
```
* 設定したデータで会員登録を行います
```swift
// ユーザーの新規登録
user.signUpInBackground(callback: { result in
    switch result {
    case .success:
        // 新規登録に成功した場合の処理
         
    case let .failure(error):
        // 新規登録に失敗した場合の処理

    }
})
```
* `.signUpInBackground()` で会員登録
* `switch case` で新規登録結果をラベルに表示させます
```swift
// 新規登録に成功した場合の処理
let successText = "新規登録に成功しました"
print(successText)
// errorLabelのの書き換え（メインスレッドで実行）
DispatchQueue.main.async {
    self.errorLabel.text = successText
}  
```
```swift
// 新規登録に失敗した場合の処理
let errorText = "新規登録に失敗しました"
print("\(errorText): \(error)")
// errorLabelのの書き換え（メインスレッドで実行）
DispatchQueue.main.async {
    self.errorLabel.text = errorText
}
```
* 書き換えたら必ず保存をしましょう
  * **command + S キー** で保存できます
## コード確認
下記のようになっていれば大丈夫です
```swift
//　Userインスタンスの生成
let user = NCMBUser()
// ユーザー名・パスワードを設定
user.userName = self.userNameTextField.text!
user.password = self.passwordTextField.text!
// ユーザーの新規登録
user.signUpInBackground(callback: { result in
    switch result {
    case .success:
        // 新規登録に成功した場合の処理
        let successText = "新規登録に成功しました"
        print(successText)
        // errorLabelのの書き換え（メインスレッドで実行）
        DispatchQueue.main.async {
            self.errorLabel.text = successText
        }
                
                
    case let .failure(error):
        // 新規登録に失敗した場合の処理
        let errorText = "新規登録に失敗しました"
        print("\(errorText): \(error)")
        // errorLabelのの書き換え（メインスレッドで実行）
        DispatchQueue.main.async {
            self.errorLabel.text = errorText
        }

    }
})
```

## 動作確認
* Simulator か実機を選択してアプリを実行します
* アプリが起動したら「Create New Acount」をタップして新規登録画面に遷移します
* テキストフィールドにユーザ名とパスワードを入力します
* 入力後「Create」ボタンをタップします
* ラベルに `新規登録に成功しました` と表示されれば正しく mobile backend 上にデータが格納されています
* クラウドにデータが保存されていることを実際に確認してみましょう
* mobile backend を開きます
* 「会員管理」 を開くと その中に登録した会員が格納されていることを確認できます

## ログイン機能
* クラウドデータベースに保存された会員管理のデータでログインの処理を実装します
### コーディング
* `ViewController.swift` に記述します
* 「Login」ボタンをタップしたときに実行されるように記述します
```swift
/***** 【NCMB】会員管理 ログイン *****/
NCMBUser.logInInBackground(userName: userName, password: password, callback: { result in
    switch result {
        case .success:
            // ログインに成功した場合の処理
            
        case let .failure(error):
            // ログインに失敗した場合の処理
                
    }
})
/***** 【NCMB】会員管理 ログイン *****/
```
* `NCMBUser.logInInBackground()` でログイン処理を実行
* `switch case` でログイン結果で画面遷移を操作します
```swift
// ログインに成功した場合の処理
let sucessText = "ログインに成功しました"
print(sucessText)
// チャット画面に遷移（メインスレッドで実行）
DispatchQueue.main.async {
    self.performSegue(withIdentifier: "toChatRoom", sender: self)
}
```

```swift
// ログインに失敗した場合の処理
// errorLabelのの書き換え（メインスレッドで実行）
DispatchQueue.main.async {
    let errorText = "ログイン失敗"
    print("\(errorText): \(error)")
    self.errorLabel.text = errorText
    //contentsのサイズに合わせてobujectのサイズを変える
    self.errorLabel.sizeToFit()
}
```
* ログインに成功すればチャット画面に遷移します
* 書き換えたら必ず保存をしましょう
  * **command + S キー** で保存できます
## コード確認
* 下記のようになっていれば大丈夫です
```swift
/***** 【NCMB】会員管理 ログイン *****/
NCMBUser.logInInBackground(userName: userName, password: password, callback: { result in
    switch result {
        case .success:
            // ログインに成功した場合の処理
            let sucessText = "ログインに成功しました"
            print(sucessText)
            // チャット画面に遷移（メインスレッドで実行）
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toChatRoom", sender: self)
            }
                
        case let .failure(error):
            // ログインに失敗した場合の処理
            // errorLabelのの書き換え（メインスレッドで実行）
            DispatchQueue.main.async {
                let errorText = "ログイン失敗"
                print("\(errorText): \(error)")
                self.errorLabel.text = errorText
                //contentsのサイズに合わせてobujectのサイズを変える
                self.errorLabel.sizeToFit()
            }
                
    }
})
/***** 【NCMB】会員管理 ログイン *****/
```

### 動作確認
* 再びアプリを実行します
* アプリが起動したらテキストフィールどに登録したユーザー名とパスワードを入力します
* ログインに成功するとチャット画面に遷移します
* ※登録していないユーザー名やパスワードを入力するとラベルにログイン失敗と表示されます

## ログアウト機能
* ログインしているユーザーをアプリからログアウトする処理を実装します
### コーディング
* `AppDelegate.swift` と `ChatRoomViewController.swift`に記述します
* アプリ落とした時と「Logout」ボタンをタップしたときに実行されるように記述します
* `AppDelegate.swift`
```swift
func applicationWillResignActive(_ application: UIApplication) {

    /***** 【NCMB】会員管理 ログアウト *****/
    NCMBUser.logOut()
    /***** 【NCMB】会員管理 ログアウト *****/
        
}
```
* `ChatRoomViewController.swift` 
```swift
/***** 【NCMB】会員管理 ログアウト *****/
NCMBUser.logOut()
/***** 【NCMB】会員管理 ログアウト *****/
```

### 動作確認
* アプリを実行します
* アプリが起動したらログインをします
* 左上の「logout」ボタンをタップします
* ログアウトが完了したらログイン画面に遷移します

## メッセージデータ保存機能
* ログインしたユーザーでメッセージを送信する処理を実装します
### コーディング
* `ChatRoomViewController.swift` に記述します
* カレントユーザー（ログインしているユーザー）を取得します
```swift
/***** 【NCMB】会員管理 カレントユーザー取得 *****/
let user = NCMBUser.currentUser
/***** 【NCMB】会員管理 カレントユーザー取得 *****/
```
* メッセージを保存するときに送信者（カレントユーザー）になるように紐づけます
```swift
/***** 取得したカレントユーザーと紐づける *****/
senderDisplayName = user?.userName
senderId = user?.objectId
/***** 取得したカレントユーザーと紐づける *****/
```
* 「send」ボタンを押したときに実行されるように記述します
* `NCMBObject(className: "chat")` で保存先のクラスを `chat` に指定します。
  * chatクラスは自動で作成されます
```swift
// クラスの生成
let object : NCMBObject = NCMBObject(className: "chat")
```
* `object[]` という変数に保存する値を設定します
  * `text` には入力した文字
  * `senderDisplayName` には紐づけたカレントユーザー名
  * `senderId` には紐づけたユーザーのオブジェクトID
```swift
// 値の設定
object["messege"] = text
object["userName"] = senderDisplayName
object["sender"] = senderId
```
* `.saveInBackground()` でクラウドデータベースにデータを保存します
```swift
// データストアへの登録を実施
object.saveInBackground(callback: { result in
    switch result {
    case .success:
        // 保存に成功した場合の処理
                
    case let .failure(error):
        // 保存に失敗した場合の処理

    }
})
```
* `switch case` でメッセージデータ保存の可否を判断します
```swift
// 保存に成功した場合の処理
let successText = "保存に成功しました"
print(successText)
self.showAlert(title: "", message: successText)
//画面に表示
self.makeMyMsg(senderId: senderId, desplayName: senderDisplayName, message: text)
```

```swift
// 保存に失敗した場合の処理
let errorText = "保存に失敗しました"
print("\(errorText): \(error)")
self.showAlert(title: "", message: errorText)
```
## コード確認
* 下記のようになっていれば大丈夫です
```swift
/***** 【NCMB】データストア 保存 *****/
// クラスの生成
let object : NCMBObject = NCMBObject(className: "chat")
// 値の設定
object["messege"] = text
object["userName"] = senderDisplayName
object["sender"] = senderId
// データストアへの登録を実施
object.saveInBackground(callback: { result in
    switch result {
    case .success:
        // 保存に成功した場合の処理
        let successText = "保存に成功しました"
        print(successText)
        self.showAlert(title: "", message: successText)
        //画面に表示
        self.makeMyMsg(senderId: senderId, desplayName: senderDisplayName, message: text)
                
    case let .failure(error):
        // 保存に失敗した場合の処理
        let errorText = "保存に失敗しました"
        print("\(errorText): \(error)")
        self.showAlert(title: "", message: errorText)
    }
})
/***** 【NCMB】データストア 保存 *****/
```

### 動作確認
* アプリを起動します
* アプリが起動したらログインをします
* テキストフィールドに文字を入力して「send」ボタンをタップします
* メッセージの保存の結果がアラートで表示されます
* クラウドにデータが保存されていることを実際に確認してみましょう
* mobile backend を開きます
* 「データストア」 を開くと `chat` クラスが作成されていて、その中にデータが格納されていることを確認できます

## メッセージデータ取得機能
* 送信されているメッセージを取得する処理を実装します
### コーディング
* `ChatRoomViewController.swift` に記述します
* ユーザー画像の表示を記述します
```swift
/***** senderId == 自分　だった場合表示しない *****/
if senderId == user?.objectId {
   return nil
}
/***** senderId == 自分　だった場合表示しない *****/
```
* ログインをしたときと「Reload」ボタンを押したときに実行されるように記述します
* データを取得するクラスを指定します
```swift
// クエリの作成
var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className: "chat")
```
* 取得するデータの件数を指定することが可能です
  * このコードを抜くことで全件取得可能です
```swift
//query.limit = 10 // 取得件数
```
* 時系列の古い順で取得します
```swift
query.order = ["-createDate"] //降順
```
* `.findInBackground()` でメッセージデータを取得できます
```swift
// 取得処理
query.findInBackground(callback: { result in
    switch result {
    case let .success(array):
        //取得に成功した場合の処理
                
    case let .failure(error):
        //取得に失敗した場合の処理
        let errorText = "取得に失敗しました"
        print("\(errorText): \(error)")
        self.showAlert(title: "", message: errorText)
                
    }
})
```
* `switch case` で取得できたかを判断します
```swift
//取得に成功したか
let successText = "取得に成功しました"
print("\(successText): \(array.count)件")
self.showAlert(title: "", message: successText)
//保持しているデータを初期化
self.messages = []
// 画面に表示
self.msgList = array.reversed()
self.makeMsg()
```

```swift
//取得に失敗した場合の処理
let errorText = "取得に失敗しました"
print("\(errorText): \(error)")
self.showAlert(title: "", message: errorText)
```
## コード確認
* 下記のようになっていれば大丈夫です
```swift
/***** 【NCMB】データストア 取得 *****/
// クエリの作成
var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className: "chat")
// 検索条件設定
//query.limit = 10 // 取得件数
query.order = ["-createDate"] //降順
// 取得処理
query.findInBackground(callback: { result in
    switch result {
    case let .success(array):
        let successText = "取得に成功しました"
        print("\(successText): \(array.count)件")
        self.showAlert(title: "", message: successText)
        //保持しているデータを初期化
        self.messages = []
        // 画面に表示
        self.msgList = array.reversed()
        self.makeMsg()
                
    case let .failure(error):
        let errorText = "取得に失敗しました"
        print("\(errorText): \(error)")
        self.showAlert(title: "", message: errorText)
                
    }
})
/***** 【NCMB】データストア 取得 *****/
```
### 動作確認
* アプリを起動します
* アプリが起動したらログインをします
* 先ほど「send」ボタンで保存されたメッセージデータが表示されます

# まとめと考察
## まとめ
クラウドデータベースの会員管理とデータ保存、データ取得を学びました
* 会員管理
* データの保存
* データの取得
* メッセージデータと会員の連携

## 考察
### ACLによるデータ管理
* 今回は使用しなかったデータ管理方法
* mBaaSの機能の一つ
* 保存したデータに権限を付与可能
* 読み取り可能なユーザーが指定できる
* ACLを利用したDMやグループチャットの実現
### ロールを活用したグループチャットの作成
* 会員のロールが作成可能
* mBaaSの機能の一つ
* デベロッパープレビュー版 Swift SDK では未実装
* ACLの権限をロールごとに指定可能
### ファイルストアを活用したアイコン設定
* 会員ごとにアイコン画像をクラウドに保存可能
* mBaaSの機能の一つ
* 本セミナーでは一つの画像のみ使用
* 会員ごとに画像を連携させることでアイコン設定が可能
### ローカルにデータを保持
* 今回はデータをすべて取得
* チャットの保存量が多くなると不可能
* アプリ側に保存して最新のデータのみ取得できるようにする
