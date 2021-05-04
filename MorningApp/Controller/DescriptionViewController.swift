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
    }
    
    private func setDefault() {
        let alertController:UIAlertController = UIAlertController(title: "インストール圧倒的感謝です", message: "アプリの使い方を説明しているので見ていただけると嬉しいです", preferredStyle: .alert)
        let okAction: UIAlertAction =
            UIAlertAction(title: "もちろん!",
                          style: .default,
                          handler: {
                            (action:UIAlertAction!) -> Void in
                            SVProgressHUD.showSuccess(withStatus: "スクロールでページ変更！")
            })
        let sosoAction:UIAlertAction =
            UIAlertAction(title: "しゃーなしいいよ",
                          style: .default,
                          handler: {
                            (action:UIAlertAction!) -> Void in
                            SVProgressHUD.showSuccess(withStatus: "スクロールでページ変更！")
                          })
        alertController.addAction(okAction)
        alertController.addAction(sosoAction)
        present(alertController, animated: true, completion: nil)
    }
}
