//
//  LoginViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/24.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextFiled: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light

        loginButton.layer.cornerRadius = 8
        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
        emailTextField.delegate = self
        passwordTextFiled.delegate = self
        
        emailTextField.keyboardType = .emailAddress
        passwordTextFiled.keyboardType = .emailAddress
        
    }
    
    
    @objc private func tappedDontHaveAccountButton() {
        let storyboar = UIStoryboard(name: "SingUp", bundle: nil)
        let FirestViewController = storyboar.instantiateViewController(identifier: "FirestViewController") as! FirestViewController
        FirestViewController.modalPresentationStyle = .fullScreen
        self.present(FirestViewController, animated: true, completion: nil)
    }
    
    @objc private func tappedLoginButton() {
        SVProgressHUD.show()
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextFiled.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("ログインに失敗しました。\(err)")
                SVProgressHUD.showError(withStatus: "有効なメールアドレスまたは,パスワードではありません")

                return
            }
            print("DEBUG_PRINT: ログインに成功しました。")
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "ログインしました！")

            
            let storyboar = UIStoryboard(name: "Home", bundle: nil)
            let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
            let nav = UINavigationController(rootViewController: homeViewController)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .coverVertical
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
