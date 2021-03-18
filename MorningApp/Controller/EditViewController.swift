//
//  EditViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/18.
//

import UIKit
import Firebase

class EditViewController: UIViewController, UIImagePickerControllerDelegate & UITextFieldDelegate ,UINavigationControllerDelegate, UITextViewDelegate {

    @IBAction func hiddenButton(_ sender: Any) {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let profileViewController = storyboar.instantiateViewController(identifier: "ProfileSettingViewController") as! ProfileSettingViewController
        let nav = UINavigationController(rootViewController: profileViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    @IBOutlet weak var groupImageButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()
        setFirebase()
    }
    
    private func setLayout() {
        groupImageButton.layer.cornerRadius = 80
        groupImageButton.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        groupImageButton.layer.borderWidth = 1.0
        groupImageButton.addTarget(self, action: #selector(tappedImageButton), for: .touchUpInside)
        userNameTextField.layer.cornerRadius = 10
        userNameTextField.layer.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        profileTextView.layer.cornerRadius = 5
        profileTextView.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        profileTextView.layer.borderWidth = 1.0
        profileTextView.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        navigationController?.navigationBar.backgroundColor = .rgb(red: 240, green: 240, blue: 255)
        view.backgroundColor = .rgb(red: 245, green: 245, blue: 245)
        saveButton.layer.cornerRadius = 10
        saveButton.isEnabled = false
        saveButton.backgroundColor = .rgb(red: 200, green: 200, blue: 200)
        saveButton.addTarget(self, action: #selector(tappedSaveButton), for: .touchUpInside)
        
        userNameTextField.delegate = self
        profileTextView.delegate = self
    }
    
    @objc func tappedImageButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func tappedSaveButton() {
        updateUser()
    }
    
    private func setFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection(Const.User).document(uid)
        userRef.getDocument { (doucuments,err) in
            if let err = err {
                print(err)
                return
            }
            guard let document = doucuments else { return }
            let userData = User(document: document)
            
            
            self.userNameTextField.text = userData.username
            if userData.profileText != "" {
                self.profileTextView.text = userData.profileText
            }
        }
    }
    
    private func updateUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection(Const.User).document(uid)
        guard let username = userNameTextField.text else { return }
        guard let profileText = profileTextView.text else { return }
        userRef.updateData([
            "username": username
        ])
        userRef.updateData([
            "profileText": profileText
        ])
        
        let user = Auth.auth().currentUser
        if let user = user {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges { error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
            }
        }
        
        guard let image = self.groupImageButton.imageView?.image else {
            print("画像の変更はありませんでした。")
            let storyboar = UIStoryboard(name: "Setting", bundle: nil)
            let profileViewController = storyboar.instantiateViewController(identifier: "ProfileSettingViewController") as! ProfileSettingViewController
            let nav = UINavigationController(rootViewController: profileViewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return
        }
        //画像をjpgに変更
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        //画像の保存場所を指定
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
        //storageに画像を保存する
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(uploadImage, metadata: metadata) { (metadata, err) in
            if let err = err {
                print("画像のアップロードに失敗しました。\(err)")
                return
            }
            print("DEBUG_PRINT: 画像の保存に成功しました。")
        }
        
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let profileViewController = storyboar.instantiateViewController(identifier: "ProfileSettingViewController") as! ProfileSettingViewController
        let nav = UINavigationController(rootViewController: profileViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            groupImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            groupImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        groupImageButton.setTitle("", for: .normal)
        groupImageButton.imageView?.contentMode = .scaleAspectFill
        groupImageButton.contentHorizontalAlignment = .fill
        groupImageButton.contentVerticalAlignment = .fill
        groupImageButton.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = true
        saveButton.backgroundColor = .rgb(red: 100, green: 150, blue: 250)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if userNameTextField.text?.isEmpty == true {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .rgb(red: 200, green: 200, blue: 200)
        } else {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .rgb(red: 100, green: 150, blue: 250)
        }
    }
}






class groupEditViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var groupImageButton: UIButton!
    @IBOutlet weak var groupNameTextFiled: UITextField!
    @IBOutlet weak var groupProfileTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func hidden(_ sender: Any) {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let groupProfileSettingViewController = storyboar.instantiateViewController(identifier: "groupProfileSettingViewController") as! groupProfileSettingViewController
        let nav = UINavigationController(rootViewController: groupProfileSettingViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    var groupName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setFirebase()
    }
    
    
    private func setLayout() {
        groupImageButton.layer.cornerRadius = 80
        groupImageButton.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        groupImageButton.layer.borderWidth = 1.0
        groupImageButton.addTarget(self, action: #selector(tappedImageButton), for: .touchUpInside)
        groupNameTextFiled.layer.cornerRadius = 10
        groupNameTextFiled.layer.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        groupProfileTextView.layer.cornerRadius = 5
        groupProfileTextView.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        groupProfileTextView.layer.borderWidth = 1.0
        groupProfileTextView.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        navigationController?.navigationBar.backgroundColor = .rgb(red: 240, green: 240, blue: 255)
        view.backgroundColor = .rgb(red: 245, green: 245, blue: 245)
        saveButton.layer.cornerRadius = 10
        saveButton.isEnabled = false
        saveButton.backgroundColor = .rgb(red: 200, green: 200, blue: 200)
        saveButton.addTarget(self, action: #selector(tappedSaveButton), for: .touchUpInside)
        
        groupNameTextFiled.delegate = self
        groupProfileTextView.delegate = self
    }
    
    @objc func tappedImageButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func tappedSaveButton() {
        updateGroup()
    }
    
    private func setFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection(Const.User).document(uid)
        userRef.getDocument { (doucuments,err) in
            if let err = err {
                print(err)
                return
            }
            guard let document = doucuments else { return }
            let userData = User(document: document)
            guard let groupName = userData.groupname else { return }
            self.groupName = groupName

            let groupRef = db.collection(Const.ChatRooms).document(groupName)
            groupRef.getDocument {(document,err) in
                if let err = err {
                    print("err",err)
                    return
                }
                if let document = document {
                    let groupName = document["groupName"] as? String
                    self.groupNameTextFiled.text = groupName
                    let groupProfileText = document["groupProfileText"] as? String
                    if groupProfileText != "" {
                        self.groupProfileTextView.text = groupProfileText
                    }
                }
            }
        }
    }
    
    private func updateGroup() {
        let db = Firestore.firestore()
        
        let groupRef = db.collection(Const.ChatRooms).document(groupName ?? "")
        guard let newGroupName = groupNameTextFiled.text else { return }
        guard let newGroupProfileText = groupProfileTextView.text else { return }
        groupRef.updateData([
            "groupName": newGroupName
        ])
        groupRef.updateData([
            "groupProfileText": newGroupProfileText
        ])

        guard let image = self.groupImageButton.imageView?.image else {
            print("画像の変更はありませんでした。")
            let storyboar = UIStoryboard(name: "Setting", bundle: nil)
            let profileViewController = storyboar.instantiateViewController(identifier: "ProfileSettingViewController") as! ProfileSettingViewController
            let nav = UINavigationController(rootViewController: profileViewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return
        }
        //画像をjpgに変更
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        //画像の保存場所を指定
        let imageRef = Storage.storage().reference().child(Const.GroupImage).child(groupName! + ".jpg")
        //storageに画像を保存する
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(uploadImage, metadata: metadata) { (metadata, err) in
            if let err = err {
                print("画像のアップロードに失敗しました。\(err)")
                return
            }
            print("DEBUG_PRINT: 画像の保存に成功しました。")
        }
        
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let groupProfileSettingViewController = storyboar.instantiateViewController(identifier: "groupProfileSettingViewController") as! groupProfileSettingViewController
        let nav = UINavigationController(rootViewController: groupProfileSettingViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            groupImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            groupImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        groupImageButton.setTitle("", for: .normal)
        groupImageButton.imageView?.contentMode = .scaleAspectFill
        groupImageButton.contentHorizontalAlignment = .fill
        groupImageButton.contentVerticalAlignment = .fill
        groupImageButton.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = true
        saveButton.backgroundColor = .rgb(red: 100, green: 150, blue: 250)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if groupNameTextFiled.text?.isEmpty == true {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .rgb(red: 200, green: 200, blue: 200)
        } else {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .rgb(red: 100, green: 150, blue: 250)
        }
    }
}