//
//  AppDelegate.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/17.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
//        let config = Realm.Configuration(
//                    schemaVersion: 1,
//                    migrationBlock: { migration, oldSchemaVersion in
//                        if (oldSchemaVersion < 1) {}
//                        }
//                )
//        Realm.Configuration.defaultConfiguration = config
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")

                if launchedBefore != true {

                    print("first launch.")
                    //起動を判定するlaunchedBeforeという論理型のKeyをUserDefaultsに用意
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
                    
                    let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                    let onboardingViewController = storyboard.instantiateViewController(withIdentifier: "onBoarding") as! OnboardingViewController
                    let naviVC = UINavigationController(rootViewController: onboardingViewController)
                    self.window?.rootViewController = naviVC

                } else {

                    print("Not first launch.")

                    //動作確認のために1回実行ごとに値をfalseに設定し直す
//                    UserDefaults.standard.set(false, forKey: "launchedBefore")
                }

        return true
    }

    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }

}
