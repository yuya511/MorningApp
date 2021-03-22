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
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var listener: ListenerRegistration?
    var id:String?
    
    @IBAction func hiddenButton(_ sender: Any) {
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let tabbarController = storyboar.instantiateViewController(withIdentifier: "TabBarControllerID") as! UITabBarController
        tabbarController.selectedIndex = 2
        tabbarController.modalPresentationStyle = .fullScreen
        present(tabbarController, animated: true, completion: nil)
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
            
        }
    }
}




class groupProfileSettingViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupTextView: UITextView!
    @IBOutlet weak var membarCountLabel: UILabel!
    
    @IBAction func hidden(_ sender: Any) {
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let tabbarController = storyboar.instantiateViewController(withIdentifier: "TabBarControllerID") as! UITabBarController
        tabbarController.selectedIndex = 2
        tabbarController.modalPresentationStyle = .fullScreen
        present(tabbarController, animated: true, completion: nil)
    }
    
    var id:String?
    var groupNameData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupImageView.layer.cornerRadius = 40
        groupTextView.layer.cornerRadius = 10
        groupTextView.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        groupTextView.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        groupTextView.layer.borderWidth = 1.0
        view.backgroundColor = .rgb(red: 245, green: 245, blue: 245)
        navigationController?.navigationBar.barTintColor = .rgb(red: 240, green: 240, blue: 255)
        groupTextView.isEditable = false
        editButton.isEnabled = false
        editButton.accessibilityElementsHidden = true
        
        setGroupfirebase()
    }
    
    
    private func setGroupfirebase() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            let imageRef = Storage.storage().reference().child(Const.GroupImage).child(id! + ".jpg")
            self.groupImageView.sd_setImage(with: imageRef)
            let groupRef = db.collection(Const.ChatRooms).document(id ?? "err")
            groupRef.getDocument { (documents, err) in
                guard let groupData = documents else { return }
                guard let groupName = groupData["groupName"] else { return }
                self.groupNameLabel.text = groupName as? String
                let membarCount:[String] = groupData["membar"] as! [String]
                self.membarCountLabel.text = String(membarCount.count)
                let groupProfileText:String = groupData["groupProfileText"] as! String
                if groupProfileText != "" {
                    self.groupTextView.text = groupProfileText
                }
            }
        }
    }
}

