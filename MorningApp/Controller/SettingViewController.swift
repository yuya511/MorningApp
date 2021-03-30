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

    
    @IBOutlet weak var settingTabelView: UITableView!
    
    private let sectionList:[String] = ["ユーザ・グループ設定","その他"]
    private let userSettingList:[String] = ["ユーザ設定","グループ設定"]
    private let otherSettingList:[String] = ["ご意見・ご要望","通知"]
    private let userImageList:[String] = ["oneUser","weUser"]
    private let otherImageList:[String] = ["mail","notice"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingTabelView.delegate = self
        settingTabelView.dataSource = self
        settingTabelView.backgroundColor = .rgb(red: 220, green: 230, blue: 245)
        navigationController?.navigationBar.barTintColor = .rgb(red: 240, green: 240, blue: 255)
        settingTabelView.sectionHeaderHeight = 75
        settingTabelView.tableFooterView = UIView()
        self.navigationItem.title = "設 定"
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.rgb(red: 100, green: 150, blue: 255)
        ]
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
    
    private func userChange(id:String) {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let profileSettingViewController = storyboar.instantiateViewController(identifier: "ProfileSettingViewController") as! ProfileSettingViewController
        profileSettingViewController.id = id
        let nav = UINavigationController(rootViewController: profileSettingViewController)
        present(nav, animated: true, completion: nil)
    }
    
    private func groupChange() {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let groupProfileSettingViewController = storyboar.instantiateViewController(identifier: "groupProfileSettingViewController") as! groupProfileSettingViewController
        let nav = UINavigationController(rootViewController: groupProfileSettingViewController)
        present(nav, animated: true, completion: nil)
    }
    
    private func groupSelect() {
        let storyboar = UIStoryboard(name: "Setting", bundle: nil)
        let groupSelectViewController = storyboar.instantiateViewController(identifier: "groupSelectViewController") as! groupSelectViewController
        let nav = UINavigationController(rootViewController: groupSelectViewController)
        present(nav, animated: true, completion: nil)
    }
}


extension SettingViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingCell = settingTabelView.dequeueReusableCell(withIdentifier: "settingCell") as! settingCell
        
        switch indexPath.section {
        case 0:
            settingCell.settingLabel.text = userSettingList[indexPath.row]
            settingCell.settingImage.image = UIImage(named: userImageList[indexPath.row])
        case 1:
            settingCell.settingLabel.text = otherSettingList[indexPath.row]
            settingCell.settingImage.image = UIImage(named: otherImageList[indexPath.row])

        default:
            settingCell.settingLabel.text = userSettingList[indexPath.row]
        }
        return settingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                userChange(id: uid)
            } else {
                groupSelect()
            }
        } else if indexPath.section == 1 {
            logOut()
        } else {
        }
    }
    //セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }
    //セクションの名前
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return sectionList[0]
        case 1:
            return sectionList[1]
        default:
            return ""
        }
    }
    
    // セクションの背景とテキストの色を変更する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // 背景色を変更する
        view.tintColor = .rgb(red: 220, green: 230, blue: 245)
        let header = view as! UITableViewHeaderFooterView
        // テキスト色を変更する
        header.textLabel?.textColor = .darkGray
    }
}






class settingCell: UITableViewCell {
    
    @IBOutlet weak var settingImage: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}





