# ニフクラ mobile backend Swift SDKについて

## 概要

ニフクラ mobile backend Swift SDKは、
モバイルアプリのバックエンド機能を提供するクラウドサービス
[ニフクラ mobile backend](https://mbaas.nifcloud.com)用の Swift SDK です。

- プッシュ通知
- データストア
- 会員管理
- ファイルストア

といった機能をアプリから利用することが可能です。

このSDKを利用する前に、ニフクラ mobile backendのアカウントを作成する必要があります。

## 動作環境

- Swift version 4.2
- iOS 12.0
- Xcode10.x

## 開発者検証バージョン

この SDK につきましては現在、デベロッパープレビュー版です。テクニカルサポート対応バージョンではありませんので御注意ください。

### 現在未実装部分について

以下の機能につきましては現在実装中です。今後順次、提供いたします。

* データストア
  * ポインタ操作
  * リレーション操作
* クエリ
  * 副問い合わせ
  * 位置情報検索
* プッシュ通知
  * リッチプッシュ
  * 絞り込み配信プッシュ通知の登録
  * 配信期限の設定
* 会員管理
  * SNS認証
  * ロール制御
  * メールアドレス確認

## ライセンス

このSDKのライセンスについては、LICENSEファイルをご覧ください。

## 参考URL集

- [ニフクラ mobile backend](https://mbaas.nifcloud.com/)
- [ドキュメント](https://mbaas.nifcloud.com/doc/current/)
- [ユーザーコミュニティ](https://github.com/NIFCloud-mbaas/UserCommunity)

## サンプル

### 初期化

```Swift
    NCMB.initialize(
        applicationKey: /* アプリケーションキー */,
        clientKey: /* クライアントキー */)
```

### データストア

#### オブジェクトをデータストアに保存する

```Swift
    // testクラスのNCMBObjectを作成
    let object : NCMBObject = NCMBObject(className: "test")

    // オブジェクトに値を設定
    object["fieldA"] = "Hello, NCMB!"
    object["fieldB"] = "日本語の内容"
    object["fieldC"] = 42
    object["fieldD"] = ["abcd", "efgh", "ijkl"]

    // データストアへの登録を実施
    object.saveInBackground(callback: { result in
        switch result {
            case .success:
                // 保存に成功した場合の処理
                print("保存に成功しました")
            case let .failure(error):
                // 保存に失敗した場合の処理
                print("保存に失敗しました: \(error)")
        }
    })
```

#### オブジェクトの取得

```Swift
    // testクラスへのNCMBObjectを設定
    let object : NCMBObject = NCMBObject(className: "test")

    // objectIdプロパティを設定
    object.objectId = "Mz6xym6wNi63lxb8"

    object.fetchInBackground(callback: { result in
        switch result {
            case .success:
                // 取得に成功した場合の処理
                print("取得に成功しました")
                if let fieldB : String = object["fieldB"] {
                    print("fieldB value: \(fieldB)")
                }
            case let .failure(error):
                // 取得に失敗した場合の処理
                print("取得に失敗しました: \(error)")
        }
    })
```

#### オブジェクトの更新

保存済み（または、objectIdを持っている）のオブジェクトに新しい値をセットして `saveInBackground` メソッドを実行することでデータストアの値が更新されます。

#### データストアに対しての操作を設定する

```Swift
    // testクラスのNCMBObjectを作成
    let object : NCMBObject = NCMBObject(className: "test")

    // objectIdプロパティを設定
    object.objectId = "Mz6xym6wNi63lxb8"

    // 指定したフィールドの値をインクリメントする（すでに該当フィールドに値が存在する場合にのみ更新可能）
    object["fieldC"] = NCMBIncrementOperator(amount: 1)
    // 指定したフィールドの配列内で重複しなければ追加する
    object["fieldD"] = NCMBAddUniqueOperator(elements: ["food", "fish"])

    // データストアへの更新を実施
    object.saveInBackground(callback: { result in
        switch result {
            case .success:
                // 更新に成功した場合の処理
                print("更新に成功しました")
            case let .failure(error):
                // 更新に失敗した場合の処理
                print("更新に失敗しました: \(error)")
        }
    })
```

#### オブジェクトの削除

```Swift
    // testクラスのNCMBObjectを作成
    let object : NCMBObject = NCMBObject(className: "test")

    // objectIdプロパティを設定
    object.objectId = "Mz6xym6wNi63lxb8"

    // データストアから削除
    object.deleteInBackground(callback: { result in
        switch result {
            case .success:
                print("削除に成功しました")
            case let .failure(error):
                print("削除に失敗しました: \(error)")
        }
    })
```

#### オブジェクトの関連付け

* TBD

#### オブジェクトの検索を行う

```Swift
    // クエリの作成
    var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className: "test")
    // フィールドの値が 42 と一致
    query.where(field: "fieldC", equalTo: 42)

    // 検索を行う
    query.findInBackground(callback: { result in
        switch result {
            case let .success(array):
                print("取得に成功しました 件数: \(array.count)")
            case let .failure(error):
                print("取得に失敗しました: \(error)")
        }
    })
```

#### 標準クラスを検索する場合

```Swift
    // 会員管理
    let userQuery : NCMBQuery<NCMBUser> = NCMBUser.query

    // ロール
    let roleQuery : NCMBQuery<NCMBRole> = NCMBRole.query

    // ファイルストレージ
    let fileQuery : NCMBQuery<NCMBFile> = NCMBFile.query

    // 配信端末
    let installationQuery : NCMBQuery<NCMBInstallation> = NCMBInstallation.query

    // プッシュ通知
    let pushQuery : NCMBQuery<NCMBPush> = NCMBPush.query
```

#### クエリの合成

and検索

```Swift
    // クエリの作成
    var query = NCMBQuery.getQuery(className: "test")
    query.where(field: "fieldA", equalTo: "Hello, NCMB!")
    query.where(field: "fieldC", greaterThanOrEqualTo: 40)

    // 検索を行う
    query.findInBackground(callback: { result in
        switch result {
            case let .success(array):
                print("取得に成功しました 件数: \(array.count)")
            case let .failure(error):
                print("取得に失敗しました: \(error)")
        }
    })
```

or検索

```Swift
    // 一つ目のクエリの作成
    var query1 = NCMBQuery.getQuery(className: "test")
    query1.where(field: "fieldB", equalTo: "日本語の内容")

    // 二つ目のクエリの作成
    var query2 = NCMBQuery.getQuery(className: "test")
    query2.where(field: "fieldC", lessThan: 50)

    // OR検索を行うためにクエリを合成する
    let query = NCMBQuery.orQuery(query1, query2)

    // 検索を行う
    query.findInBackground(callback: { result in
        switch result {
            case let .success(array):
                print("取得に成功しました 件数: \(array.count)")
            case let .failure(error):
                print("取得に失敗しました: \(error)")
        }
    })
```

### プッシュ通知

#### 配信端末情報の登録

`AppDelegate.swift` 内に記述

```Swift
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        // 配信端末インスタンスの作成
        let installation : NCMBInstallation = NCMBInstallation.currentInstallation

        // デバイストークンの設定
        installation.setDeviceTokenFromData(data: deviceToken)

        // 配信端末の登録
        installation.saveInBackground(callback: { result in
            switch result {
                case .success:
                    print("保存に成功しました")
                case let .failure(error):
                    print("保存に失敗しました: \(error)")
                    return;
            }
        })
    }
```

#### プッシュ通知をアプリから送信する

```Swift
    // プッシュ通知オブジェクトの作成
    let push : NCMBPush = NCMBPush()
    // メッセージの設定
    push.message = "プッシュ通知です"
    // iOS端末を送信対象に設定する
    push.isSendToIOS = true
    // android端末を送信対象に設定する
    push.isSendToAndroid = true
    // 即時配信を設定する
    push.setImmediateDelivery()

    // プッシュ通知を配信登録する
    push.sendInBackground(callback: { result in
        switch result {
            case .success:
                print("登録に成功しました。プッシュID: \(push.objectId!)")
            case let .failure(error):
                print("登録に失敗しました: \(error)")
                return;
        }
    })
```

#### プッシュ通知のスケジューリング

```Swift
    // プッシュ通知オブジェクトの作成
    let push : NCMBPush = NCMBPush()
    // メッセージの設定
    push.message = "プッシュ通知です"
    // iOS端末を送信対象に設定する
    push.isSendToIOS = true
    // android端末を送信対象に設定する
    push.isSendToAndroid = true
    // 配信時刻を設定する
    let formatter : DateFormatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    push.deliveryTime = formatter.date(from: "2020-07-24T10:10:01.964Z")

    // プッシュ通知を配信登録する
    push.sendInBackground(callback: { result in
        switch result {
            case .success:
                print("登録に成功しました。プッシュID: \(push.objectId!)")
            case let .failure(error):
                print("登録に失敗しました: \(error)")
                return;
        }
    })
```

#### 配信端末の絞り込み

* TBD

### 会員管理

#### ユーザーの新規登録

```Swift
    //　Userインスタンスの生成
    let user = NCMBUser()

    // ユーザー名・パスワードを設定
    user.userName = "takanokun"
    user.password = "openGoma"

    // ユーザーの新規登録
    user.signUpInBackground(callback: { result in
        switch result {
            case .success:
                // 新規登録に成功した場合の処理
                print("新規登録に成功しました")
            case let .failure(error):
                // 新規登録に失敗した場合の処理
                print("新規登録に失敗しました: \(error)")
        }
    })
```

#### 会員登録用のメールを要求する

```Swift
    // 会員登録用メールを要求する
    let result = NCMBUser.requestAuthenticationMailInBackground(mailAddress: "takanokun@example.com", callback: { result in
        switch result {
            case .success:
                // 会員登録用メールの要求に成功した場合の処理
                print("会員登録用メールの要求に成功しました")
            case let .failure(error):
                // 会員登録用のメール要求に失敗した場合の処理
                print("会員登録用メールの要求に失敗しました: \(error)")
        }
    })
```

#### ログイン

ユーザー名、パスワードでのログイン

```Swift
    // ログイン状況の確認
    if let user = NCMBUser.currentUser {
        print("ログインしています。ユーザー: \(user.userName!)")
    } else {
        print("ログインしていません")
    }

    // ログイン
    NCMBUser.logInInBackground(userName: "takanokun", password: "openGoma", callback: { result in
        switch result {
            case .success:
                // ログインに成功した場合の処理
                print("ログインに成功しました")

                // ログイン状況の確認
                if let user = NCMBUser.currentUser {
                    print("ログインしています。ユーザー: \(user.userName!)")
                } else {
                    print("ログインしていません")
                }

            case let .failure(error):
                // ログインに失敗した場合の処理
                print("ログインに失敗しました: \(error)")
        }
    })
```

メールアドレス、パスワードでのログイン

```Swift
    // ログイン状況の確認
    if let user = NCMBUser.currentUser {
        print("ログインしています。ユーザー: \(user.userName!)")
    } else {
        print("ログインしていません")
    }

    // ログイン
    NCMBUser.logInInBackground(mailAddress: "takanokun@example.com", password: "openGoma", callback: { result in
        switch result {
            case .success:
                // ログインに成功した場合の処理
                print("ログインに成功しました")

                // ログイン状況の確認
                if let user = NCMBUser.currentUser {
                    print("ログインしています。ユーザー: \(user.userName!)")
                } else {
                    print("ログインしていません")
                }

            case let .failure(error):
                // ログインに失敗した場合の処理
                print("ログインに失敗しました: \(error)")
        }
    })
```

#### ログアウト

```Swift
    // ログイン状況の確認
    if let user = NCMBUser.currentUser {
        print("ログインしています。ユーザー: \(user.userName!)")
    } else {
        print("ログインしていません")
    }

    // ログアウト
    NCMBUser.logOut(callback: { result in
        switch result {
            case .success:
                // ログアウトに成功した場合の処理
                print("ログアウトに成功しました")

                // ログイン状況の確認
                if let user = NCMBUser.currentUser {
                    print("ログインしています。ユーザー: \(user.userName!)")
                } else {
                    print("ログインしていません")
                }

            case let .failure(error):
                // ログアウトに失敗した場合の処理
                print("ログアウトに失敗しました: \(error)")
        }
    })
```

#### パスワードのリセット

```Swift
    // パスワードのリセット
    NCMBUser.requestPasswordResetInBackground(mailAddress: "takanokun@example.com", callback: { result in
        switch result {
            case .success:
                // パスワードのリセット処理登録に成功した場合の処理
                print("パスワードのリセット処理登録に成功しました")
            case let .failure(error):
                // パスワードのリセット処理登録に失敗した場合の処理
                print("パスワードのリセット処理登録に失敗しました: \(error)")
        }
    })
```

#### メールアドレス確認の有無

* TBD


#### 匿名認証

```Swift
    // ログイン状況の確認
    if let user = NCMBUser.currentUser {
        print("ログインしています。ユーザー: \(user.userName!)")
    } else {
        print("ログインしていません")
    }

    // 匿名ユーザの自動生成を有効化
    NCMBUser.enableAutomaticUser()

    // 匿名ユーザーでのログイン
    let result = NCMBUser.automaticCurrentUserInBackground(callback: { result in
        switch result {
            case .success:
                // ログインに成功した場合の処理
                print("ログインに成功しました")

                // ログイン状況の確認
                if let user = NCMBUser.currentUser {
                    print("ログインしています。ユーザー: \(user.userName!)")

                    // 匿名ユーザーでログインしているかの確認
                    if NCMBAnonymousUtils.isLinked(user: user) {
                        print("匿名ユーザーです。")
                    } else {
                        print("匿名ユーザーではありません。")
                    }

                } else {
                    print("ログインしていません")
                }

            case let .failure(error):
                // ログインに失敗した場合の処理
                print("ログインに失敗しました: \(error)")
        }
    })
```

#### 会員のグルーピング

* TBD

### ファイルストア

#### ファイルストアへのアップロード

```Swift
    // アップロード対象のデータ
    let data : Data

    // ファイルオブジェクトの作成
    let file : NCMBFile = NCMBFile(fileName: "Takanokun.txt")

    // アップロード
    file.saveInBackground(data: data, callback: { result in
        switch result {
            case .success:
                print("保存に成功しました")
            case let .failure(error):
                print("保存に失敗しました: \(error)")
                return;
        }
    })
```

#### ファイルを取得する

```Swift
    // ファイルオブジェクトの作成
    let file : NCMBFile = NCMBFile(fileName: "Takanokun.txt")

    // ファイルの取得
    file.fetchInBackground(callback: { result in
        switch result {
            case let .success(data):
                print("取得に成功しました: \(data)")
            case let .failure(error):
                print("取得に失敗しました: \(error)")
                return;
        }
    })
```


#### ファイルの削除

```Swift
    // ファイルオブジェクトの作成
    let file : NCMBFile = NCMBFile(fileName: "Takanokun.txt")

    // ファイルの削除
    file.deleteInBackground(callback: { result in
        switch result {
            case .success:
                print("削除に成功しました")
            case let .failure(error):
                print("削除に失敗しました: \(error)")
                return;
        }
    })
```

### スクリプト

#### スクリプト実行

```Swift
    // スクリプトインスタンスの作成
    let script = NCMBScript(name: "myCoolScript.js", method: .get)

    // スクリプトの実行
    script.executeInBackground(headers: [:], queries: ["name": "foo"], body: nil, callback: { result in
        switch result {
            case let .success(data):
                print("scriptSample 実行に成功しました: \(data)")
            case let .failure(error):
                print("scriptSample 実行に失敗しました: \(error)")
                return;
        }
    })
```
