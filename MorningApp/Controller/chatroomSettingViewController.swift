//
//  chatroomSettingViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/12.
//

import UIKit
import Firebase

//グループ作成の画面
class chatroomSettingViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var groupImageButton: UIButton!
    @IBOutlet weak var groupNameTextFeld: UITextField!
    @IBOutlet weak var groupPasswordTextField: UITextField!
    @IBOutlet weak var groupRegisterButtonOutlet: UIButton!
    
    var groupPasswordIsEmpty:Bool = true
    
    @IBAction func groupRegisterButton(_ sender: Any) {
        firebase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupRegisterButtonOutlet.layer.cornerRadius = 10
        groupRegisterButtonOutlet.isEnabled = false
        groupRegisterButtonOutlet.layer.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        groupImageButton.layer.cornerRadius = 85
        groupImageButton.layer.borderWidth = 1
        groupImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        
        groupImageButton.addTarget(self, action: #selector(tappedImageButton), for: .touchUpInside)
        
        groupNameTextFeld.delegate = self
        groupPasswordTextField.delegate = self
        
    }
    
    @objc func tappedImageButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //新しいグループの作成
    private func firebase() {
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
            "groupProfileText": ""
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
        //画像をjpgに変更
        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
        //画像の保存場所を指定
        let imageRef = Storage.storage().reference().child(Const.GroupImage).child(chatroomRef.documentID + ".jpg")
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
        
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        
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
    @IBOutlet weak var groupPasswordTextField: UITextField!
    @IBOutlet weak var enterButtonOutlet: UIButton!
    
    //グループを選択してからの決定ボタン
    @IBAction func EnterButton(_ sender: Any) {
        //ユーザーの情報にグループの名前が入る
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        guard pickGroupId != nil else { return }
        let userRef = db.collection(Const.User).document(uid)
        let groupRef = db.collection(Const.ChatRooms).document(pickGroupId ?? "")
        
        groupRef.getDocument() {(document,err) in
            if let err = err {
                print(err)
                return
            }
            guard let groupData = document?.data() else { return }
            guard let password = groupData["password"] else { return }
            
            if password as? String == self.groupPasswordTextField.text {
                userRef.updateData([
                    "groupId": FieldValue.arrayUnion([self.pickGroupId!]),
                    "nowGroup": self.pickGroupId!
                ])
                groupRef.updateData([
                    "membar": FieldValue.arrayUnion([uid])
                ])
                
                let storyboar = UIStoryboard(name: "Home", bundle: nil)
                let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
                let nav = UINavigationController(rootViewController: homeViewController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            } else {
                print("*** passwordが違う")
            }
        }
    }
    
    var Chatgroup = [Group]()
    var listener:ListenerRegistration?
    var groupNameList = [String]()
    var searchResultList = [String]()
    var groupIdList = [String]()
    var pickGroupId:String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //デリゲート先を自分に設定する。
        groupSerchBar.delegate = self
        groupTableView.delegate = self
        groupTableView.dataSource = self
        //何も入力されていなくてもReturnキーを押せるようにする。
        groupSerchBar.enablesReturnKeyAutomatically = false
        enterButtonOutlet.layer.cornerRadius = 10
        groupPasswordTextField.layer.cornerRadius = 7.5
        groupPasswordTextField.isEnabled = false
        enterButtonOutlet.isEnabled = false
        enterButtonOutlet.layer.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        
        groupTableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "GroupCell")
        firebaseGroup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
   
    private func firebaseGroup() {
        if Auth.auth().currentUser != nil {
            let groupRef = Firestore.firestore().collection(Const.ChatRooms).order(by: "date",descending: true)
            listener = groupRef.addSnapshotListener() {
                (querySnapshot, err) in
                if let err = err {
                    print("err",err)
                    return
                }
                self.Chatgroup = querySnapshot!.documents.map {
                    document in
                    let groupData = Group(document: document)
                    return groupData
                }
                
                guard let groupData = querySnapshot?.documents else { return }
                for data in groupData {
                    self.groupIdList.append(data.documentID)
                    let data = data.data()
                    if let groupName:String = data["groupName"] as? String {
                        self.groupNameList.append(groupName)
                    }
                }
                self.groupTableView.reloadData()
                print("***Chatgroup",self.Chatgroup)
            }
        }
    }
}


extension chatroomEnterViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Chatgroup.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell",for: indexPath) as! GroupCell
                    
        cell.setGroupData(Chatgroup[indexPath.row])
        
        return cell
       
    }
    //選ばれたセル
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        didSelectRowLabel.text = groupNameList[indexPath.row]
        pickGroupId = groupIdList[indexPath.row]
        
        groupPasswordTextField.isEnabled = true
        enterButtonOutlet.isEnabled = true
        enterButtonOutlet.layer.backgroundColor = UIColor.rgb(red: 100, green: 150, blue: 255).cgColor
    }
  
    //検索ボタン押下時の呼び出しメソッド
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        //キーボードを閉じる。
//        groupSerchBar.endEditing(true)
//    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        //検索結果配列を空にする。
//        searchResultList.removeAll()
//
//        if(groupSerchBar.text == "") {
//            //検索文字列が空の場合はすべてを表示する。
//            searchResultList = groupNameList
//        } else {
//            //検索文字列を含むデータを検索結果配列に追加する。
//            for group in groupNameList {
//                if group.contains(groupSerchBar.text!) {
//                    searchResultList.append(group)
//                }
//            }
//        }
//        groupTableView.reloadData()
//    }
}
    
 

