//
//  MorningChuckViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/08.
//

import UIKit
import Firebase

//朝の最初の画面
class MorningChuckViewController: UIViewController {

    @IBOutlet weak var morningMessage: UILabel!
    @IBOutlet weak var tappedMessage: UILabel!
    @IBOutlet var morningView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(MorningChuckViewController.tapped(_:)))
        
        // デリゲートをセット
        tapGesture.delegate = self
        
        self.view.addGestureRecognizer(tapGesture)
            
    }
       
}
//最初のタップのデリゲートメソッド
extension MorningChuckViewController: UIGestureRecognizerDelegate {
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            let storyboar = UIStoryboard(name: "MorningChuck", bundle: nil)
            let morningRecrdViewController = storyboar.instantiateViewController(identifier:"MorningRecrdViewController") as! MorningRecrdViewController
            
            morningRecrdViewController.modalPresentationStyle = .fullScreen
            self.present(morningRecrdViewController, animated: true, completion: nil)
        }
    }
}

//朝の目標設定画面
class MorningRecrdViewController: UIViewController {
    
    @IBAction func decisionButton(_ sender: Any) {
        
        morningFirebase()
        
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        homeViewController.firest = false
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func morningFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { (document, err) in
            if let err = err {
                print(err)
                return
            }
            guard let dic = document?.data() else { return }
            guard let username = dic["username"] else { return }
            
            let chatroomRef = Firestore.firestore().collection(Const.ChatRooms).document()
            
            let chatroomDic = [
                "name": username,
                "text": "",
                "stamp": true,
                "date": Timestamp(),
                "uid": uid,
            ] as [String : Any]
            chatroomRef.setData(chatroomDic)
            print("tappedMorningButtonの情報が保存されました")
        }
    }
}



class MorningSettingViewController: UIViewController {
    
    @IBOutlet weak var firestTextField: UITextField!
    @IBOutlet weak var firest02TextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var second02TextField: UITextField!
    
    @IBOutlet weak var settingButton: UIButton!
    
    var data :[String] = ["4","5","6","7","8","9","10",]
    var data02 :[String] = ["00","10","20","30","40","50"]
    
    var pickerView: UIPickerView = UIPickerView()
    var pickerView02: UIPickerView = UIPickerView()
    
    var startTime:String?
    var endTime:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerView()
        
        
        settingButton.backgroundColor = .darkGray
        settingButton.isEnabled = false
        
        settingButton.layer.cornerRadius = 10
        settingButton.addTarget(self, action: #selector(tappedSettingButton), for: .touchUpInside)
        
    }
    
    
    @objc func tappedSettingButton() {
        
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        homeViewController.firestTime = startTime
        homeViewController.endTime = endTime
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: true, completion: nil)
    }
    
    
    func createPickerView() {
        pickerView.delegate = self
        pickerView.tag = 1
        pickerView02.delegate = self
        pickerView02.tag = 2
        firestTextField.inputView = pickerView
        firest02TextField.inputView = pickerView
        secondTextField.inputView = pickerView02
        second02TextField.inputView = pickerView02
       
        // toolbar
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action:#selector(donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        firestTextField.inputAccessoryView = toolbar
        firest02TextField.inputAccessoryView = toolbar
        secondTextField.inputAccessoryView = toolbar
        second02TextField.inputAccessoryView = toolbar
    }
    //ツールバーのボタンでキーボード閉じる
    @objc func donePicker() {
        firestTextField.endEditing(true)
        firest02TextField.endEditing(true)
        secondTextField.endEditing(true)
        second02TextField.endEditing(true)
    }
    //タップでキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        firestTextField.endEditing(true)
        firest02TextField.endEditing(true)
        secondTextField.endEditing(true)
        second02TextField.endEditing(true)
    }
    
}


extension MorningSettingViewController: UIPickerViewDelegate,UIPickerViewDataSource  {
    //列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return data.count
        case 1:
            return data02.count
        default:
            return 0
        }
    }
    //タイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return data[row]
        case 1:
            return data02[row]
        default:
            return ""
        }
    }
    
    //選ばれた行
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            
          
            switch component {
            case 0:
                firestTextField.text = data[row]
            case 1:
                firest02TextField.text = data02[row]
            default:
                firestTextField.text = ""
            }
            guard let da = firestTextField.text else { return }
            //0埋め
            guard let daInt = Int(da) else { return }
            let d1 = NSString(format: "%02d", daInt)
            
            guard let da02 = firest02TextField.text else { return }
            
            startTime = "\(String(describing: d1)):\(String(describing: da02))"
        } else {
            switch component {
            case 0:
                secondTextField.text = data[row]
            case 1:
                second02TextField.text = data02[row]
            default:
                firestTextField.text = ""
            }
            guard let da = secondTextField.text else { return }
            //0埋め
            guard let daInt = Int(da) else { return }
            let d1 = NSString(format: "%02d", daInt)
            
            guard let da02 = second02TextField.text else { return }
            endTime = "\(String(describing: d1)):\(String(describing: da02))"
        }
        
      
        if startTime?.isEmpty ?? true || endTime?.isEmpty ?? true {
            settingButton.isEnabled = false
        } else {
            settingButton.isEnabled = true
            settingButton.backgroundColor = .white
        }
    }
}


