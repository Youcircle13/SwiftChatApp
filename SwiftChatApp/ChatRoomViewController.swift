//
//  ChatRoomViewController.swift
//  SwiftChatApp
//
//  Created by yuma.saito on 2019/07/17.
//  Copyright © 2019 yuma.saito. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import NCMB

class ChatRoomViewController: JSQMessagesViewController {
    
    /***** 【NCMB】会員管理 カレントユーザー取得 *****/
    let user = NCMBUser.currentUser
    /***** 【NCMB】会員管理 カレントユーザー取得 *****/
    
    var messages: [JSQMessage] = []
    var msgList: [NCMBObject] = []
    var timer = Timer()
    //processing count
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 画面更新
        self.getMsg()
        
        self.messages = []

        /***** 取得したカレントユーザと紐づける *****/
        senderDisplayName = user?.userName
        senderId = user?.objectId
        /***** 取得したカレントユーザと紐づける *****/
    }
    
    // Sendボタンが押された時に呼ばれる
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        //キーボードを閉じる
        self.view.endEditing(true)
        //textFieldをクリアする
        self.inputToolbar.contentView.textView.text = ""
        
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
        
    }
    
    func getMsg(){
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
    }
    
    @IBAction func logoutBtn(_ sender: UIBarButtonItem) {
        /***** 【NCMB】会員管理 ログアウト *****/
        NCMBUser.logOut()
        /***** 【NCMB】会員管理 ログアウト *****/
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // メッセージを画面に表示
    func makeMsg(){
        for msgData in msgList{
            let messege = JSQMessage(senderId: msgData["sender"] ?? "senderId", displayName: msgData["userName"] ?? "userName" , text: msgData["messege"] ?? "msgText")
            self.messages.append(messege!)
        }
        self.finishReceivingMessage(animated: true)
        
    }
    
    func makeMyMsg(senderId: String, desplayName: String, message: String){
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: message)
        self.messages.append(message!)
        self.finishReceivingMessage(animated: true)
    }
    
    //アイテムごとに参照するメッセージデータを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {

        return messages[indexPath.row]
    }
    
    //各送信者の表示について
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUsername = message.senderDisplayName
        
        return NSAttributedString(string: messageUsername!)
    }
    
    //アイテムごとのMessageBubble(背景)を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        if messages[indexPath.row].senderId == senderId {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(
                with: UIColor(red: 0/255, green: 130/255, blue:  255/255, alpha: 1))
        } else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(
                with: UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
        }
    }
    
    // cell for item
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        if messages[indexPath.row].senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.darkGray
        }
        return cell
    }
    
    // 数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // image data for item
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let senderId = messages[indexPath.row].senderId
        
        /***** senderId == 自分　だった場合表示しない *****/

        /***** senderId == 自分　だった場合表示しない *****/
        
        // senderId != 自分だったら user.ong を表示する
        return JSQMessagesAvatarImage.avatar(with: UIImage(named: "user"))
    }
    
    //各メッセージの高さ
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //添付ファイルボタンが押された時の挙動
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
    }
    
    @IBAction func reloadBtn(_ sender: UIBarButtonItem) {
        self.getMsg()
    }
    
    // alert
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
}
