//
//  EditViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/18.
//

import UIKit
import Firebase
import FirebaseUI

class EditViewController: UIViewController, UIImagePickerControllerDelegate & UITextFieldDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBAction func hiddenButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        self.overrideUserInterfaceStyle = .light

        super.viewDidLoad()

        setLayout()
        setFirebase()
 
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 150
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setLayout() {
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        profileImageButton.layer.borderWidth = 1.0
        profileImageButton.addTarget(self, action: #selector(tappedImageButton), for: .touchUpInside)
        userNameTextField.layer.cornerRadius = 10
        userNameTextField.layer.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        profileTextView.layer.cornerRadius = 5
        profileTextView.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        profileTextView.layer.borderWidth = 1.0
        profileTextView.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        navigationController?.navigationBar.backgroundColor = .rgb(red: 240, green: 240, blue: 255)
        view.backgroundColor = .rgb(red: 245, green: 245, blue: 245)
        self.navigationItem.title = "ユーザーを編集"
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.rgb(red: 100, green: 150, blue: 255)
        ]
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
        
        guard let image = self.profileImageButton.imageView?.image else {
            print("***画像の変更はありませんでした。")
            let storyboar = UIStoryboard(name: "Home", bundle: nil)
            let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
            let nav = UINavigationController(rootViewController: homeViewController)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .coverVertical
            self.present(nav, animated: true, completion: nil)
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
            SDImageCache.shared.clearMemory()
            SDImageCache.shared.clearDisk()
        }
        
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .overFullScreen
        nav.modalTransitionStyle = .coverVertical
        present(nav, animated: true, completion: nil)
    }
    
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





//グループ編集画面
class groupEditViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var groupImageButton: UIButton!
    @IBOutlet weak var groupNameTextFiled: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var groupProfileTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func hidden(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var groupId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light

        setLayout()
        setFirebase()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 180
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setLayout() {
        groupImageButton.layer.cornerRadius = 25
        groupImageButton.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        groupImageButton.layer.borderWidth = 1.0
        groupImageButton.addTarget(self, action: #selector(tappedImageButton), for: .touchUpInside)
        groupNameTextFiled.layer.cornerRadius = 10
        groupNameTextFiled.layer.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        groupProfileTextView.layer.cornerRadius = 5
        groupProfileTextView.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        groupProfileTextView.layer.borderWidth = 1.0
        groupProfileTextView.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        navigationController?.navigationBar.backgroundColor = .rgb(red: 240, green: 240, blue: 255)
        self.navigationItem.title = "グループを編集"
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.rgb(red: 100, green: 150, blue: 255)
        ]
        view.backgroundColor = .rgb(red: 245, green: 245, blue: 245)
        saveButton.layer.cornerRadius = 10
        saveButton.isEnabled = false
        saveButton.backgroundColor = .rgb(red: 200, green: 200, blue: 200)
        saveButton.addTarget(self, action: #selector(tappedSaveButton), for: .touchUpInside)
        
        groupNameTextFiled.delegate = self
        passwordTextField.delegate = self
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
        let db = Firestore.firestore()
        let groupRef = db.collection(Const.ChatRooms).document(groupId!)
        groupRef.getDocument {(document,err) in
            if let err = err {
                print("err",err)
                return
            }
            if let document = document {
                let groupName = document["groupName"] as? String
                let groupPassword = document["password"] as? String
                self.groupNameTextFiled.text = groupName
                self.passwordTextField.text = groupPassword
                let groupProfileText = document["groupProfileText"] as? String
                if groupProfileText != "" {
                    self.groupProfileTextView.text = groupProfileText
                }
            }
        }
    }
    
    private func updateGroup() {
        let db = Firestore.firestore()
        
        let groupRef = db.collection(Const.ChatRooms).document(groupId!)
        guard let newGroupName = groupNameTextFiled.text else { return }
        guard let newGroupProfileText = groupProfileTextView.text else { return }
        guard let newGroupPassword = passwordTextField.text else { return }
        groupRef.updateData([
            "groupName": newGroupName,
            "groupProfileText": newGroupProfileText,
            "password": newGroupPassword
        ])

        guard let image = self.groupImageButton.imageView?.image else {
            print("***画像の変更はありませんでした。")
            let storyboar = UIStoryboard(name: "Home", bundle: nil)
            let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
            let nav = UINavigationController(rootViewController: homeViewController)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .coverVertical
            present(nav, animated: true, completion: nil)
            return
        }
        //画像をjpgに変更
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        //画像の保存場所を指定
        let imageRef = Storage.storage().reference().child(Const.GroupImage).child(groupId! + ".jpg")
        //storageに画像を保存する
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(uploadImage, metadata: metadata) { (metadata, err) in
            if let err = err {
                print("画像のアップロードに失敗しました。\(err)")
                return
            }
            print("DEBUG_PRINT: 画像の保存に成功しました。")
            SDImageCache.shared.clearMemory()
            SDImageCache.shared.clearDisk()
        }
       
        print("呼ばれている")
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .overFullScreen
        nav.modalTransitionStyle = .coverVertical
        self.present(nav, animated: true, completion: nil)
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





//グループ選択画面
class groupSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var groupSelectTableView: UITableView!
    
    @IBAction func groupAddButton(_ sender: Any) {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let chatroomSettingViewController = storyboar.instantiateViewController(identifier: "chatroomSettingViewController") as! chatroomSettingViewController
        let nav = UINavigationController(rootViewController: chatroomSettingViewController)
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func dissmisButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    var group = [Group]()
    var groupIdList = [String]()
    var listener: ListenerRegistration?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light

        groupSelectTableView.delegate = self
        groupSelectTableView.dataSource = self
        groupSelectTableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "cell")
        navigationController?.navigationBar.barTintColor = .rgb(red: 240, green: 240, blue: 255)
        self.navigationItem.title = "グループを選択"
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.rgb(red: 100, green: 150, blue: 255)
        ]
        setFirestore()
    
    }
  
    private func setFirestore() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userRef = db.collection(Const.User).document(uid)
        userRef.getDocument() { (document,err) in
            if let err = err {
                print("***err",err)
                return
            }
            let userData = document?.data()
            self.groupIdList = userData?["groupId"] as! [String]
            self.groupIdList.removeAll(where: {$0 == uid})
            
            for groupId in self.groupIdList {
                let groupRef = db.collection(Const.ChatRooms).document(groupId)
                groupRef.getDocument() {(document,err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    guard let document = document else {return}
                    self.group.append(Group(docu: document))
                    self.groupSelectTableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupSelectTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GroupCell
        cell.setGroupData(group[indexPath.row])
        return cell

    }
    
    //選択したセルが呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let groupProfileSettingViewController = storyboar.instantiateViewController(identifier: "groupProfileSettingViewController") as! groupProfileSettingViewController
        groupProfileSettingViewController.groupId = groupIdList[indexPath.row]
        let nav = UINavigationController(rootViewController: groupProfileSettingViewController)
        present(nav, animated: true, completion: nil)
    }
}
