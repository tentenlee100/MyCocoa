//
//  SettingValue.swift
//  MyCocoaChina
//
//  Created by LeeTenten on 2016/4/11.
//  Copyright © 2016年 LeeTenten. All rights reserved.
//

import Foundation

func rootApiUrl() -> String {
//    return "http://www.cocoachina.com/news"
    
    return "http://www.cocoachina.com/cms/wap.php"

    
    
}

func morePageApiUrl(page:UInt) -> String {
//    return "http://www.cocoachina.com/news/index.php?num=\(page)"
    
    return "http://www.cocoachina.com/cms/wap.php?action=more&page=\(page)"

}