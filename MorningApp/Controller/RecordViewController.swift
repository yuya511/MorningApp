//
//  RecordViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/03.
//

import UIKit
import Charts
import Firebase
import GoogleMobileAds

class RecordViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var didLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var mistakeLabel: UILabel!
    @IBOutlet weak var targetTimeLabel: UILabel!
    
    var successCount = Double()
    var didCount = Double()
    var parsent: Double {
        get {
            return round(successCount / didCount * 100)
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
        
        guard let tabbarSize = tabBarController?.tabBar.frame.size.height else { return }
        
        var admobView = GADBannerView()
        admobView = GADBannerView(adSize: kGADAdSizeBanner)
        admobView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - admobView.frame.height - tabbarSize)
        admobView.frame.size = CGSize(width: self.view.frame.width, height: admobView.frame.height)
        admobView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        admobView.rootViewController = self
        admobView.load(GADRequest())
        self.view.addSubview(admobView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setChartData()
        timeCheck()
    }
    
    func timeCheck() {
        let storyboar = UIStoryboard(name: "Home", bundle: nil)
        let HomeViewController = storyboar.instantiateViewController(identifier: "Home") as! HomeViewController
        HomeViewController.timeMonitor()
    }
    
    
    func setNav() {
        view.backgroundColor = .rgb(red: 220, green: 230, blue: 245)
        //ナビゲーションバーの設定
        navigationController?.navigationBar.barTintColor = .rgb(red: 240, green: 240, blue: 255)
        self.navigationItem.title = "記 録"
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.rgb(red: 100, green: 150, blue: 255)
        ]
        self.targetTimeLabel.text = UserDefaults.standard.string(forKey: "SETTIME") ?? "設定する"
    }
    
    func setChartData() {
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
                let createdAt :Timestamp = data["createdAt"] as! Timestamp
                let createdAtDate :Date = createdAt.dateValue()
                
                let calendar = Calendar(identifier: .gregorian)
                let nowTime = calendar.startOfDay(for: createdAtDate)
                print("***nowTime",nowTime)
                
                //経過日数を取得
                guard let elapsedDays = Calendar.current.dateComponents([.day], from: nowTime, to: Date()).day else { return }
                let didcount = elapsedDays
                
                self.didCount = Double(didcount)
                //経過日数のデータ
                self.didLabel.text = "\(didcount) 日"
                //成功した日にちの数
                let morningCount:Int = data["morningCount"] as? Int ?? 0
                self.successLabel.text = "\(morningCount) 日"
                self.successCount = Double(morningCount)
                self.mistakeLabel.text = "\(self.miss) 日"
                print("***self.parent",String(self.parsent))
                if self.parsent.isNaN {
                    self.percentLabel.text = "データなし"
                    self.percentLabel.font = self.percentLabel.font.withSize(15)
                } else {
                    self.percentLabel.text = "\(self.parsent)%"
                }
                self.setChart()

               
                
//                let chatRef = Firestore.firestore().collection(Const.ChatRooms)
//                let query = chatRef.whereField("uid", isEqualTo: uid).whereField("stamp", isEqualTo: true)
//                query.getDocuments { (snaps, err) in
//                    if let err = err {
//                        print(err)
//                        return
//                    }
//                    guard let snaps = snaps else {return}
//                    let successcount = snaps.documents.count
//                    self.successCount = Double(successcount)
//                    //成功日数のデータ
//                    self.successLabel.text = "\(successcount) 日"
//                    //失敗日数のデータ
//                    self.mistakeLabel.text = "\(String(self.miss)) 日"
//                    print("didCount",self.didCount)
//                    print("miss",self.miss)
//                    //グラフの中心のデータ
//                    self.percentLabel.text = "\(String(self.parsent))%"
//                    self.setChart()
//                }
            }
        }
    }
    
    func setChart() {
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
        pieChartView.backgroundColor = .rgb(red: 220, green: 230, blue: 245)
        
        //アニメーションをつける
        pieChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
        
        view.addSubview(self.pieChartView)
    }
    
}
