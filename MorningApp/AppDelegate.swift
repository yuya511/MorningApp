//
//  AppDelegate.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/19.
//

import UIKit
import BackgroundTasks
import Firebase
import AVFoundation
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow? 

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // Override point for customization after application launch.
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.MorningApp.refresh", using: nil) { task in
//            // バックグラウンド処理したい内容 ※後述します
////            self.handleAppProcessing(task: task as! BGProcessingTask)
//
//        }
//        // AVAudioSessionCategory設定
//        let session = AVAudioSession.sharedInstance()
//        do {
//            // CategoryをPlaybackにする
//            try session.setCategory(.playback, mode: .default)
//        } catch  {
//            // 予期しない場合
//            fatalError("Category設定失敗")
//        }
//        // session有効化
//        do {
//            try session.setActive(true)
//        } catch {
//            // 予期しない場合
//            fatalError("Session有効化失敗")
//        }
        
        // 通知許可の取得
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { ( granted, error) in
            
        }
        center.delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.banner, .list, .sound])
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}



