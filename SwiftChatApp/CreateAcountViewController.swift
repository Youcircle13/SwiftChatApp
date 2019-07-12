//
//  CreateAcountViewController.swift
//  SwiftChatApp
//
//  Created by yuma.saito on 2019/07/17.
//  Copyright © 2019 yuma.saito. All rights reserved.
//

import UIKit
import NCMB

class CreateAcountViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //表示可能最大行数を指定 0で可変
        self.errorLabel.numberOfLines = 0
        
    }
    
    @IBAction func createButton(_ sender: Any) {
        
        self.errorLabel.text = "作成中"
        
        // 入力確認
        if self.userNameTextField.text!.isEmpty || self.passwordTextField.text!.isEmpty || self.rePasswordTextField.text!.isEmpty {
            self.errorLabel.text = "未入力の項目があります"
            //contentsのサイズに合わせてobujectのサイズを変える
            self.errorLabel.sizeToFit()
            // TextFieldを空に
            cleanTextField()
            return
        }
        
        // 入力確認
        if  self.passwordTextField.text! != self.rePasswordTextField.text!{
            
            self.errorLabel.text = "パスワードの値が異なります"
            //contentsのサイズに合わせてobujectのサイズを変える
            self.errorLabel.sizeToFit()
            // TextFieldを空に
            cleanTextField()
            
            return
        }
        
        /***** 【NCMB】会員管理 新規登録 *****/
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
        /***** 【NCMB】会員管理 新規登録 *****/
        
    }
    
    @IBAction func backButtonFromCreate(_ sender: Any) {
        //Back seguem
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapScreen(_ sender: Any) {
        //Hide Keyboad
        self.view.endEditing(true)
    }
    
    func cleanTextField(){
        userNameTextField.text! = ""
        passwordTextField.text! = ""
        rePasswordTextField.text! = ""
    }

}
