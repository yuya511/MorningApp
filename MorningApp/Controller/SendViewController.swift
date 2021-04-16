//
//  SendViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/04/05.
//

import UIKit
import Firebase
import SVProgressHUD


class SendViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var sendTextView: UITextView!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    @IBAction func sendButtonAction(_ sender: Any) {
        setFirebase()
    }
    @IBAction func hiddenButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        sendTextView.delegate = self
        sendTextView.layer.borderColor = UIColor.rgb(red: 200, green: 200, blue: 200).cgColor
        sendTextView.layer.borderWidth = 1.0
        sendTextView.layer.cornerRadius = 10
        sendButtonOutlet.layer.cornerRadius = 10
        sendButtonOutlet.isEnabled = false
        sendButtonOutlet.backgroundColor = .rgb(red: 150, green: 150, blue:150)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 200
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setFirebase() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let opinionText = sendTextView.text else { return }
        let opinionRef = db.collection(Const.Opinion).document()
        
        let docData = [
            "uid": uid,
            "opinion": opinionText
        ] as [String : Any]
        
        opinionRef.setData(docData)
        print("意見が送られました")
        SVProgressHUD.showSuccess(withStatus: "ご意見ありがとうございます！")
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let sendTextViewEmpty = sendTextView.text.isEmpty
        if sendTextViewEmpty {
            sendButtonOutlet.isEnabled = false
            sendButtonOutlet.backgroundColor = .rgb(red: 150, green: 150, blue:150)
        } else {
            sendButtonOutlet.isEnabled = true
            sendButtonOutlet.backgroundColor = .rgb(red: 0, green: 130, blue:255)
        }
    }
}
