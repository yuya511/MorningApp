//
//  ViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/19.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    
    private let cellId = "cellId"
    
    
    private var users = [User]()
    private var chat: [Chatroom] = []
    //監視するやつ
    private var listener: ListenerRegistration?
    private var messages = [String]()
    
    
    @IBOutlet weak var HomeTableView: UITableView!
    
    
    //インプットアクセサリービューの設置
    private lazy var chatInputAccessoryView: ChatInputAccessory = {
        let view = ChatInputAccessory()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HomeTableView.delegate = self
        HomeTableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        
        let logoutBarButton = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(tappedLoginButton))
        navigationItem.rightBarButtonItem = logoutBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        //カスタムセルの登録
        HomeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        HomeTableView.backgroundColor = .rgb(red: 215, green: 215, blue: 230)
        
       if Auth.auth().currentUser?.uid == nil {
            let storyboar = UIStoryboard(name: "SingUp",bundle: nil)
            let singUpViewController = storyboar.instantiateViewController(identifier: "SingUpViewController") as! SingUpViewController
            let nav = UINavigationController(rootViewController: singUpViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    @objc private func tappedLoginButton() {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "SingUp", bundle: nil)
            let singupViewController = storyboard.instantiateViewController(withIdentifier: "SingUpViewController")
            let nav = UINavigationController(rootViewController: singupViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        } catch {
            print("ログアウトに失敗しました。\(error)")
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            let chatroomsRef = Firestore.firestore().collection(Const.ChatRooms).order(by: "date", descending: false)
            listener = chatroomsRef.addSnapshotListener() { ( querysnapshot, err) in
                if let err = err {
                    print("DEBUG_PRINT: snapshotの取得に失敗しました。\(err)")
                    return
                }
                self.chat = querysnapshot!.documents.map { document in
                    let chatData = Chatroom(document: document)
                    return chatData
                }
                self.HomeTableView.reloadData()
            }
        }
        
        
        fetchUserInfoFromFirestore()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        listener?.remove()
    }
    
    private func fetchUserInfoFromFirestore() {
        //userモデルのデータベースへの保存
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
            if let err = err {
                print("DEBUG_PRINT:userの情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                
                self.users.append(user)
            })
        }
    }
    
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
   

}

//アクセサリービューで作ったデリゲートメソッド
extension HomeViewController: ChatInputAccessoryDelegate {
    func tappedSendButton(text: String) {
        chatInputAccessoryView.removeText()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { (document, err) in
            if let err = err {
                print(err)
                return
            }
            guard let dic = document?.data() else { return }
            guard let username = dic["username"] else { return }
            
            let chatroomRef = Firestore.firestore().collection(Const.ChatRooms).document()
            
            let chatroomDic = [
                "name": username,
                "text": text,
                "uid": uid,
                "date": Timestamp(),
            ] as [String : Any]
            chatroomRef.setData(chatroomDic)
            print("chatroomの情報が保存されました")
        }
    }
}



//テーブルビューのデリゲートメソッド
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        HomeTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HomeTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! HomeTableViewCell
//        cell.usertext = messages[indexPath.row]
        cell.setUserData(chat[indexPath.row])
        
        return cell
        
    }
    
}

