//
//  AppDelegate.swift
//  ESCHints
//
//  Created by Matt Ao on 4/19/18.
//  Copyright © 2018 Matt Ao. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
            if authorized {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        })
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let publicDB = CKContainer.init(identifier: "iCloud.esc.GameMaster").publicCloudDatabase
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "👌🏻👌🏻"
        notificationInfo.shouldBadge = false
        notificationInfo.soundName = "default"
        notificationInfo.title = "A Hint Just For You"
        if let currentRoom = UserDefaults().value(forKey: "room") as? String {
            let predicate = NSPredicate(format: "room = %@", currentRoom)
            let subscription = CKQuerySubscription(recordType: "Hint", predicate: predicate, options: .firesOnRecordCreation)
            subscription.notificationInfo = notificationInfo
            
            publicDB.save(subscription, completionHandler: { subscription, error in
                if error == nil {
                    print("success")
                } else {
                    print("fail")
                }
            })
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
        
        if UIApplication.shared.applicationState == .active {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.reloadData()
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
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

    func reloadData() {
        if let mainVC = self.window?.rootViewController as? ViewController {
            mainVC.fetchAllHints()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        reloadData()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

