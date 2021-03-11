//
//  MorningChuckViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/08.
//

import UIKit
import Firebase

//朝の最初の画面
class MorningChuckViewController: UIViewController {

    @IBOutlet weak var morningMessage: UILabel!
    @IBOutlet weak var tappedMessage: UILabel!
    @IBOutlet var morningView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(MorningChuckViewController.tapped(_:)))
        
        // デリゲートをセット
        tapGesture.delegate = self
        
        self.view.addGestureRecognizer(tapGesture)
            
    }
       
}
//最初のタップのデリゲートメソッド
extension MorningChuckViewController: UIGestureRecognizerDelegate {
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
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
    //決定ボタン
    @IBAction func decisionButton(_ sender: Any) {
        
        morningFirebase()
        setMorningRecrdViewController()
      
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        targetSettingTextView.layer.cornerRadius = 10
        decisionButtonOutlet.layer.cornerRadius = 5
    }
    
    private func setMorningRecrdViewController() {
        
        UserDefaults.standard.set(Date(), forKey: "NOWDATE")
        
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
    }
    
    func morningFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { (document, err) in
            if let err = err {
                print(err)
                return
            }
            guard let dic = document?.data() else { return }
            guard let username = dic["username"] else { return }
            guard let text = self.targetSettingTextView.text else { return }
            
            let chatroomRef = Firestore.firestore().collection(Const.ChatRooms).document()
            
            let chatroomDic = [
                "name": username,
                "text": text,
                "stamp": true,
                "date": Timestamp(),
                "uid": uid,
                "chatId": chatroomRef.documentID
            ] as [String : Any]
            chatroomRef.setData(chatroomDic)
            print("tappedMorningButtonの情報が保存されました")
        }
    }
}



class MorningSettingViewController: UIViewController {
    
   
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func changedPicker(_ sender: Any) {
        
        settingTime = datePicker.date
        
        settingButton.backgroundColor = .white
        settingButton.isEnabled = true
        
    }
    
    var settingTime:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            // 文字の色
            .foregroundColor: UIColor.white
        ]
    }
    
    @objc func backButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func tappedSettingButton() {
        
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        
        homeViewController.targetTime = settingTime
        
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: true, completion: nil)
    }
   
}


