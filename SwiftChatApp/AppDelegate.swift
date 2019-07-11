//
//  AppDelegate.swift
//  SwiftChatApp
//
//  Created by yuma.saito on 2019/07/17.
//  Copyright © 2019 yuma.saito. All rights reserved.
//

import UIKit
import NCMB


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    /***** 【NCMB】APIキー *****/
    //let applicationkey = "YOUR_NCMB_APPLICATION_KEY"
    //let clientkey = "YOUR_NCMB_CLIENTKEY"
    
    let applicationkey = "88b626747d953fb6d3aefe54e88073c4237e18bd4bc493da5de771263577726b"
    let clientkey = "104ac9817ee72e672a396105457db8e4d2892463b8e544bfa2fdc1e16aa42801"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        /***** 【NCMB】SDKの初期化 *****/
        NCMB.initialize(
            applicationKey: applicationkey,
            clientKey: clientkey)
        /***** 【NCMB】SDKの初期化 *****/
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {

        /***** 【NCMB】会員管理 ログアウト *****/
        NCMBUser.logOut()
        /***** 【NCMB】会員管理 ログアウト *****/
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

