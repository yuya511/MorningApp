//
//  RecordViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/03.
//

import UIKit
import Charts
import Firebase

class RecordViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var didLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var mistakeLabel: UILabel!
    
    var successCount = Double()
    var didCount = Double()
    var parsent: Double {
        get {
            return successCount / didCount * 100
        }
    }
    
    var miss: Int {
        get {
            return Int(didCount) - Int(successCount)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNav()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setFirebase()
        
    }
    
  
    
    
    
    func setNav() {
        //ナビゲーションバーの設定
        navigationController?.navigationBar.barTintColor = .rgb(red: 65, green: 105, blue: 255)
        self.navigationItem.title = "記 録"
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.white
        ]

    }
    
    func setFirebase() {
        if Auth.auth().currentUser !=  nil {
            //userを作ったときの時間を取得
            guard let uid = Auth.auth().currentUser?.uid else { return  }
            let userRef = Firestore.firestore().collection(Const.User).document(uid)
            userRef.getDocument { (document, err) in
                if let err = err {
                    print(err)
                    return
                }
                guard let data = document?.data() else {return}
                let createdAt:Timestamp = data["createdAt"] as! Timestamp
                let createdAtDate: Date = createdAt.dateValue()
                //現在時刻を取得
                let nowTime :Date = Date()
                //経過日数を取得
                guard let elapsedDays = Calendar.current.dateComponents([.day], from: createdAtDate, to: nowTime).day else { return }
                let didcount = elapsedDays
                
                self.didCount = Double(didcount)
                //経過日数のデータ
                self.didLabel.text = "\(didcount) 日"
                
                let chatRef = Firestore.firestore().collection(Const.ChatRooms)
                let query = chatRef.whereField("uid", isEqualTo: uid).whereField("stamp", isEqualTo: true)
                query.getDocuments { (snaps, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    guard let snaps = snaps else {return}
                    
                    let successcount = snaps.documents.count
                    self.successCount = Double(successcount)
                    
                    //成功日数のデータ
                    self.successLabel.text = "\(successcount) 日"
                    //グラフの中心のデータ
                    self.percentLabel.text = "\(String(self.parsent))%"
                    //失敗日数のデータ
                    self.mistakeLabel.text = "\(String(self.miss)) 日"
                    print("didCount",self.didCount)
                    print("miss",self.miss)
                    
                    self.setChart()
                }
            }
        }
    }
    
    func setChart() {
        
        print("successCount",successCount)
                
        pieChartView.noDataText = "まだデータがありません"
        pieChartView.highlightPerTapEnabled = false //データをタップできるかどうか
        pieChartView.chartDescription?.enabled = false  // グラフの説明を非表示
        pieChartView.drawEntryLabelsEnabled = false  // グラフ上のデータラベルを非表示
        pieChartView.legend.enabled = false  // グラフの注釈を非表示
        
        
        // グラフに表示するデータのタイトルと値
        let dataEntries = [
            PieChartDataEntry(value: successCount, label: ""),
            PieChartDataEntry(value: Double(miss), label: "")
        ]
        
        
        //データをセットする
        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        //データの数字を消す
        dataSet.drawValuesEnabled = false
        
        
        // グラフの色
        let colors = [UIColor(named: "GoodColor"), UIColor(named: "NoColor")]
        dataSet.colors = colors as! [NSUIColor]
        
        //viewにデータを入れる
        self.pieChartView.data = PieChartData(dataSet: dataSet)
        
        pieChartView.backgroundColor = .rgb(red: 240, green: 255, blue: 255)
        
        //アニメーションをつける
        pieChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
        
        
        view.addSubview(self.pieChartView)
    }
    
}
