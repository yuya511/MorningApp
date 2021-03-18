//
//  ProfileViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/18.
//

import UIKit
import Firebase

class ProfileSettingViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var listener: ListenerRegistration?
    
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
        
        
//        setUserfirebase()
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
        let db = Firestore.firestore()
        let userRef = db.collection(Const.User).document(uid)

        listener = userRef.addSnapshotListener() { (doucuments,err) in
            if let err = err {
                print(err)
                return
            }
            guard let document = doucuments else { return }
            let userData = User(document: document)
            
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
            self.profileImageView.sd_setImage(with: imageRef)
            
            self.userNameLabel.text = userData.username
            
            if userData.profileText != "" {
                self.profileTextView.text = userData.profileText
            }
        }
    }
    
}




class groupProfileSettingViewController: UIViewController {
    
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
        
        setGroupfirebase()
    }
    
    
    private func setGroupfirebase() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            
            let userRef = db.collection(Const.User).document(uid)
            userRef.getDocument { (doucuments,err) in
                if let err = err {
                    print(err)
                    return
                }
                guard let document = doucuments else { return }
                let userData = User(document: document)
                guard let groupName = userData.groupname else { return }
                let imageRef = Storage.storage().reference().child(Const.GroupImage).child(groupName + ".jpg")
                self.groupImageView.sd_setImage(with: imageRef)
                
                let groupRef = db.collection(Const.ChatRooms).document(groupName)
                groupRef.getDocument { (documents, err) in
                    guard let document = documents else { return }
                    guard let groupName = document["groupName"] else { return }
                    self.groupNameLabel.text = groupName as? String
                    let membarCount:[String] = document["membar"] as! [String]
                    self.membarCountLabel.text = String(membarCount.count)
                    let groupProfileText:String = document["groupProfileText"] as! String
                    if groupProfileText != "" {
                        self.groupTextView.text = groupProfileText
                    }
                }
            }
        }
    }
}

