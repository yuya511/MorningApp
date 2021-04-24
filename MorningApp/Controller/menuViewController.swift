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
        present(nav, animated: true, completion: nil)
    }
    
    private let cellId = "cellId"
    
    private var users = [User]()
    private var groups = [Group]()
    private var membarUidList = [String]()
    private var groupIdList = [String]()
    private var myNowGroup : String?
    private var myNowGroupNmae : String?

    
    var sectionArry = ["グループ","メンバー"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().barTintColor = UIColor.white
        self.overrideUserInterfaceStyle = .light

        menuView.backgroundColor = .rgb(red: 240, green: 240, blue: 255)
        menuView.layer.cornerRadius = 10
        menuImageView.layer.cornerRadius = 25
        menuTabelView.separatorStyle = .none
        menuTabelView.backgroundColor = .rgb(red: 245, green: 245, blue: 245)
        menuTabelView.delegate = self
        menuTabelView.dataSource = self
        menuTabelView.register(UINib(nibName: "menuMemberTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        menuTargetLabel.text = UserDefaults.standard.string(forKey: "SETTIME") ?? "設定する"
        self.overrideUserInterfaceStyle = .light
        //右へ
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipeGesture.direction = .right
        //左へ
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipeGesture.direction = .left
        
        view.addGestureRecognizer(rightSwipeGesture)
        view.addGestureRecognizer(leftSwipeGesture)
        
        setUser()

        guard let tabbarSize = tabBarController?.tabBar.frame.size.height else {return }

        var admobView = GADBannerView()
        admobView = GADBannerView(adSize: kGADAdSizeBanner)
        
        let screenSize = UIScreen.main.bounds.size
        switch (screenSize.height) {
        case 480.0:
            admobView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - admobView.frame.height - tabbarSize)
            admobView.frame.size = CGSize(width: self.view.frame.width, height: admobView.frame.height)
             break
        case 568.0:
            admobView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - admobView.frame.height - tabbarSize)
            admobView.frame.size = CGSize(width: self.view.frame.width, height: admobView.frame.height)
             break
        case 667.0:
            //iPhone8とか
            admobView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - admobView.frame.height - tabbarSize)
            admobView.frame.size = CGSize(width: self.view.frame.width, height: admobView.frame.height)
             break
        case 736.0:
            admobView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - admobView.frame.height - tabbarSize - 34)
            admobView.frame.size = CGSize(width: self.view.frame.width, height: admobView.frame.height)
             break
        case 812.0:
            admobView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - admobView.frame.height - tabbarSize - 34)
            admobView.frame.size = CGSize(width: self.view.frame.width, height: admobView.frame.height)
             break
        case 896.0:
            admobView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - admobView.frame.height - tabbarSize - 34)
            admobView.frame.size = CGSize(width: self.view.frame.width, height: admobView.frame.height)
             break
        default:
            admobView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - admobView.frame.height - tabbarSize - 34)
            admobView.frame.size = CGSize(width: self.view.frame.width, height: admobView.frame.height)
             break
        }
        
        
//        admobView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        admobView.adUnitID = "ca-app-pub-7475127346409545/8974259664"

        admobView.rootViewController = self
        admobView.load(GADRequest())
        self.view.addSubview(admobView)
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            print("left Swipe")
            self.dismiss(animated: true, completion: nil)
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
        
        timeCheck()
    }
    
    func timeCheck() {
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let HomeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        HomeViewController.timeCheck()
    }
   
    func setUser() {
        if Auth.auth().currentUser != nil {
           
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let UserRef = Firestore.firestore().collection(Const.User).document(uid)
            UserRef.addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    print("***err",err)
                    return
                }
                guard let UserData = querySnapshot?.data() else { return }
                guard let nowGroup = UserData["nowGroup"] else { return }
                self.myNowGroup = nowGroup as? String
                self.fetchUserInfoFromFirestore(nowGroup: nowGroup as? String ?? "")
            }
            
            //ログインしているユーザーの画像と名前を表示する
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
            menuImageView.sd_setImage(with: imageRef)
            
            UserRef.addSnapshotListener() { (document, err) in
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
    
    //nowGroupがあったら呼ばれるようにしている
    private func fetchUserInfoFromFirestore(nowGroup:String) {
        print("****",nowGroup)
        //ユーザのメンバーの監視
        if Auth.auth().currentUser != nil{
            //userからGroupIdを取得し、groupsにデータをセットしている
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let userRef = Firestore.firestore().collection(Const.User).document(uid)
            userRef.getDocument { (documents, err) in
                if let err = err {
                    print("***err",err)
                }
                guard let document = documents?.data() else { return }
                guard let groupId:[String] = document["groupId"] as? [String] else { return }
                for id in groupId {
                    self.groupIdList.append(id)
                    let groupRef = Firestore.firestore().collection(Const.ChatRooms).document(id)
                    groupRef.addSnapshotListener() {(querySnapshot,err) in
                        if let err = err {
                            print("***err",err)
                            return
                        }
                        guard let querySnapshot = querySnapshot else {return}
                        print("self.呼ばれている")
                        self.groups.append(Group(docu: querySnapshot))
                    }
                }
                //nowGroupを使ってmembarを取得し、membarのUIDからuserのデータを取得しusersにデータをセットしている
                let chatroomMembarRef = Firestore.firestore().collection(Const.ChatRooms).document(nowGroup)
                chatroomMembarRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT \(error)")
                        return
                    }
                    guard let chatroomData = querySnapshot?.data() else { return }
                    self.myNowGroupNmae = chatroomData["groupName"] as? String
                    self.membarUidList = chatroomData["membar"] as? [String] ?? ["メンバーなし"]
                    guard let chatroomMembar:[String] = chatroomData["membar"] as? [String] else { return }
                    for membar in chatroomMembar {
                        let membarRef = Firestore.firestore().collection(Const.User).document(membar)
                        membarRef.addSnapshotListener() {(document,err) in
                            if let err = err {
                                print("***err",err)
                            }
                            guard let document = document else { return }
                            let user = User(document: document)

                            self.users.append(user)
                            self.menuTabelView.reloadData()
                        }
                    }
                    self.menuTabelView.reloadData()
                }
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
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            let userRef = db.collection(Const.User).document(uid)
            
            userRef.updateData([
                "nowGroup": groupIdList[indexPath.row]
            ])
            
            let storyboar = UIStoryboard(name: "Home", bundle: nil)
            let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
            let nav = UINavigationController(rootViewController: homeViewController)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .coverVertical
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
            print("***groups.count",groups.count)
            return groups.count
            
        } else if section == 1 {
            print("***users.count",users.count)
            return users.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellMembar = menuTabelView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! menuMemberTableViewCell
        if indexPath.section == 0 {
            cellMembar.setGroupData(groups[indexPath.row])
            return cellMembar
        } else if indexPath.section == 1 {
            cellMembar.setUserData(users[indexPath.row])
            return cellMembar
        } else {
            return cellMembar
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        if indexPath.section == 0 {
            return .none
        } else if indexPath.section == 1 {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        guard let nowId = Auth.auth().currentUser?.uid else { return ""}
        if users[indexPath.row].uid == nowId {
            return "グループから抜ける"
        } else {
            return "削除"
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let db = Firestore.firestore()
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        let userUid = users[indexPath.row].uid
        guard let userName = users[indexPath.row].username else { return }
        
        if editingStyle == .delete {
            if userUid == myUid {
                let alertController:UIAlertController = UIAlertController(title:"「\(self.myNowGroupNmae ?? "")」から退会しますか？", message: "", preferredStyle: .alert)
                let doAction:UIAlertAction = UIAlertAction(title: "退会", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                    
                    var GroupUpdateValue: FieldValue
                    var UserUpdateValue: FieldValue
                    
                    GroupUpdateValue = FieldValue.arrayRemove([myUid])
                    UserUpdateValue = FieldValue.arrayRemove([self.myNowGroup!])
                    
                    let groupRef = db.collection(Const.ChatRooms).document(self.myNowGroup!)
                    let userRef = db.collection(Const.User).document(myUid)
                    userRef.getDocument() {(doument,err) in
                        if let err = err {
                            print(err)
                            return
                        }
                            groupRef.updateData(["membar":GroupUpdateValue])
                            userRef.updateData(["groupId":UserUpdateValue])
                        
                        SVProgressHUD.showSuccess(withStatus: "「\(self.myNowGroupNmae ?? "")」から退会しました。")
                        
                        let storyboar = UIStoryboard(name: "Home", bundle: nil)
                        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
                        let nav = UINavigationController(rootViewController: homeViewController)
                        nav.modalPresentationStyle = .overFullScreen
                        nav.modalTransitionStyle = .coverVertical
                        self.present(nav, animated: true, completion: nil)
                    }
                })
                let canselAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: .default, handler: {(action:UIAlertAction!) -> Void in
                    print("キャンセルが呼ばれた。")
                })
                
                alertController.addAction(canselAction)
                alertController.addAction(doAction)
                
                present(alertController, animated: true, completion: nil)
                
            } else {
                
                let alertController:UIAlertController = UIAlertController(title:"「\(userName)」をグループから削除しますか？", message: "", preferredStyle: .alert)
                let doAction:UIAlertAction = UIAlertAction(title: "削除", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                    
                    var GroupUpdateValue: FieldValue
                    var UserUpdateValue: FieldValue
                    
                    GroupUpdateValue = FieldValue.arrayRemove([userUid])
                    UserUpdateValue = FieldValue.arrayRemove([self.myNowGroup!])
                    
                    let groupRef = db.collection(Const.ChatRooms).document(self.myNowGroup!)
                    let userRef = db.collection(Const.User).document(userUid)
                    userRef.getDocument() {(doument,err) in
                        if let err = err {
                            print(err)
                            return
                        }
                            groupRef.updateData(["membar":GroupUpdateValue])
                            userRef.updateData(["groupId":UserUpdateValue])
                        }
                        
                        SVProgressHUD.showSuccess(withStatus: "「\(userName))」を削除しました。")
                        
                        let storyboar = UIStoryboard(name: "Home", bundle: nil)
                        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
                        let nav = UINavigationController(rootViewController: homeViewController)
                        nav.modalPresentationStyle = .overFullScreen
                        nav.modalTransitionStyle = .coverVertical
                        self.present(nav, animated: true, completion: nil)
                    
                })
                let canselAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: .default, handler: {(action:UIAlertAction!) -> Void in
                    print("キャンセルが呼ばれた。")
                })

                alertController.addAction(canselAction)
                alertController.addAction(doAction)

                present(alertController, animated: true, completion: nil)

            }
        } else {
            
        }
    }
}


