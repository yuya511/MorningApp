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
    private let cellId02 = "cellId02"
    
    private var users = [User]()
    private var chat = [Chatroom]()
    
    //監視するやつ
    private var listener: ListenerRegistration?
    
    
    private let chatInputAccessoryHeight: CGFloat = 100
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicateorInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    
    @IBOutlet weak var HomeTableView: UITableView!
    
    
    //インプットアクセサリービューの設置
    private lazy var chatInputAccessoryView: ChatInputAccessory = {
        let view = ChatInputAccessory()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: chatInputAccessoryHeight)
        view.delegate = self
        return view
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpHomeTableView()
        setUpNotification()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
                
        if Auth.auth().currentUser != nil {
            let chatroomsRef = Firestore.firestore().collection(Const.ChatRooms).order(by: "date", descending: true)
            
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
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        listener?.remove()
    }
    
    
    private func setUpNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setUpHomeTableView() {
        //HomeTableViewの設定
        HomeTableView.delegate = self
        HomeTableView.dataSource = self
        HomeTableView.backgroundColor = .rgb(red: 215, green: 215, blue: 230)
        HomeTableView.contentInset = .init(top: 60, left: 0, bottom: 0, right: 0)
        HomeTableView.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
        //下に表示されるように逆さまにしている。
        HomeTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        HomeTableView.keyboardDismissMode = .interactive
        
        //ログインの確認
        if Auth.auth().currentUser?.uid == nil {
            let storyboar = UIStoryboard(name: "SingUp",bundle: nil)
            let singUpViewController = storyboar.instantiateViewController(identifier: "SingUpViewController") as! SingUpViewController
            let nav = UINavigationController(rootViewController: singUpViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
        //ナビゲーションバーの設定
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)

        //カスタムセルの登録
        HomeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        HomeTableView.register(UINib(nibName: "MorningTableViewCell", bundle: nil), forCellReuseIdentifier: cellId02)
        
    }

    
   
    @objc func keyboardWillShow(notification: NSNotification) {
        //keyboardの高さを取得
        guard let userInfo = notification.userInfo else { return }
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= chatInputAccessoryHeight { return }
            
            let top = keyboardFrame.height - safeAreaBottom
            var moveY = -(top - HomeTableView.contentOffset.y)
            if HomeTableView.contentOffset.y != -60 { moveY += 60 }
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            
            HomeTableView.contentInset = contentInset
            HomeTableView.scrollIndicatorInsets = contentInset
            HomeTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    
    @objc func keyboardWillHide() {
        HomeTableView.contentInset = tableViewContentInset
        HomeTableView.scrollIndicatorInsets = tableViewIndicateorInset
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
        
            guard let username = Auth.auth().currentUser?.displayName else { return }
            
            let chatroomRef = Firestore.firestore().collection(Const.ChatRooms).document()
            
            let chatroomDic = [
                "name": username,
                "text": text,
                "stamp": false,
                "date": Timestamp(),
                "uid": uid,
            ] as [String : Any]
            chatroomRef.setData(chatroomDic)
            print("chatroomの情報が保存されました")
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
    
    //セルが生成される瞬間に呼ばれる
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HomeTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! HomeTableViewCell
            //セルを逆さまにしている
            cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)

            cell.setUserData(chat[indexPath.row])
        
        let cell02 = HomeTableView.dequeueReusableCell(withIdentifier: cellId02, for: indexPath) as! MorningTableViewCell
            //セルを逆さまにしている
            cell02.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
            cell02.setUserData(chat[indexPath.row])
        
        
        let chatData = chat[indexPath.row]

            switch chatData.stamp {
            case true:
                return cell02
            case false:
                return cell
            default:
                return cell
            }
        
    }

}
