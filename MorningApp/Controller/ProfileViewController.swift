//
//  ProfileViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/18.
//

import UIKit
import Firebase
import SVProgressHUD

//ユーザのプロフィール画面
class ProfileSettingViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var doSupportCountLabel: UILabel!
    @IBOutlet weak var BeDoneSupportCountLabel: UILabel!
    
    
    var listener: ListenerRegistration?
    var id:String?
    
    @IBAction func hiddenButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        
        profileImageView.layer.cornerRadius = 50
        profileTextView.layer.cornerRadius = 10
        profileTextView.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        profileTextView.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        profileTextView.layer.borderWidth = 1.0
        view.backgroundColor = .rgb(red: 245, green: 245, blue: 245)
        navigationController?.navigationBar.barTintColor = .rgb(red: 240, green: 240, blue: 255)
        profileTextView.isEditable = false
        editButton.accessibilityElementsHidden = true
        editButton.isEnabled = false
    }
    
    @objc private func logOut() {
        let alertController:UIAlertController = UIAlertController(title:"ログアウトしますか？", message: "", preferredStyle: .alert)
        let doAction:UIAlertAction = UIAlertAction(title: "ログアウト", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
            do {
                try Auth.auth().signOut()
                SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
                let storyboard = UIStoryboard(name: "SingUp", bundle: nil)
                let firestViewController = storyboard.instantiateViewController(withIdentifier: "FirestViewController") as! FirestViewController
                firestViewController.modalPresentationStyle = .fullScreen
                self.present(firestViewController, animated: true, completion: nil)
            } catch {
                SVProgressHUD.showError(withStatus: "エラー")
                print("ログアウトに失敗しました。\(error)")
            }
        })
        let canselAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: .default, handler: {(action:UIAlertAction!) -> Void in
            print("キャンセルが呼ばれた。")
        })
        
        alertController.addAction(canselAction)
        alertController.addAction(doAction)
        
        present(alertController, animated: true, completion: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserfirebase()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listener?.remove()
    }
    
    private func setUserfirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if id == uid {
            logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
            editButton.accessibilityElementsHidden = false
            editButton.isEnabled = true
        } else {
            editButton.accessibilityElementsHidden = true
            editButton.isEnabled = false
            logOutButton.setTitle("通報する", for: .normal)
            logOutButton.addTarget(self, action: #selector(report), for: .touchUpInside)
        }
        let db = Firestore.firestore()
        let userRef = db.collection(Const.User).document(self.id ?? uid)
        listener = userRef.addSnapshotListener() { (doucuments,err) in
            if let err = err {
                print(err)
                return
            }
            guard let document = doucuments else { return }
            let userData = User(document: document)
            
            if let id = self.id {
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(id + ".jpg")
                self.profileImageView.sd_setImage(with: imageRef)
            } else {
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
                self.profileImageView.sd_setImage(with: imageRef)
            }
            self.userNameLabel.text = userData.username
            if userData.profileText != "" {
                self.profileTextView.text = userData.profileText
            }
            self.doSupportCountLabel.text = String(userData.doSupport ?? 0)
            self.BeDoneSupportCountLabel.text = String(userData.BedoneSupport ?? 0)
        }
    }
    
    @objc func report() {
        let alertController:UIAlertController = UIAlertController(title:"通報しますか？", message: "通報すると該当ユーザの情報を送信します", preferredStyle: .alert)
        let doAction:UIAlertAction = UIAlertAction(title: "通報する", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
            print("通報するが呼ばれた。")
            let db = Firestore.firestore()
            guard let uid =  Auth.auth().currentUser?.uid else {return}
            let banRef = db.collection(Const.Ban).document()
            let docData = [
                "documentID": banRef.documentID,
                "sendUser": uid,
                "banUser": self.id ?? "",
                "time": Timestamp()
            ] as [String : Any]
            
            banRef.setData(docData) {
                (err) in
                if err != nil {
                    print("err")
                    return
                }
            }
            SVProgressHUD.showSuccess(withStatus: "通報しました")
            let storyboar = UIStoryboard(name: "Home", bundle: nil)
            let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
            let nav = UINavigationController(rootViewController: homeViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        })
        
        let canselAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: .default, handler: {(action:UIAlertAction!) -> Void in
            print("キャンセルが呼ばれた。")
        })
        
        alertController.addAction(canselAction)
        alertController.addAction(doAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
}





//グループのプロフィール画面
class groupProfileSettingViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupTextView: UITextView!
    @IBOutlet weak var membarCountLabel: UILabel!
    @IBOutlet weak var exitButtonOutlet: UIButton!
    
    var groupId:String?
    var nowGroup:String?
    var groupName:String?
    var groupNameData = [String]()
    var membarCount = [String]()
    var groupIdList = [String]()
    let db = Firestore.firestore()

    
    @IBAction func editAction(_ sender: Any) {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let groupEditViewController = storyboar.instantiateViewController(identifier: "groupEditViewController") as! groupEditViewController
        groupEditViewController.groupId = self.groupId
        let nav = UINavigationController(rootViewController: groupEditViewController)
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func hidden(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        let alertController:UIAlertController = UIAlertController(title:"「\(self.groupName ?? "")」から退会しますか？", message: "", preferredStyle: .alert)
            let doAction:UIAlertAction = UIAlertAction(title: "退会", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
        
                var GroupUpdateValue: FieldValue
                var UserUpdateValue: FieldValue
                
                if let uid = Auth.auth().currentUser?.uid {
                    GroupUpdateValue = FieldValue.arrayRemove([uid])
                    UserUpdateValue = FieldValue.arrayRemove([self.groupId!])
                    
                    let groupRef = self.db.collection(Const.ChatRooms).document(self.groupId!)
                    let userRef = self.db.collection(Const.User).document(uid)
                    userRef.getDocument() {(doument,err) in
                        if let err = err {
                            print(err)
                            return
                        }
                        if self.nowGroup == self.groupId {
                            groupRef.updateData(["membar":GroupUpdateValue])
                            userRef.updateData(["groupId":UserUpdateValue])
                            userRef.updateData(["nowGroup":self.groupIdList[0]])
                        } else {
                            groupRef.updateData(["membar":GroupUpdateValue])
                            userRef.updateData(["groupId":UserUpdateValue])
                        }
                        let storyboar = UIStoryboard(name: "Home", bundle: nil)
                        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
                        let nav = UINavigationController(rootViewController: homeViewController)
                        nav.modalPresentationStyle = .overFullScreen
                        nav.modalTransitionStyle = .coverVertical
                        self.present(nav, animated: true, completion: nil)
                    }
                }
                
            })
            let canselAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: .default, handler: {(action:UIAlertAction!) -> Void in
                print("キャンセルが呼ばれた。")
            })
        
            alertController.addAction(canselAction)
            alertController.addAction(doAction)
        
            present(alertController, animated: true, completion: nil)

        
       
        
    }
            
    override func viewDidLoad() {
        self.overrideUserInterfaceStyle = .light
        super.viewDidLoad()
        groupImageView.layer.cornerRadius = 25
        groupTextView.layer.cornerRadius = 10
        groupTextView.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        groupTextView.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        groupTextView.layer.borderWidth = 1.0
        view.backgroundColor = .rgb(red: 245, green: 245, blue: 245)
        navigationController?.navigationBar.barTintColor = .rgb(red: 240, green: 240, blue: 255)
        groupTextView.isEditable = false
        
        setGroupfirebase()
    }
    
    
    private func setGroupfirebase() {
        if Auth.auth().currentUser != nil {
            let imageRef = Storage.storage().reference().child(Const.GroupImage).child(groupId! + ".jpg")
            self.groupImageView.sd_setImage(with: imageRef)
            let groupRef = db.collection(Const.ChatRooms).document(groupId ?? "err")
            groupRef.getDocument { (documents, err) in
                guard let groupData = documents else { return }
                guard let groupName = groupData["groupName"] else { return }
                self.groupName = groupName as? String
                self.groupNameLabel.text = groupName as? String
                self.membarCount = groupData["membar"] as! [String]
                self.membarCountLabel.text = String(self.membarCount.count)
                let groupProfileText:String = groupData["groupProfileText"] as! String
                if groupProfileText != "" {
                    self.groupTextView.text = groupProfileText
                }
            }
            
            if let uid = Auth.auth().currentUser?.uid {
                let userRef = db.collection(Const.User).document(uid)
                userRef.getDocument() {(doument,err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    let userData = doument?.data()
                    self.nowGroup = userData?["nowGroup"] as? String
                    self.groupIdList = userData?["groupId"] as! [String]
                    self.groupIdList.removeAll(where: {$0 == self.nowGroup!})
                    if self.groupIdList.isEmpty == true {
                        self.exitButtonOutlet.isHidden = true
                    }
                }
            }
        }
    }
}

