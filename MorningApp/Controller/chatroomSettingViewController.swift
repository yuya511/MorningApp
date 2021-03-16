//
//  chatroomSettingViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/12.
//

import UIKit
import Firebase

//グループ作成の画面
class chatroomSettingViewController: UIViewController {

    @IBOutlet weak var groupNameTextFeld: UITextField!
    @IBOutlet weak var groupPasswordTextField: UITextField!
    
    @IBAction func groupRegisterButton(_ sender: Any) {
        firebase()
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    //新しいグループの作成
    private func firebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
                
        guard let groupText = groupNameTextFeld.text else { return }
        guard let groupPasswordText = groupPasswordTextField.text else { return }
        
        let chatroomRef = Firestore.firestore().collection(Const.ChatRooms).document(groupText)
        
        let chatroomDic = [
            "password": groupPasswordText,
            "date": Timestamp(),
            "membar": [uid],
            "groupName": groupText
        ] as [String : Any]
        chatroomRef.setData(chatroomDic)
        print("***chatroomの情報が保存されました")
        
        //ユーザーの情報にグループの名前が入る
        let userRef = Firestore.firestore().collection(Const.User).document(uid)
        userRef.updateData([
            "groupName": groupText
        ])
    }
}

//グループを検索して参加するとき
class chatroomEnterViewController: UIViewController, UISearchBarDelegate {
   
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var groupSerchBar: UISearchBar!
    @IBOutlet weak var didSelectRowLabel: UILabel!
    
    //グループを選択してからの決定ボタン
    @IBAction func EnterButton(_ sender: Any) {
        //ユーザーの情報にグループの名前が入る
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection(Const.User).document(uid)
        
        guard let didLabel = didSelectRowLabel.text else { return }
        
        userRef.updateData([
            "groupName": didLabel
        ])
        
        let groupRef = db.collection(Const.ChatRooms).document(didLabel)
        
        groupRef.updateData([
            "membar": FieldValue.arrayUnion([uid])
        ])
        
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: true, completion: nil)
    }
    
    var Chatgroup = [Group]()
    var listener:ListenerRegistration?
    //検索結果配列
    var groupNameList = [String]()
    var searchResultList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //デリゲート先を自分に設定する。
        groupSerchBar.delegate = self
        groupTableView.delegate = self
        groupTableView.dataSource = self
        //何も入力されていなくてもReturnキーを押せるようにする。
        groupSerchBar.enablesReturnKeyAutomatically = false
        firebaseGroup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        
        let chat = Chatgroup[indexPath.row]
        
//        groupNameList.append(chat.groupName ?? "")
//
//        searchResultList.append(chat.groupName ?? "")
//
        cell.textLabel?.text = chat.groupName
        
        return cell
       
    }
    //選ばれたセル
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chat = Chatgroup[indexPath.row]
        didSelectRowLabel.text = chat.groupName
        
    }
  
    //検索ボタン押下時の呼び出しメソッド
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        self.view.endEditing(true)
//        print("*****")
//
//        groupNameList.removeAll()
//
//        if(groupSerchBar.text == "") {
//            searchResultList = groupNameList
//        } else {
//            for data in groupNameList {
//                if data.contains(groupSerchBar.text!) {
//                    searchResultList.append(data)
//                }
//            }
//        }
//
//        //テーブルを再読み込みする。
//        groupTableView.reloadData()
//    }
}
    
 

