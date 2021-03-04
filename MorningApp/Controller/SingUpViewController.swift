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
       setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setUpViews() {
        
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        RegisterButton.layer.cornerRadius = 10
        
        profileImageButton.addTarget(self, action: #selector(tappedProfileImageButton), for: .touchUpInside)
        
        alreadyHaveAccountButton.addTarget(self, action: #selector(tappedAlredyHaveAccountButton), for: .touchUpInside)
        
        emailTextFiled.delegate = self
        passwordTextFiled.delegate = self
        usernameTextFiled.delegate = self
        
        RegisterButton.isEnabled = false
        RegisterButton.backgroundColor = .rgb(red: 150, green: 150, blue: 150)
        RegisterButton.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
    }
    
    @objc private func tappedProfileImageButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func tappedAlredyHaveAccountButton() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(LoginViewController, animated: true)
    }
    
    @objc private func tappedRegisterButton() {
        createUserToFiresore()
    }
    
    private func createUserToFiresore() {
        guard let email = emailTextFiled.text else { return }
        guard let password = passwordTextFiled.text else { return }
        
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                SVProgressHUD.dismiss()
                print("認証情報の保存に失敗しました。\(err)")
            }
            
            guard let uid = res?.user.uid else { return }
            guard let username = self.usernameTextFiled.text else { return }
            
            let user = Auth.auth().currentUser
            if let user = user {
                let changRequest = user.createProfileChangeRequest()
                changRequest.displayName = username
                changRequest.commitChanges { error in
                    if let error = error {
                        print("DEBUG_PRINT* \(error)")
                    }
                }
            }
            
            print(" DEBUG_PRINT: 認証情報の保存に成功しました。")
            
            
            let docData = [
                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "uid": uid
            ] as [String : Any]
            //uidをドキュメントに指定
            Firestore.firestore().collection("users").document(uid).setData(docData) {
                (err) in
                if let err = err {
                    SVProgressHUD.dismiss()
                    print("Firestoreへの保存に失敗しました。\(err)")
                    return
                }
            }
            
            print("DEBUG_PRINT: Firestoreへの情報の保存に成功しました。")
            
            let image = self.profileImageButton.imageView?.image ?? UIImage(named: "男シルエットイラスト")
            //画像をjpgに変更
            guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
            //画像の保存場所を指定
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
            //storageに画像を保存する
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            imageRef.putData(uploadImage, metadata: metadata) { (metadata, err) in
                if let err = err {
                    SVProgressHUD.dismiss()
                    print("画像のアップロードに失敗しました。\(err)")
                    return
                }
                
                print("DEBUG_PRINT: 画像の保存に成功しました。")
            }
            SVProgressHUD.dismiss()
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
  
}

extension SingUpViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
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


