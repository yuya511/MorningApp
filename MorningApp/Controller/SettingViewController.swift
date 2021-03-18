//
//  SettingViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/10.
//

import UIKit
import Firebase
import FirebaseUI

class SettingViewController: UIViewController {

    @IBAction func logOutButton(_ sender: Any) {
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
    
    @IBAction func pofileChangeButton(_ sender: Any) {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let profileSettingViewController = storyboar.instantiateViewController(identifier: "ProfileSettingViewController") as! ProfileSettingViewController
        let nav = UINavigationController(rootViewController: profileSettingViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func groupChangeButton(_ sender: Any) {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let groupProfileSettingViewController = storyboar.instantiateViewController(identifier: "groupProfileSettingViewController") as! groupProfileSettingViewController
        let nav = UINavigationController(rootViewController: groupProfileSettingViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}





