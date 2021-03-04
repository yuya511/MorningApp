//
//  menuViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/01.
//

import UIKit
import Firebase
import FirebaseUI
import SVProgressHUD


class menuViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuNameLabel: UILabel!
    @IBOutlet weak var menuEmailLabel: UILabel!
    @IBOutlet weak var menuTabelView: UITableView!
    
    
    private let cellId = "cellId"
    
    private var users = [User]()
    
    var listener: ListenerRegistration?

    
    @IBAction func LogOutButton(_ sender: Any) {
        
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuImageView.layer.cornerRadius = 25
        menuTabelView.separatorStyle = .none
        
        menuTabelView.delegate = self
        menuTabelView.dataSource = self
        
        menuTabelView.register(UINib(nibName: "menuMemberTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // メニューの位置を取得する
        let menuPos = self.menuView.layer.position
        // 初期位置を画面の外側にするため、メニューの幅の分だけマイナスする
        self.menuView.layer.position.x = -self.menuView.frame.width
        // 表示時のアニメーションを作成する
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.menuView.layer.position.x = menuPos.x
        },
            completion: { bool in
        })
        fetchUserInfoFromFirestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listener?.remove()
    }
    
    
    private func fetchUserInfoFromFirestore() {
        
        if Auth.auth().currentUser != nil{
            
            let usersRef = Firestore.firestore().collection(Const.User).order(by: "createdAt", descending: true)
            
            listener = usersRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT* \(error)")
                    return
                }
                
                
                querySnapshot?.documents.forEach({ ( document ) in
                    let user = User(document: document)
                    
                    if Auth.auth().currentUser?.uid == document.documentID {
                        return
                    }
                    
                    self.users.append(user)
                    self.menuTabelView.reloadData()
                })
            }
            
        
        
            //ログインしているユーザーの画像と名前を表示する
            guard let uid = Auth.auth().currentUser?.uid else {return}
            
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
            menuImageView.sd_setImage(with: imageRef)
            
            let userRef = Firestore.firestore().collection("users").document(uid)
            userRef.getDocument { (document, err) in
                if let err = err {
                    print(err)
                    return
                }
                guard let dic = document?.data() else { return }
                guard let username = Auth.auth().currentUser?.displayName else { return }
                guard let email = dic["email"] else { return }
                
                self.menuNameLabel.text = username
                self.menuEmailLabel.text = email as? String
            }
        }
    }

    // メニューエリア以外タップ時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                }
            )}
        }
    }
}



extension menuViewController: UITableViewDelegate, UITableViewDataSource {
   
    //セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //セクションの名前
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "member"
    }
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTabelView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! menuMemberTableViewCell
        cell.setUserData(users[indexPath.row])
        return cell
    }
    
    
    
}

