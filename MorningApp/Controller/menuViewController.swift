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
    @IBOutlet weak var menuTargetLabel: UILabel!
    
    @IBAction func menuEditButton(_ sender: Any) {
        let storyboar = UIStoryboard(name: "MorningChuck", bundle: nil)
        let morningSettingViewController = storyboar.instantiateViewController(identifier: "MorningSettingViewController") as! MorningSettingViewController
        let nav = UINavigationController(rootViewController: morningSettingViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    private let cellId = "cellId"
    
    private var users = [User]()
    
    var listener: ListenerRegistration?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuView.backgroundColor = .rgb(red: 240, green: 240, blue: 255)
        menuView.layer.cornerRadius = 10
        menuImageView.layer.cornerRadius = 25
        menuTabelView.separatorStyle = .none
        menuTabelView.backgroundColor = .rgb(red: 245, green: 245, blue: 245)
        menuTabelView.delegate = self
        menuTabelView.dataSource = self
        menuTabelView.register(UINib(nibName: "menuMemberTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        menuTargetLabel.text = UserDefaults.standard.string(forKey: "SETTIME") ?? "設定する"
        //右へ
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipeGesture.direction = .right
        
        //左へ
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipeGesture.direction = .left
        
        view.addGestureRecognizer(rightSwipeGesture)
        view.addGestureRecognizer(leftSwipeGesture)
        
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case .left:
            let storyboar = UIStoryboard(name: "Home", bundle: nil)
            let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
            let nav = UINavigationController(rootViewController: homeViewController)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .crossDissolve

            present(nav, animated: true, completion: nil)
            
        case .right:
            
           print("right Swipe")
            
        default:
            break
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // メニューの位置を取得する
        let menuPos = self.menuView.layer.position
        // 初期位置を画面の外側にするため、メニューの幅の分だけマイナスする
        self.menuView.layer.position.x = -self.menuView.frame.width
        // 表示時のアニメーションを作成する
        UIView.animate(
            withDuration: 0.25,
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
        return "メンバー"
    }
    
    // セクションの背景とテキストの色を変更する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // 背景色を変更する
        view.tintColor = .rgb(red: 245, green: 245, blue: 245)

        let header = view as! UITableViewHeaderFooterView
        // テキスト色を変更する
        header.textLabel?.textColor = .darkGray
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

