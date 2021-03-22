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
    private let cellId02 = "cellId02"
    
    private var users = [User]()
    private var groups = [Group]()
    private var membarUidList = [String]()
    private var groupIdList = [String]()
    
    var listener: ListenerRegistration?
    var sectionArry = ["グループ","メンバー"]
    
    
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
        menuTabelView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: cellId02)
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
        
        //ユーザのメンバーの監視
        if Auth.auth().currentUser != nil{
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let userRef = Firestore.firestore().collection(Const.User).document(uid)
            userRef.getDocument { (documents, err) in
                if let err = err {
                    print("err",err)
                }
                guard let document = documents?.data() else { return }
                let groupId = document["groupId"] ?? "err"
                let chatroomMembarRef = Firestore.firestore().collection(Const.ChatRooms).document(groupId as! String)
                
                self.listener = chatroomMembarRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT \(error)")
                        return
                    }
                    guard let chatroomData = querySnapshot?.data() else { return }
                    self.membarUidList = chatroomData["membar"] as? [String] ?? ["err"]
                    guard let chatroomMembar:[String] = chatroomData["membar"] as? [String] else { return }
                    for membar in chatroomMembar {
                        let membarRef = Firestore.firestore().collection(Const.User).document(membar)
                        membarRef.addSnapshotListener() {(document,err) in
                            if let err = err {
                                print(err)
                            }
                            guard let document = document else { return }
                            let user = User(document: document)
                            self.users.append(user)
                            self.menuTabelView.reloadData()
                        }
                    }
                }
            }
            let groupRef = Firestore.firestore().collection(Const.ChatRooms)
            listener = groupRef.addSnapshotListener() {(querySnapshot,err) in
                if let err = err {
                    print("err",err)
                    return
                }
                
                self.groups = querySnapshot!.documents.map { document in
                    let groupdata = Group(document: document)
                    self.groupIdList.append(groupdata.groupId ?? "err")
                    return groupdata
                }
            }
            //ログインしているユーザーの画像と名前を表示する
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
            menuImageView.sd_setImage(with: imageRef)
            
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
        return sectionArry.count
    }
    //セクションの名前
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArry[section]
    }
    
    // セクションの背景とテキストの色を変更する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // 背景色を変更する
        view.tintColor = .rgb(red: 245, green: 245, blue: 245)
        let header = view as! UITableViewHeaderFooterView
        // テキスト色を変更する
        header.textLabel?.textColor = .darkGray
    }
    
    
    //選択したセルが呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        if indexPath.section == 0 {
            let groupProfileSettingViewController = storyboar.instantiateViewController(identifier: "groupProfileSettingViewController") as! groupProfileSettingViewController
            groupProfileSettingViewController.id = groupIdList[indexPath.row]
            let nav = UINavigationController(rootViewController: groupProfileSettingViewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        } else if indexPath.section == 1 {
            let profileSettingViewController = storyboar.instantiateViewController(identifier: "ProfileSettingViewController") as! ProfileSettingViewController
            profileSettingViewController.id = membarUidList[indexPath.row]
            let nav = UINavigationController(rootViewController: profileSettingViewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        } else {
            let profileSettingViewController = storyboar.instantiateViewController(identifier: "ProfileSettingViewController") as! ProfileSettingViewController
            let nav = UINavigationController(rootViewController: profileSettingViewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }

   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return groups.count
        } else if section == 1 {
            return users.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellGroup = menuTabelView.dequeueReusableCell(withIdentifier: cellId02, for: indexPath) as! GroupCell
        let cellMembar = menuTabelView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! menuMemberTableViewCell
        if indexPath.section == 0 {
            cellGroup.setGroupData(groups[indexPath.row])
            return cellGroup
        } else if indexPath.section == 1 {
            cellMembar.setUserData(users[indexPath.row])
            return cellMembar
        } else {
            return cellMembar
        }
    }
}


