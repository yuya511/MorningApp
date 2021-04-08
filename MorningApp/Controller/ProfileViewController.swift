//
//  ProfileViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/18.
//

import UIKit
import Firebase

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
    @IBAction func logOutButton(_ sender: Any) {
        logOut()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        logOutButton.isHidden = true
        logOutButton.isEnabled = false
    }
    
    private func logOut() {
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
            editButton.accessibilityElementsHidden = false
            editButton.isEnabled = true
            logOutButton.isHidden = false
            logOutButton.isEnabled = true        }
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
}




class groupProfileSettingViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupTextView: UITextView!
    @IBOutlet weak var membarCountLabel: UILabel!
    @IBOutlet weak var exitButtonOutlet: UIButton!
    
    var groupId:String?
    var nowGroup:String?
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
        var GroupUpdateValue: FieldValue
        var UserUpdateValue: FieldValue
        
        if let uid = Auth.auth().currentUser?.uid {
            GroupUpdateValue = FieldValue.arrayRemove([uid])
            UserUpdateValue = FieldValue.arrayRemove([groupId!])
            
            let groupRef = db.collection(Const.ChatRooms).document(groupId!)
            let userRef = db.collection(Const.User).document(uid)
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
    }
            
    override func viewDidLoad() {
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

