//
//  AppDelegate.swift
//  MyCocoaChina
//
//  Created by LeeTenten on 2016/4/11.
//  Copyright © 2016年 LeeTenten. All rights reserved.
//

import UIKit
import MagicalRecord

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var managedObjectContext : NSManagedObjectContext?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupCoreData()
    
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setupCoreData() -> Void {
        
        
        let fileManager = FileManager.default
        let storeURL = NSPersistentStore.mr_url(forStoreName: kRecipesStoreName as String)
        
        if fileManager.fileExists(atPath: (storeURL?.path)!) {
            let defaultStorePath = Bundle.main.path(forResource: kRecipesStoreName.deletingPathExtension, ofType: kRecipesStoreName.pathExtension)
            if ((defaultStorePath) != nil) {
                do{
                    try fileManager.copyItem(atPath: defaultStorePath!, toPath: (storeURL?.path)!)
                } catch _ as NSError{
                    print("Failed to install default recipe store")
                }
            }
        }
        
        MagicalRecord.setupCoreDataStack(withStoreNamed: kRecipesStoreName as String)
        managedObjectContext = NSManagedObjectContext.mr_default();
            
    }
}

