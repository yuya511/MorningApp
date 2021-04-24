//
//  MorningChuckViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/08.
//

import UIKit
import Firebase
import AVFoundation

//朝の最初の画面
class MorningChuckViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var morningMessage: UILabel!
    @IBOutlet weak var tappedMessage: UILabel!
    @IBOutlet var morningView: UIView!
    
    var audioPlayer:AVAudioPlayer!
  
    override func viewDidLoad() {
        setDefault()
    }
    
    private func setDefault() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(MorningChuckViewController.tapped(_:)))
        tapGesture.delegate = self
        // 再生する audio ファイルのパスを取得
        let audioPath = Bundle.main.path(forResource: "霧雨", ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        // auido を再生するプレイヤーを作成する
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer.numberOfLoops = -1
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        audioPlayer.play()
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        self.view.addGestureRecognizer(tapGesture)
    }
}
//最初のタップのデリゲートメソッド
extension MorningChuckViewController: UIGestureRecognizerDelegate {
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            if ( audioPlayer.isPlaying ){
                audioPlayer.stop()
            }
            else{
                audioPlayer.play()
            }
            let storyboar = UIStoryboard(name: "MorningChuck", bundle: nil)
            let morningRecrdViewController = storyboar.instantiateViewController(identifier:"MorningRecrdViewController") as! MorningRecrdViewController
            morningRecrdViewController.modalPresentationStyle = .fullScreen
            self.present(morningRecrdViewController, animated: true, completion: nil)
        }
    }
}






//朝の目標設定画面
class MorningRecrdViewController: UIViewController {
    @IBOutlet weak var targetSettingTextView: UITextView!
    @IBOutlet weak var decisionButtonOutlet: UIButton!
    
    @IBAction func decisionButton(_ sender: Any) {
        morningFirebase()
        setMorningRecrdViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light

        targetSettingTextView.layer.cornerRadius = 10
        decisionButtonOutlet.layer.cornerRadius = 5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setMorningRecrdViewController() {
        let now = Date()
        //今日かどうかを判定するために、保存
        UserDefaults.standard.set(now, forKey: "NOWDATE")
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    private func morningFirebase() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection(Const.User).document(uid)
        userRef.getDocument { document,err in
            if let err = err {
                print(err)
                return
            }
            guard let dic = document?.data() else { return }
            guard let username = dic["username"] else { return }
            guard let text = self.targetSettingTextView.text else { return }
            //groupIdListに配列で入れてから、for文でgroupIdを回している　→　グループ全部に送るため
            guard let groupIdList:[String] = dic["groupId"] as? [String] else { return }
            for groupId in groupIdList {
                let chatroomRef = db.collection(Const.ChatRooms).document(groupId).collection(Const.Chat).document()
                let chatroomDic = [
                    "name": username,
                    "text": text,
                    "stamp": true,
                    "date": Timestamp(),
                    "uid": uid,
                    "chatId": chatroomRef.documentID
                ] as [String : Any]
                chatroomRef.setData(chatroomDic)
                print("***朝の目標の情報が保存されました")
            }
            let userData = document?.data()
            let morningCount:Int = userData?["morningCount"] as! Int
            let newMorningCount = morningCount + 1
            print("***newMorningCount",newMorningCount)
            userRef.updateData([
                "morningCount": newMorningCount
            ])
        }
    }
}





//時間の設定画面
class MorningSettingViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func changedPicker(_ sender: Any) {
        settingTime = datePicker.date
        settingButton.backgroundColor = .rgb(red: 79, green: 104, blue: 220)
        settingButton.isEnabled = true
    }
    var settingTime:Date?
    var time:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefault()
        self.overrideUserInterfaceStyle = .light
    }
   
    private func setDefault() {
        UITabBar.appearance().barTintColor = UIColor.white
        settingButton.backgroundColor = .darkGray
        settingButton.isEnabled = false
        settingButton.layer.cornerRadius = 10
        settingButton.addTarget(self, action: #selector(tappedSettingButton), for: .touchUpInside)
        //ナビゲーションバーの設定
        navigationController?.navigationBar.barTintColor = .white
        let myLefthtItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(backButton))
        self.navigationItem.leftBarButtonItem = myLefthtItem
        self.navigationItem.leftBarButtonItem?.tintColor = .rgb(red: 65, green: 105, blue: 255)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        //datePicker default
        datePicker.datePickerMode = .time
        datePicker.setDate(Date(), animated: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func backButton() {
        //通知を許可するかどうか
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { ( granted, error) in}
        center.delegate = self
        print("***呼ばれている")
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func tappedSettingButton() {
        //通知を許可するかどうか
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { ( granted, error) in}
        center.delegate = self
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        homeViewController.targetTime = settingTime
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}

