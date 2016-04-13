//
//  SettingValue.swift
//  MyCocoaChina
//
//  Created by LeeTenten on 2016/4/11.
//  Copyright © 2016年 LeeTenten. All rights reserved.
//

import Foundation
import MagicalRecord

let kRecipesStoreName = "MyCocoaDB" as NSString


func rootApiUrl() -> String {
//    return "http://www.cocoachina.com/news"
    
    return "http://www.cocoachina.com/cms/wap.php"

    
    
}

func morePageApiUrl(page:UInt) -> String {
//    return "http://www.cocoachina.com/news/index.php?num=\(page)"
    
    return "http://www.cocoachina.com/cms/wap.php?action=more&page=\(page)"

}

func managedObjectContext() -> NSManagedObjectContext {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    return appDelegate.managedObjectContext!    
}