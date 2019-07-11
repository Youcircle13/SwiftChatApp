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
