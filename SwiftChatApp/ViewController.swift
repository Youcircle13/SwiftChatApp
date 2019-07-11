//
//  ViewController.swift
//  SwiftChatApp
//
//  Created by yuma.saito on 2019/07/17.
//  Copyright © 2019 yuma.saito. All rights reserved.
//

import UIKit
import NCMB

class ViewController: UIViewController{
    
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var loginCheck:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 表示可能最大行数を指定 0で可変
        self.errorLabel.numberOfLines = 0
        
    }
    
    // Tap Login button
    @IBAction func LoginButton(_ sender: UIButton) {
        // 入力値
        let userName = self.UsernameTextField.text!
        let password = self.PasswordTextField.text!
        
        // 入力確認
        if userName.isEmpty || password.isEmpty {
            self.errorLabel.text = "未入力の項目があります"
            // TextFieldを空に
            cleanTextField()
            
            return
        }
        
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
        
    }
    
    //Tap Create Button.
    @IBAction func createButton(_ sender: Any) {
        //Transition Create Acount View.
        self.performSegue(withIdentifier: "toCreate", sender: nil)
    }
    
    //When screen tap.
    @IBAction func tapScreen(_ sender: Any) {
        //Hide Keyboad
        self.view.endEditing(true)
    }
    
    func cleanTextField(){
        UsernameTextField.text! = ""
        PasswordTextField.text! = ""
    }
    
}

