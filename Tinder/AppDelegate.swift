//
//  AppDelegate.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/1/19.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = HomeViewController()
//        window?.rootViewController = RegistrationController()
//        let naviVC = UINavigationController.init(rootViewController: SettingController())
//        window?.rootViewController = naviVC
        //若不要有翻頁效果，就用scroll
//        window?.rootViewController = SwipingPhotosController.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        return true
    }
}
