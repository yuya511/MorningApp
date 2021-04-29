//
//  ViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/19.
//

import UIKit
import Firebase
import UserNotifications

class HomeViewController: UIViewController {
    
    @IBOutlet weak var HomeTableView: UITableView!
    
    var targetTime:Date? {
        //ストアドプロパティを監視する。変更されたら呼ばれる
        didSet {
            timeMonitor()
            //比較のためにdate型の状態で保存している
            UserDefaults.standard.set(targetTime, forKey: "SETDATE")
            //datePickerの時間の値をStringに変換して、UserDefaultsに保存している->表示用
            let displayTime:String = formatChang(date: targetTime ?? Date())
            UserDefaults.standard.set(displayTime, forKey: "SETTIME")
            setNotification()
        }
    }
    
    private let cellId = "cellId"
    private let cellId02 = "cellId02"
    
    private var listener: ListenerRegistration?
    var firest:Bool?
    var timer:Timer?
    private var users = [User]()
    private var chat = [Chatroom]()
    private var nowGroup:String?
    private var groupName:String? {
        didSet {
            if let groupName = groupName {
                self.navigationItem.title = "\(String(describing: groupName))"
            }
        }
    }
    
    private let chatInputAccessoryHeight: CGFloat = 100
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicateorInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
   
   
    //インプットアクセサリービューの設置
    private lazy var chatInputAccessoryView: ChatInputAccessory = {
        let view = ChatInputAccessory()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: chatInputAccessoryHeight)
        view.delegate = self
        return view
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        
        setUpHomeTableView()
        setUpNotification()

        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipeGesture.direction = .right
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipeGesture.direction = .left
        view.addGestureRecognizer(rightSwipeGesture)
        view.addGestureRecognizer(leftSwipeGesture)
//        menuReload()
        checkLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUser()
        checkLogin()
        timeCheck()
        menuReload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            print("***swiped left menuViewController")
        case .right:
            let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID")  as! UITabBarController
            tabbarController.selectedIndex = 0
            tabbarController.modalPresentationStyle = .overFullScreen
            tabbarController.modalTransitionStyle = .crossDissolve
            present(tabbarController, animated: true, completion: nil)
        default:
            break
        }
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
       
    private func setUpNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func menuReload() {
        let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID") as! UITabBarController
        tabbarController.selectedIndex = 0
        tabbarController.modalPresentationStyle = .overFullScreen
        tabbarController.modalTransitionStyle = .crossDissolve
        
        present(tabbarController, animated: true, completion: nil)
    }
    
    private func setUpHomeTableView() {
        HomeTableView.delegate = self
        HomeTableView.dataSource = self
        HomeTableView.backgroundColor = .rgb(red: 220, green: 230, blue: 245)
        HomeTableView.contentInset = .init(top: 60, left: 0, bottom: 0, right: 0)
        HomeTableView.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
        //下に表示されるように逆さまにしている。
        HomeTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        HomeTableView.keyboardDismissMode = .interactive
        //ナビゲーションバーの設定
        navigationController?.navigationBar.barTintColor = .rgb(red: 240, green: 240, blue: 255)
        let myRightItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(groupSelectButton))
        self.navigationItem.rightBarButtonItem = myRightItem
        self.navigationItem.rightBarButtonItem?.tintColor = .rgb(red: 100, green: 150, blue: 255)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.rgb(red: 100, green: 150, blue: 255)
        ]
        //カスタムセルの登録
        HomeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        HomeTableView.register(UINib(nibName: "MorningTableViewCell", bundle: nil), forCellReuseIdentifier: cellId02)
    }
    //グループ追加ボタン
    @objc func groupSelectButton() {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let chatroomSettingViewController = storyboar.instantiateViewController(identifier: "chatroomSettingViewController") as! chatroomSettingViewController
        let nav = UINavigationController(rootViewController: chatroomSettingViewController)
        chatroomSettingViewController.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //通知の処理
    func setNotification() {
        guard let setTimeDate = load(key: "SETDATE") else { return }
        print("*** 通知が設定された")
        //通知の内容を設定
        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = "おはようございます"
        content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "霧雨.mp3"))
        //通知の発動のトリガーを設定
        let calendar = Calendar.current
        var trigger : UNNotificationTrigger
        let dateComponents = calendar.dateComponents([.hour,.minute], from: setTimeDate)
        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        //identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存)
        let request = UNNotificationRequest(identifier: "id", content: content, trigger: trigger)
        //ローカル通知を登録する
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "***ローカル通知の登録完了")
        }
        //未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("***request",request)
            }
        }
    }
      
    //userのnowGroupに変更を監視
    func setUser() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let UserRef = Firestore.firestore().collection(Const.User).document(uid)
            listener = UserRef.addSnapshotListener() { querySnapshot, err in
                if let err = err {
                    print("err",err)
                    return
                }
                guard let UserData = querySnapshot?.data() else { return }
                guard let nowGroup = UserData["nowGroup"] else { return }
                self.nowGroup = nowGroup as? String
                self.setChatrooms(nowGroup: nowGroup as? String ?? "")
            }
        }
    }
    
    func setChatrooms(nowGroup:String) {
        if Auth.auth().currentUser != nil {
            let db = Firestore.firestore()
            let groupRef = db.collection(Const.ChatRooms).document(nowGroup)
            groupRef.getDocument() { document,err in
                if let err = err {
                    print(err)
                    return
                }
                let groupData = document?.data()
                guard let groupName = groupData?["groupName"] else { return }
                self.groupName = groupName as? String
            }
            let chatroomsRef = db.collection(Const.ChatRooms).document(nowGroup).collection(Const.Chat).order(by: "date", descending: true)
            self.listener = chatroomsRef.addSnapshotListener() {(querysnapshot, err) in
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
    
    func checkLogin() {
        if Auth.auth().currentUser?.uid == nil {
            let storyboar = UIStoryboard(name: "SingUp",bundle: nil)
            let FirestViewController = storyboar.instantiateViewController(identifier: "FirestViewController") as! FirestViewController
            FirestViewController.modalPresentationStyle = .fullScreen
            self.present(FirestViewController, animated: true, completion: nil)
        }
    }
    
    func timeCheck() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.timeMonitor), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func timeMonitor() {
        let now = Date()
                
        let nowString = formatChang(date: now)
        guard let setTimeDate = load(key: "SETDATE") else { return }
        let pullModifiedDate = Calendar.current.date(byAdding: .minute, value: -15, to: setTimeDate)!
        let pullModifiedString = formatChang(date: pullModifiedDate)
        let addModifiedDate = Calendar.current.date(byAdding: .minute, value: 15, to: setTimeDate)!
        let addModifiedString = formatChang(date: addModifiedDate)
        if pullModifiedString <= nowString && nowString <= addModifiedString {
            print("***範囲内")
            let dt2 = now.addingTimeInterval(-60 * 60 * 24)
            //今日かどうかを判定->trueなら今日
            let todayMark:Bool = Calendar.current.isDateInToday(load(key: "NOWDATE") ?? dt2)
            if !todayMark {
                let storybar = UIStoryboard(name: "MorningChuck", bundle: nil)
                let morningChuckViewController = storybar.instantiateViewController(identifier: "MorningChuckViewController") as! MorningChuckViewController
                morningChuckViewController.modalPresentationStyle = .fullScreen
                present(morningChuckViewController, animated: true, completion: nil)
            } else {
                print("***2回目")
            }
        } else {
            print("+範囲外")
        }
    }
    //userdafaultsでdate型を取り出すために型をキャストするためのメソッド
    private func load(key: String) -> Date? {
        let value = UserDefaults.standard.object(forKey: key)
        guard let date = value as? Date else {
            return nil
        }
        return date
    }
    //日本時間の”○時○分”に変えるメソッド
    func formatChang(date:Date) -> String {
        let dateFormatter = DateFormatter()
        // フォーマット設定
        dateFormatter.dateFormat = "HH:mm"
        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // タイムゾーン設定（端末設定によらず、どこの地域の時間帯なのかを指定する）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        // 変換
        let date = dateFormatter.string(from: date)
        return date
    }
}


//HomeTableView delegate method
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
            //応援ボタン
            cell02.fireButton.addTarget(self, action: #selector(tappedfireButton), for: .touchUpInside)
        let chatData = chat[indexPath.row]
        //stampがtrue or false で判断
        switch chatData.stamp {
            case true:
                return cell02
            case false:
                return cell
            default:
                return cell
        }
    }
    
    @objc func tappedfireButton(_ sender: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.HomeTableView)
        let indexPath = HomeTableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let chatData = chat[indexPath!.row]
        if let myUid = Auth.auth().currentUser?.uid {
            var updateValue: FieldValue
            // 更新データを作成する
            if chatData.isSupport {
                updateValue = FieldValue.arrayRemove([myUid])
            } else {
                updateValue = FieldValue.arrayUnion([myUid])
            }
            let chatRoomRef = Firestore.firestore().collection(Const.ChatRooms).document(nowGroup ?? "").collection(Const.Chat).document(chatData.chatId ?? myUid)
            chatRoomRef.updateData(["supports": updateValue])
            //応援した数
            let userRef = Firestore.firestore().collection(Const.User).document(myUid)
            userRef.getDocument() {(document,err) in
                if let err = err {
                    print(err)
                    return
                }
                var newDoSupport: Int
                let userData = document?.data()
                let doSupport:Int = userData?["doSupport"] as? Int ?? 0
                
                if chatData.isSupport {
                    newDoSupport = doSupport - 1
                } else {
                    newDoSupport = doSupport + 1
                }
                userRef.updateData([
                    "doSupport": newDoSupport
                ])
            }
            //応援された数
            guard let uid = chatData.uid else { return }
            let usersRef = Firestore.firestore().collection(Const.User).document(uid)
            usersRef.getDocument() {(document,err)in
                if let err = err {
                    print(err)
                    return
                }
                let usersData = document?.data()
                var newDoSupport: Int
                let BedoneSupport:Int = usersData?["BedoneSupport"] as? Int ?? 0
                if chatData.isSupport {
                    newDoSupport = BedoneSupport - 1
                } else {
                    newDoSupport = BedoneSupport + 1
                }
                usersRef.updateData([
                    "BedoneSupport": newDoSupport
                ])
            }
        }
    }
}


//アクセサリービューで作ったデリゲートメソッド
extension HomeViewController: ChatInputAccessoryDelegate {
    func tappedSendButton(text: String) {
        chatInputAccessoryView.removeText()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let username = Auth.auth().currentUser?.displayName else { return }
        let userRef = Firestore.firestore().collection(Const.User).document(uid)
        userRef.getDocument { (documents, err) in
            if let err = err {
                print("err",err)
            }
            guard let document = documents?.data() else { return }
            let nowGroup = document["nowGroup"] ?? "まだグループに参加していません"
            let chatroomRef = Firestore.firestore().collection(Const.ChatRooms).document(nowGroup as! String).collection(Const.Chat).document()
            let chatroomDic = [
                "name": username,
                "text": text,
                "stamp": false,
                "date": Timestamp(),
                "uid": uid,
                "chatId": chatroomRef.documentID
            ] as [String : Any]
            chatroomRef.setData(chatroomDic)
            print("***chatroomの情報が保存されました")
        }
    }
}

