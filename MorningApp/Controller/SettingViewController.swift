//
//  SettingViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/10.
//

import UIKit
import Firebase

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
   
   

}
