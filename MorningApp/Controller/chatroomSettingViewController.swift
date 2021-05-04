//
//  chatroomSettingViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/12.
//

import UIKit
import Firebase
import SVProgressHUD

class chatroomSettingViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var groupImageButton: UIButton!
    @IBOutlet weak var groupNameTextFeld: UITextField!
    @IBOutlet weak var groupPasswordTextField: UITextField!
    @IBOutlet weak var groupRegisterButtonOutlet: UIButton!
    
    @IBAction func groupRegisterButton(_ sender: Any) {
        newGroupSetting()
    }
    
    var endButton: UIBarButtonItem!
    
    private var groupPasswordIsEmpty:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        setDefault()
        newUserFirestCheck()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
       
    private func setDefault() {
        groupRegisterButtonOutlet.layer.cornerRadius = 10
        groupRegisterButtonOutlet.isEnabled = false
        groupRegisterButtonOutlet.layer.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        groupImageButton.layer.cornerRadius = 25
        groupImageButton.layer.borderWidth = 1
        groupImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        groupImageButton.addTarget(self, action: #selector(tappedImageButton), for: .touchUpInside)
        
        groupNameTextFeld.delegate = self
        groupPasswordTextField.delegate = self
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 240, green: 240, blue: 255)
        navigationItem.title = "グループを作成"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.rgb(red: 79, green: 109, blue: 220)
        ]
        endButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(leftBarButtonAction))
        self.navigationItem.leftBarButtonItem = endButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func leftBarButtonAction() {
        self.dismiss(animated: true, completion: nil)
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
    
    @objc func tappedImageButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
  
    private func newUserFirestCheck() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userRef = Firestore.firestore().collection(Const.User).document(uid)
//        userRef.getDocument { (documents, err) in
//            if let err = err {
//                print("***err",err)
//                return
//            }
//            guard let document = documents?.data() else { return }
//            if let _:String = document["nowGroup"] as? String {
//
//            } else {
//            }
//        }
    }
  
    private func newGroupSetting() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let groupText = groupNameTextFeld.text else { return }
        guard let groupPasswordText = groupPasswordTextField.text else { return }
        let chatroomRef = db.collection(Const.ChatRooms).document()
        
        let chatroomDic = [
            "groupId": chatroomRef.documentID,
            "password": groupPasswordText,
            "passwordCheck": groupPasswordIsEmpty,
            "date": Timestamp(),
            "membar": [uid],
            "groupName": groupText,
            "groupProfileText": "",
            "myChat":false
        ] as [String : Any]
        chatroomRef.setData(chatroomDic)
        print("***chatroomの情報が保存されました")
        
        //ユーザーの情報にグループの名前が入る
        let userRef = Firestore.firestore().collection(Const.User).document(uid)
        userRef.updateData([
            "groupId": FieldValue.arrayUnion([chatroomRef.documentID])
        ])
        userRef.updateData([
            "nowGroup": chatroomRef.documentID
        ])
        let image = self.groupImageButton.imageView?.image ?? UIImage(named: "男シルエットイラスト")
        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
        let imageRef = Storage.storage().reference().child(Const.GroupImage).child(chatroomRef.documentID + ".jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(uploadImage, metadata: metadata) { (metadata, err) in
            if let err = err {
                print("***画像のアップロードに失敗しました。\(err)")
                return
            }
            print("***画像の保存に成功しました。")
        }
        //アプリを使うのが初めてかどうかをチェック
        if UserDefaults.standard.bool(forKey: "firestTime") {
            let storyboar = UIStoryboard(name: "Home", bundle: nil)
            let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
            let nav = UINavigationController(rootViewController: homeViewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        } else {
            UserDefaults.standard.set(true, forKey: "firestTime")
            let storyboar = UIStoryboard(name: "MorningChuck", bundle: nil)
            let MorningSettingViewController = storyboar.instantiateViewController(identifier: "MorningSettingViewController") as! MorningSettingViewController
            let nav = UINavigationController(rootViewController: MorningSettingViewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let groupNameIsEmpty = groupNameTextFeld.text?.isEmpty ?? false
        self.groupPasswordIsEmpty = groupPasswordTextField.text?.isEmpty ?? false
                
        if groupNameIsEmpty {
            groupRegisterButtonOutlet.isEnabled = false
            groupRegisterButtonOutlet.layer.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        } else {
            groupRegisterButtonOutlet.isEnabled = true
            groupRegisterButtonOutlet.layer.backgroundColor = UIColor.rgb(red: 100, green: 150, blue: 250).cgColor
        }
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
    
}







//グループを検索して参加するとき
class chatroomEnterViewController: UIViewController, UISearchBarDelegate {
   
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var groupSerchBar: UISearchBar!
    @IBOutlet weak var didSelectRowLabel: UILabel!
    @IBOutlet weak var enterButtonOutlet: UIButton!
    //グループを選択してからの決定ボタン
    @IBAction func EnterButton(_ sender: Any) {
       enterGroup()
    }
    
    private var Chatgroup = [Group]()
    private var resultChatgroup = [Group]()
    
    private var groupNameList = [String]()
    private var searchGroupNameList = [String]()
    
    private var groupIdList = [String]()
    private var searchGroupIdList = [String]()
    
    private var pickGroupId:String?
    private var listener:ListenerRegistration?
    
    var firestFlag:Bool?
    
    private var addGroupButton: UIBarButtonItem!
    private var endButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        setDefault()
        GroupsSetting()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        groupSerchBar.endEditing(true)
    }
    
    private func setDefault() {
        groupSerchBar.delegate = self
        groupTableView.delegate = self
        groupTableView.dataSource = self
        groupSerchBar.keyboardType = .default
        groupSerchBar.enablesReturnKeyAutomatically = false
        enterButtonOutlet.layer.cornerRadius = 10
        enterButtonOutlet.isEnabled = false
        enterButtonOutlet.layer.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        groupTableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "GroupCell")

        self.navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 240, green: 240, blue: 255)
        addGroupButton = UIBarButtonItem(title: "新規グループ", style: .done, target: self, action: #selector(rightBarButtonAction))
        self.navigationItem.rightBarButtonItem = addGroupButton
        endButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(leftBarButtonAction))
        self.navigationItem.leftBarButtonItem = endButton
        guard let firestFlag = firestFlag else { return }
        if firestFlag {
            endButton.isEnabled = false
        }
    }
    
    @objc func rightBarButtonAction() {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let chatroomSettingViewController = storyboar.instantiateViewController(identifier: "chatroomSettingViewController") as! chatroomSettingViewController
        let nav = UINavigationController(rootViewController: chatroomSettingViewController)
        present(nav, animated: true, completion: nil)
    }
    
    @objc func leftBarButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func GroupsSetting() {
        if Auth.auth().currentUser != nil {
            let groupRef = Firestore.firestore().collection(Const.ChatRooms)
                .whereField("myChat", isEqualTo: false)
            listener = groupRef.addSnapshotListener() { querySnapshot, err in
                if let err = err {
                    print("***err",err)
                    return
                }
                self.Chatgroup = querySnapshot!.documents.map { document in
                    let groupData = Group(document: document)
                    return groupData
                }
                self.resultChatgroup = self.Chatgroup
                guard let groupData = querySnapshot?.documents else { return }
                for data in groupData {
                    self.groupIdList.append(data.documentID)
                    let data = data.data()
                    if let groupName:String = data["groupName"] as? String {
                        self.groupNameList.append(groupName)
                    }
                }
                self.searchGroupIdList = self.groupIdList
                self.searchGroupNameList = self.groupNameList
                self.groupTableView.reloadData()
            }
        }
    }
    
    private func enterGroup() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        guard pickGroupId != nil else { return }
        let userRef = db.collection(Const.User).document(uid)
        let groupRef = db.collection(Const.ChatRooms).document(pickGroupId ?? "err")
        groupRef.getDocument() { document,err in
            if let err = err {
                print("***err",err)
                return
            }
            guard let groupData = document?.data() else { return }
            guard let password = groupData["password"] else { return }
            if password as? String == "" {
                
                print("***パスワードなし")
                userRef.updateData([
                    "groupId": FieldValue.arrayUnion([self.pickGroupId!]),
                    "nowGroup": self.pickGroupId!
                ])
                groupRef.updateData([
                    "membar": FieldValue.arrayUnion([uid])
                ])
                if UserDefaults.standard.bool(forKey: "firestTime") {
                    let storyboar = UIStoryboard(name: "Home", bundle: nil)
                    let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
                    let nav = UINavigationController(rootViewController: homeViewController)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                } else {
                    UserDefaults.standard.set(true, forKey: "firestTime")
                    let storyboar = UIStoryboard(name: "MorningChuck", bundle: nil)
                    let MorningSettingViewController = storyboar.instantiateViewController(identifier: "MorningSettingViewController") as! MorningSettingViewController
                    let nav = UINavigationController(rootViewController: MorningSettingViewController)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                }
            } else {
                print("***パスワードが設定されている")
                let storybor = UIStoryboard(name: "Setting", bundle: nil)
                let passwordView = storybor.instantiateViewController(identifier: "passwordViewController") as! passwordViewController
                passwordView.password = password as? String
                passwordView.uid = uid
                passwordView.groupId = self.pickGroupId
                let nav = UINavigationController(rootViewController: passwordView)
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
}


extension chatroomEnterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultChatgroup.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell",for: indexPath) as! GroupCell
        cell.setGroupData(resultChatgroup[indexPath.row])
        return cell
    }
    //選ばれたセル
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        groupSerchBar.endEditing(true)
        didSelectRowLabel.text = searchGroupNameList[indexPath.row]
        pickGroupId = searchGroupIdList[indexPath.row]
        enterButtonOutlet.isEnabled = true
        enterButtonOutlet.layer.backgroundColor = UIColor.rgb(red: 100, green: 150, blue: 255).cgColor
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //検索結果配列を空にする。
        resultChatgroup.removeAll()
        searchGroupNameList.removeAll()
        searchGroupIdList.removeAll()
        //検索文字列が空の場合はすべてを表示する。
        if groupSerchBar.text == "" {
            
            searchGroupNameList = groupNameList
            searchGroupIdList = groupIdList
            resultChatgroup = Chatgroup
            self.groupTableView.reloadData()
            
        } else {
            //検索文字列を含むデータを検索結果配列に追加する。
            for group in groupNameList {
                if group.contains(groupSerchBar.text!) {
                    searchGroupNameList.append(group)
                    for groupName in searchGroupNameList {
                        let groupRef = Firestore.firestore().collection(Const.ChatRooms).order(by: "date",descending: true).whereField("groupName", isEqualTo:groupName)
                        listener = groupRef.addSnapshotListener() { querySnapshot, err in
                            if let err = err {
                                print("***err",err)
                                return
                            }
                            self.resultChatgroup = querySnapshot!.documents.map { document in
                                let groupData = Group(document: document)
                                return groupData
                            }
                            guard let groupData = querySnapshot?.documents else { return }
                            for data in groupData {
                                self.searchGroupIdList.append(data.documentID)
                            }
                            self.groupTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
    



//パスワード入力画面
class passwordViewController:UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordTextFiled: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBAction func hiddenButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var password:String?
    var uid:String?
    var groupId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        
       setDefault()
    }
    
    private func setDefault() {
        passwordTextFiled.layer.cornerRadius = 10
        enterButton.layer.cornerRadius = 7
        passwordTextFiled.delegate = self
        navigationController?.navigationBar.barTintColor = .rgb(red: 240, green: 240, blue: 255)
        enterButton.addTarget(self, action: #selector(enterButtonAction), for: .touchUpInside)
    }
    
    @objc func enterButtonAction() {
        if passwordTextFiled.text == password {
            
            let db = Firestore.firestore()
            let userRef = db.collection(Const.User).document(uid ?? "")
            let groupRef = db.collection(Const.ChatRooms).document(groupId ?? "")
            userRef.updateData([
                "groupId": FieldValue.arrayUnion([self.groupId!]),
                "nowGroup": groupId ?? ""
            ])
            groupRef.updateData([
                "membar": FieldValue.arrayUnion([uid ?? ""])
            ])
            
            if UserDefaults.standard.bool(forKey: "firestTime") {
                let storyboar = UIStoryboard(name: "Home", bundle: nil)
                let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
                let nav = UINavigationController(rootViewController: homeViewController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(true, forKey: "firestTime")
                let storyboar = UIStoryboard(name: "MorningChuck", bundle: nil)
                let MorningSettingViewController = storyboar.instantiateViewController(identifier: "MorningSettingViewController") as! MorningSettingViewController
                let nav = UINavigationController(rootViewController: MorningSettingViewController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            
        } else {
            SVProgressHUD.showError(withStatus: "有効なパスワードでは、ありません")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
}
