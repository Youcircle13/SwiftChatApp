/*
 Copyright 2019 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

/// 会員情報を操作するためのクラスです。
public class NCMBUser : NCMBBase {
    static let CLASSNAME : String = "user"
    static let FIELDNAME_USER_NAME : String = "userName"
    static let FIELDNAME_PASSWORD : String = "password"
    static let FIELDNAME_MAIL_ADDRESS : String = "mailAddress"
    static let FIELDNAME_AUTH_DATA : String = "authData"
    static let FIELDNAME_SESSION_TOKEN : String = "sessionToken"
    static let FIELDNAME_MAIL_ADDRESS_CONFIRM : String = "mailAddressConfirm"
    static let FIELDNAME_TEMPORARY_PASSWORD : String = "temporaryPassword"

    /// 現在ログインユーザー
    static var _currentUser : NCMBUser? = nil
    private static var isEnableAutomaticUser : Bool = false

    /// コンストラクタです。
    public init() {
        super.init(className: NCMBUser.CLASSNAME)
    }

    /// コンストラクタです。
    /// このコンストラクタは変更フィールドを正しく把握するためにモジュール外での利用は許可しません。
    ///
    /// - Parameter className: データストアのクラス名
    /// - Parameter fields: フィールド内容
    /// - Parameter modifiedFieldKeys: 更新フィールド名一覧
    required init(className: String, fields: [String : Any], modifiedFieldKeys: Set<String> = []) {
        super.init(className: className, fields: fields, modifiedFieldKeys: modifiedFieldKeys)
    }

    /// ログインユーザーのセッショントークンです。
    public class var currentUserSessionToken : String? {
        if let user : NCMBUser = _currentUser {
            return user[FIELDNAME_SESSION_TOKEN]
        }
        return nil
    }

    /// ユーザー情報をコピーしたものです。
    override var copy : NCMBUser {
        get {
            let user = NCMBUser(className: self.className, fields: self.fields, modifiedFieldKeys: self.modifiedFieldKeys)
            return user
        }
    }

    /// セッショントークンです。
    public var sessionToken : String? {
        get {
            return self[NCMBUser.FIELDNAME_SESSION_TOKEN]
        }
    }

    /// ユーザー名です。
    public var userName : String? {
        get {
            return self[NCMBUser.FIELDNAME_USER_NAME]
        }
        set {
            self[NCMBUser.FIELDNAME_USER_NAME] = newValue
        }
    }

    /// パスワードです。
    public var password : String? {
        get {
            return self[NCMBUser.FIELDNAME_PASSWORD]
        }
        set {
            self[NCMBUser.FIELDNAME_PASSWORD] = newValue
        }
    }

    /// メールアドレスです。
    public var mailAddress : String? {
        get {
            return self[NCMBUser.FIELDNAME_MAIL_ADDRESS]
        }
        set {
            self[NCMBUser.FIELDNAME_MAIL_ADDRESS] = newValue
        }
    }

    /// 認証情報です。
    var authData : [String : Any]? {
        get {
            if let authData : Any = self[NCMBUser.FIELDNAME_AUTH_DATA] {
                if let authData = authData as? [String : Any] {
                    return authData
                }
            }
            return nil
        }
        set {
            self[NCMBUser.FIELDNAME_AUTH_DATA] = newValue
        }
    }

    /// 会員情報を検索するためのクエリです。
    public class var query : NCMBQuery<NCMBUser> {
        get {
            return NCMBQuery<NCMBUser>(service: NCMBUserService())
        }
    }

    /// ログインユーザー情報を返します。
    public class var currentUser : NCMBUser? {
        get {
            if let currentUser = _currentUser {
                return currentUser
            }
            if let user : NCMBUser = NCMBUser.loadFromFile() {
                _currentUser = user
                return user
            }
            return nil
        }
    }

    /// ユーザが認証済みかを表します。
    /// 認証済みの場合は `true` 、それ以外では `false`
    public var isAuthenticated : Bool {
        get {
            return self.sessionToken != nil
        }
    }

    /// anonymous認証による自動会員登録を同期処理にて実行します。
    ///
    /// - Returns: リクエストが成功した場合は `.success<NCMBUser>` 、 失敗した場合は `.failure<Error>`
    public class func automaticCurrentUser() -> NCMBResult<NCMBUser> {
        var result : NCMBResult<NCMBUser> = NCMBResult.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        automaticCurrentUserInBackground(callback: {(res: NCMBResult<NCMBUser>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// anonymous認証による自動会員登録を非同期処理にて実行します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public class func automaticCurrentUserInBackground(callback: @escaping NCMBHandler<NCMBUser>) -> Void {
        if let currentUser = NCMBUser.currentUser {
            callback(NCMBResult.success(currentUser))
        } else if NCMBUser.isEnableAutomaticUser {
            NCMBAnonymousUtils.login(callback: { (result: NCMBResult<NCMBUser>) -> Void in
                switch result {
                    case let .success(user):
                        NCMBUser.isEnableAutomaticUser = false
                        callback( NCMBResult<NCMBUser>.success(user))
                        break
                    case let .failure(error):
                        callback( NCMBResult<NCMBUser>.failure(error))
                        break
                }
            })
        } else {
            callback( NCMBResult<NCMBUser>.failure(NCMBUserError.automaticUserNotAvailable))
        }
    }

    /// 匿名ユーザの自動生成を有効化します。
    public class func enableAutomaticUser() -> Void {
        isEnableAutomaticUser = true
    }

    /// 匿名ユーザの自動生成を無効化します。
    public class func disableAutomaticUser() -> Void {
        isEnableAutomaticUser = false
    }

    /// 設定された内容から会員情報を同期処理にて登録します。
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func signUp() -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        signUpInBackground(callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 設定された内容から会員情報を非同期処理にて登録します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func signUpInBackground(callback: @escaping NCMBHandler<Void>) -> Void {
        NCMBUserService().save(object: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    self.reflectResponse(response: response)
                    NCMBUser._currentUser = self
                    self.saveToFile()
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// 指定メールアドレスに対して、会員登録を行うためのメールを送信します。
    ///
    /// - Parameter mailAddress: メールアドレス
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public class func requestAuthenticationMail(mailAddress: String) -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        requestAuthenticationMailInBackground(mailAddress: mailAddress, callback: {
                (res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 指定メールアドレスに対して、会員登録を行うためのメールを送信します。
    ///
    /// - Parameter mailAddress: メールアドレス
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public class func requestAuthenticationMailInBackground(mailAddress: String, callback: @escaping NCMBHandler<Void>) -> Void {
        var object : [String : Any] = [:]
        object[FIELDNAME_MAIL_ADDRESS] = mailAddress
        NCMBRequestMailAddressUserEntryService().send(
                object: object,
                callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case .success(_):
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// ログインを同期処理にて行います。
    ///
    /// - Parameter userName: ユーザー名
    /// - Parameter password: パスワード
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public class func logIn(userName: String, password: String) -> NCMBResult<Void> {
        return logIn(userName: userName, mailAddress: nil, password: password)
    }

    /// ログインを非同期処理にて行います。
    ///
    /// - Parameter userName: ユーザー名
    /// - Parameter password: パスワード
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public class func logInInBackground(userName: String, password: String, callback: @escaping NCMBHandler<Void>) -> Void {
        logInInBackground(userName: userName, mailAddress: nil, password: password, callback: callback)
    }

    /// ログインを同期処理にて行います。
    ///
    /// - Parameter mailAddress: メールアドレス
    /// - Parameter password: パスワード
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public class func logIn(mailAddress: String, password: String) -> NCMBResult<Void> {
        return logIn(userName: nil, mailAddress: mailAddress, password: password)
    }

    /// ログインを非同期処理にて行います。
    ///
    /// - Parameter mailAddress: メールアドレス
    /// - Parameter password: パスワード
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public class func logInInBackground(mailAddress: String, password: String, callback: @escaping NCMBHandler<Void>) -> Void {
        logInInBackground(userName: nil, mailAddress: mailAddress, password: password, callback: callback)
    }

    /// ログインを行います。
    ///
    /// - Parameter userName: ユーザー名
    /// - Parameter mailAddress: メールアドレス
    /// - Parameter password: パスワード
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    class func logIn(userName: String?, mailAddress: String?, password: String) -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        logInInBackground(userName: userName, mailAddress: mailAddress, password: password, callback: {
                (res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// ログインを行います。
    ///
    /// - Parameter userName: ユーザー名
    /// - Parameter mailAddress: メールアドレス
    /// - Parameter password: パスワード
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    class func logInInBackground(
            userName: String?,
            mailAddress: String?,
            password: String,
            callback: @escaping NCMBHandler<Void>) -> Void {
        var queryItems : [String : String?] = [:]
        if let userName : String = userName {
            queryItems[FIELDNAME_USER_NAME] = userName
        }
        if let mailAddress : String = mailAddress {
            queryItems[FIELDNAME_MAIL_ADDRESS] = mailAddress
        }
        queryItems[FIELDNAME_PASSWORD] = password
        NCMBLoginService().logIn(
                queryItems: queryItems,
                callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    let user : NCMBUser = NCMBUser()
                    user.reflectResponse(response: response)
                    _currentUser = user
                    user.saveToFile()
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// ログアウトを同期処理にて行います。
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public class func logOut() -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        logOutInBackground(callback: {
                (res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// ログアウトを非同期処理にて行います。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public class func logOutInBackground(callback: @escaping NCMBHandler<Void>) -> Void {
        NCMBLogoutService().logOut(callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case .success(_):
                    deleteFile()
                    _currentUser = nil
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// 指定メールアドレスに該当する会員に対して、パスワード再発行を行うためのメールを送信するためのリクエストを同期処理にて行います。
    ///
    /// - Parameter mailAddress: メールアドレス
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public class func requestPasswordReset(mailAddress: String) -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        requestPasswordResetInBackground(mailAddress: mailAddress, callback: {
                (res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 指定メールアドレスに該当する会員に対して、パスワード再発行を行うためのメールを送信するためのリクエストを非同期処理にて行います。
    ///
    /// - Parameter mailAddress: メールアドレス
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public class func requestPasswordResetInBackground(mailAddress: String, callback: @escaping NCMBHandler<Void>) -> Void {
        var object : [String : Any] = [:]
        object[FIELDNAME_MAIL_ADDRESS] = mailAddress
        NCMBRequestPasswordResetService().send(
                object: object,
                callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case .success(_):
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// 設定されたオブジェクトIDに対応する会員情報を同期処理にて取得します。
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    func fetch() -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        fetchInBackground(callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 設定されたオブジェクトIDに対応する会員情報を非同期処理にて取得します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func fetchInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBUserService().fetch(
                object: self,
                callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    self.removeAllFields()
                    self.reflectResponse(response: response)
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// 会員情報を同期処理にて保存します。
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func save() -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        saveInBackground(callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 会員情報を非同期処理にて保存します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func saveInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        if self.objectId == nil {
            callback(NCMBResult<Void>.failure(NCMBInvalidRequestError.emptyObjectId))
            return;
        }
        // セッショントークンを削除したユーザーを用意
        let tmpuser = self.removeSessionToken()
        NCMBInstallationService().save(object: tmpuser, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    self.reflectResponse(response: response)
                    if self.isCurrentUser() {
                        self.saveToFile()
                    }
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// 設定されたオブジェクトIDに対応する会員情報を同期処理にて削除します。
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func delete() -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        deleteInBackground(callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 設定されたオブジェクトIDに対応する会員情報を非同期処理にて削除します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func deleteInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBUserService().delete(
                object: self,
                callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case .success(_):
                    if self.isCurrentUser() {
                        NCMBUser.deleteFile()
                    }
                    self.removeAllFields()
                    self.removeAllModifiedFieldKeys()
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// ログインユーザーかを判定します。
    ///
    /// - Returns: ログインユーザーの場合は `true` 、それ以外では `false`
    private func isCurrentUser() -> Bool {
        if let selfObjectId = self.objectId {
            if let currentUser = NCMBUser.currentUser {
                if let currentObjectId = currentUser.objectId {
                    return selfObjectId == currentObjectId
                }
            }
        }
        return false
    }

    /// ローカルファイルからログインユーザー情報を取得します。
    ///
    /// - Returns: ローカルファイルから取得したログインユーザー情報
    class func loadFromFile() -> NCMBUser? {
        let manager : NCMBLocalFileManagerProtocol = NCMBLocalFileManagerFactory.getInstance()
        let data : Data? = manager.loadFromFile(target: .currentUser)
        if let data : Data = data {
            do {
                let fields : [String : Any] = try NCMBJsonConverter.convertToKeyValue(data)
                return NCMBUser(className: NCMBInstallation.CLASSNAME, fields: fields)
            } catch let error {
                NSLog("NCMB: Failed to acquire local file with current user : \(error)")
                return nil
            }
        }
        return nil
    }

    /// ログインユーザー情報をローカルファイルに保存します。
    func saveToFile() -> Void {
        let manager : NCMBLocalFileManagerProtocol = NCMBLocalFileManagerFactory.getInstance()
        do {
            let data : Data? = try self.toJson()
            if let data : Data = data {
                manager.saveToFile(data: data, target: .currentUser)
            }
        } catch let error {
            NSLog("NCMB: Failed to save local file with current user : \(error)")
        }
    }

    /// ローカルに保存されているログインユーザー情報を削除します。
    class func deleteFile() -> Void {
        let manager : NCMBLocalFileManagerProtocol = NCMBLocalFileManagerFactory.getInstance()
        manager.deleteFile(target: .currentUser)
    }

    /// セッショントークンを除去したユーザーを返します。
    ///
    /// - Returns: セッショントークンを除去したユーザー
    func removeSessionToken() -> NCMBUser {
        var fields : [String : Any] = self.fields
        var modifiedFieldKeys : Set<String> = self.modifiedFieldKeys
        fields[NCMBUser.FIELDNAME_SESSION_TOKEN] = nil
        modifiedFieldKeys.remove(NCMBUser.FIELDNAME_SESSION_TOKEN)
        let tmpuser = NCMBUser(className: NCMBUser.CLASSNAME, fields: fields, modifiedFieldKeys: modifiedFieldKeys)
        return tmpuser
    }

}