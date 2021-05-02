//
//  SingUpViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/21.
//

import UIKit
import Firebase
import SVProgressHUD

class SingUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var passwordTextFiled: UITextField!
    @IBOutlet weak var usernameTextFiled: UITextField!
    @IBOutlet weak var RegisterButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        
        settingDefault()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func settingDefault() {
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        RegisterButton.layer.cornerRadius = 10
        
        profileImageButton.addTarget(self, action: #selector(tappedProfileImageButton), for: .touchUpInside)
        alreadyHaveAccountButton.addTarget(self, action: #selector(alredyHaveAccountButton), for: .touchUpInside)
        
        emailTextFiled.delegate = self
        passwordTextFiled.delegate = self
        usernameTextFiled.delegate = self
        
        emailTextFiled.keyboardType = .emailAddress
        passwordTextFiled.keyboardType = .emailAddress
        usernameTextFiled.keyboardType = .namePhonePad
        
        RegisterButton.isEnabled = false
        RegisterButton.backgroundColor = .rgb(red: 150, green: 150, blue: 150)
        RegisterButton.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
        
        //キーボードの出現を知らせてくれる
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 150
            } else {
            }
        }
    }
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @objc private func tappedProfileImageButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func alredyHaveAccountButton() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        LoginViewController.modalPresentationStyle = .fullScreen
        present(LoginViewController, animated: true, completion: nil)
    }
    
    @objc private func tappedRegisterButton() {
        createUser()
    }
    
    private func createUser() {
        guard let email = emailTextFiled.text else { return }
        guard let password = passwordTextFiled.text else { return }
        
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: email, password: password) { res, err in
            if let err = err {
                SVProgressHUD.dismiss()
                print("***err",err)
                SVProgressHUD.showError(withStatus: "有効なメールアドレスまたは,パスワードではありません")
                return

            }
            guard let uid = res?.user.uid else { return }
            guard let username = self.usernameTextFiled.text else { return }
            
            let user = Auth.auth().currentUser
            if let user = user {
                let changRequest = user.createProfileChangeRequest()
                changRequest.displayName = username
                changRequest.commitChanges { err in
                    if let err = err {
                        print("***error",err)
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showError(withStatus: "有効なメールアドレスまたはパスワードではありません")
                        return
                    }
                }
            }
            print("***認証情報の保存に成功しました。")
            
            let db = Firestore.firestore()
            let chatroomRef = db.collection(Const.ChatRooms).document(uid)
            let chatroomDic = [
                "groupId": uid,
                "password": "",
                "passwordCheck": "",
                "date": Timestamp(),
                "membar": [],
                "groupName": "マイチャット",
                "groupProfileText": "",
                "myChat": true
            ] as [String : Any]
            chatroomRef.setData(chatroomDic) { err in
                if let err = err {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: "有効なメールアドレスまたはパスワードではありません")
                    print("***err",err)
                    return
                }
            }
            print("***マイチャットの作成に成功しました")
            
            let userRef = db.collection(Const.User).document(uid)
            let userDic = [
                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "uid": uid,
                "morningCount": 0,
                "doSupport": 0,
                "BedoneSupport": 0,
                "groupId": [uid],
                "profileText": ""
            ] as [String : Any]
            userRef.setData(userDic) { err in
                if let err = err {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: "有効なメールアドレスまたはパスワードではありません")
                    print("err",err)
                    return
                }
            }
            print("***userの情報の保存に成功しました")
            
            let image = self.profileImageButton.imageView?.image ?? UIImage(named: "男シルエットイラスト")
            //画像をjpgに変更
            guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
            //画像の保存場所を指定
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
            //storageに画像を保存する
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            imageRef.putData(uploadImage, metadata: metadata) { metadata, err in
                if let err = err {
                    SVProgressHUD.showError(withStatus: "有効なメールアドレスまたはパスワードではありません")
                    SVProgressHUD.dismiss()
                    print("***err",err)
                    return
                }
                print("***userの画像の保存に成功しました")
            }
            print("***新規登録の処理を完了しました")
            
            SVProgressHUD.dismiss()
            let storyboar = UIStoryboard(name: "Setting", bundle: nil)
            let chatroomSettingViewController = storyboar.instantiateViewController(identifier: "chatroomSettingViewController") as! chatroomSettingViewController
            let nav = UINavigationController(rootViewController: chatroomSettingViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
}

extension SingUpViewController:UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextFiled.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextFiled.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextFiled.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            RegisterButton.isEnabled = false
            RegisterButton.backgroundColor = .rgb(red: 150, green: 150, blue: 150)
        } else {
            RegisterButton.isEnabled = true
            RegisterButton.backgroundColor = .rgb(red: 0, green: 130, blue:255)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}


extension SingUpViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }
}




//Firest Screen
class FirestViewController: UIViewController {
    
    @IBOutlet weak var singUpButtonOutlet: UIButton!
    
    @IBAction func loginButton(_ sender: Any) {
        let storbor = UIStoryboard(name: "Login", bundle: nil)
        let LoginViewController = storbor.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        LoginViewController.modalPresentationStyle = .fullScreen
        present(LoginViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        setDefault()
    }
    
    private func setDefault() {
        singUpButtonOutlet.layer.cornerRadius = 10
        singUpButtonOutlet.layer.borderColor = UIColor.rgb(red: 100, green: 150, blue: 255).cgColor
        singUpButtonOutlet.layer.borderWidth = 1.0
        singUpButtonOutlet.addTarget(self, action: #selector(singUp), for: .touchUpInside)
    }
    
    @objc func singUp() {
        let storbor = UIStoryboard(name: "SingUp", bundle: nil)
        let AgreementViewController = storbor.instantiateViewController(identifier: "AgreementViewController") as! AgreementViewController
        let nav = UINavigationController(rootViewController: AgreementViewController)
        present(nav, animated: true, completion: nil)
    }
}



//利用規約のview
class AgreementViewController: UIViewController {
    @IBAction func endButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func agreementButton(_ sender: Any) {
        let storbor = UIStoryboard(name: "SingUp", bundle: nil)
        let SingUpViewController = storbor.instantiateViewController(identifier: "SingUpViewController") as! SingUpViewController
        SingUpViewController.modalPresentationStyle = .fullScreen
        present(SingUpViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light

        navigationController?.navigationBar.barTintColor = .rgb(red: 240, green: 240, blue: 255)
        self.navigationItem.title = "利用規約"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.rgb(red: 100, green: 150, blue: 255)
        ]
    }
}

