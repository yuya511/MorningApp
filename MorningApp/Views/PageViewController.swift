//
//  PageViewController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/04/25.
//

import UIKit

class PageViewController: UIPageViewController {
    
    //1.PageViewで表示するViewControllerを格納する配列を定義
    private var controllers: [UIViewController] = []
    private var backBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        initPageViewController()
    }
    
    private func initPageViewController() {
        //2.PageViewControllerで表示するViewControllerをインスタンス化する
        let firestVC = storyboard!.instantiateViewController(withIdentifier: "DescriptionViewController") as! DescriptionViewController
        let secondVC = storyboard!.instantiateViewController(withIdentifier: "SecondView") as! SecondViewController
        let ThirdVC = storyboard!.instantiateViewController(withIdentifier: "ThirdView") as! ThirdViewController
        let FourthVC = storyboard!.instantiateViewController(withIdentifier: "FourthView") as! FourthViewController

        //3.インスタンス化したViewControllerを配列に保存する
        self.controllers = [ firestVC, secondVC, ThirdVC, FourthVC ]
        //3.最初に表示するViewControllerを指定する
        setViewControllers([self.controllers[0]], direction: .forward, animated: true, completion: nil)
        //4.PageViewControllerのDataSourceを関連付ける
        self.dataSource = self
        
        self.navigationItem.title = "アプリの説明"
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.rgb(red: 100, green: 150, blue: 255)
        ]
        backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(leftBarButtonAction))
        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    @objc func leftBarButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
 }


// MARK: - UIPageViewController DataSource
extension PageViewController: UIPageViewControllerDataSource {
    //ページの数
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.controllers.count
    }
    //左にスワイプ → after
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let index = self.controllers.firstIndex(of: viewController),
           index < self.controllers.count - 1 {
            return self.controllers[index + 1]
        } else {
            return nil
        }
    }
    //右にスワイプ → before
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if let index = self.controllers.firstIndex(of: viewController),
           index > 0 {
            return self.controllers[index - 1]
        } else {
            return nil
        }
    }
}
