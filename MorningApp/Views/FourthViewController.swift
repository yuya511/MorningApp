//
//  FourthViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/04/30.
//

import UIKit

class FourthViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefault()
    }
    private func setDefault() {
        startButton.layer.cornerRadius = 10
        startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
    }
    
    @objc private func startButtonAction() {
        if UserDefaults.standard.bool(forKey: "firestTime") {
            let storyboar = UIStoryboard(name: "Home", bundle: nil)
            let HomeViewController = storyboar.instantiateViewController(withIdentifier: "Home") as! HomeViewController
            let nav = UINavigationController(rootViewController: HomeViewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        } else {
            UserDefaults.standard.set(true, forKey: "firestTime")
            let storyboar = UIStoryboard(name: "MorningChuck", bundle: nil)
            let MorningSettingViewController = storyboar.instantiateViewController(withIdentifier: "MorningSettingViewController") as! MorningSettingViewController
            let nav = UINavigationController(rootViewController: MorningSettingViewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
}
