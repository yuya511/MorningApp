//
//  DescriptionViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/04/24.
//

import UIKit
import SVProgressHUD

class DescriptionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setDefault()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SVProgressHUD.showSuccess(withStatus: "スクロールでページ変更！")
    }
    
    private func setDefault() {
      
    }
}
