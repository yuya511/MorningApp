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
    
    var targetTime:Date? {
        //ストアドプロパティを監視する。変更されたら呼ばれる
        didSet {
            timeMonitor()
            //比較のためにdate型の状態で保存している
            UserDefaults.standard.set(targetTime, forKey: "SETDATE")
            //datePickerの時間の値をStringに変換して、UserDefaultsに保存している
            let japanTime:String = formatChang(date: targetTime ?? Date())
            UserDefaults.standard.set(japanTime, forKey: "SETTIME")
        }
    }
    
    var firest:Bool?
    
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
        setChatrooms()
        timeMonitor()
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
        HomeTableView.backgroundColor = .rgb(red: 240, green: 255, blue: 255)
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
        navigationController?.navigationBar.barTintColor = .rgb(red: 65, green: 105, blue: 255)
        self.navigationItem.title = "\(UserDefaults.standard.string(forKey: "SETTIME") ?? "")に起きます！"
        
        let myRightItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(settingButton))
        self.navigationItem.rightBarButtonItem = myRightItem
        self.navigationItem.rightBarButtonItem?.tintColor = .white
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.white
        ]

        //カスタムセルの登録
        HomeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        HomeTableView.register(UINib(nibName: "MorningTableViewCell", bundle: nil), forCellReuseIdentifier: cellId02)
       
    }
    
    //編集ボタン
    @objc func settingButton() {
        print("rightButton")
        let storyboar = UIStoryboard(name: "MorningChuck", bundle: nil)
        let morningSettingViewController = storyboar.instantiateViewController(identifier: "MorningSettingViewController") as! MorningSettingViewController
        let nav = UINavigationController(rootViewController: morningSettingViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //chatroomの監視
    func setChatrooms() {
        
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
    
    
    private func timeMonitor() {
        let now = Date()
        print("***now",now)
        
        guard let setTimeDate = load(key: "SETDATE") else { return }
        print("***setTimeDate",setTimeDate)
            
        let pullModifiedDate = Calendar.current.date(byAdding: .minute, value: -15, to: setTimeDate)!
        let addModifiedDate = Calendar.current.date(byAdding: .minute, value: 15, to: setTimeDate)!
        
        
        print("***addModifiedDate,pullModifiedDate",addModifiedDate,pullModifiedDate)
        
        if pullModifiedDate <= now && now <= addModifiedDate {
            
            print("範囲内です")
            if firest ?? true {
                let storybar = UIStoryboard(name: "MorningChuck", bundle: nil)
                let morningChuckViewController = storybar.instantiateViewController(identifier: "MorningChuckViewController") as! MorningChuckViewController
                morningChuckViewController.modalPresentationStyle = .fullScreen
                present(morningChuckViewController, animated: true, completion: nil)
            } else {
                print("***二回目です")
            }
            
        } else {
            print("範囲外です")
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
