//
//  MyWebViewController.swift
//  MyCocoaChina
//
//  Created by LeeTenten on 2016/4/12.
//  Copyright © 2016年 LeeTenten. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire

class MyWebViewController: UIViewController {
    
    var url : NSURL = NSURL()
    @IBOutlet var webview : UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview?.scrollView.contentInset = UIEdgeInsets.init(top: -85, left: 0, bottom: 44, right: 0)
        self.webview?.scrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 44, right: 0)
        

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Alamofire.request(.GET, self.url.absoluteString , parameters: nil)
            .responseData { response in
                print(response.request)
                print(response.response)
                print(response.result)
                
                var htmlString = NSString(data: response.data!, encoding:NSUTF8StringEncoding)
                
                let startRange : NSRange = (htmlString?.rangeOfString("<header>"))!
                let endRange : NSRange = (htmlString?.rangeOfString("</header>"))!
                
                if (startRange.location != NSNotFound && endRange.location != NSNotFound){
                    htmlString = htmlString?.stringByReplacingCharactersInRange(NSRange.init(location: startRange.location, length: endRange.location + endRange.length - startRange.location) , withString: "")
                }
                print("htmlString:\(htmlString)")
                
                self.webview?.loadHTMLString(String.init(htmlString!) , baseURL: self.url)
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
                let myActivity = NSUserActivity.init(activityType:"com.ddmc.MyCocoaChina")
                myActivity.webpageURL = self.url
                self.userActivity = myActivity

        }

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.userActivity!.invalidate()
    }
    
    class func loadFromStoryboard() -> MyWebViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MyWebViewController") as? MyWebViewController
    }
    
    
}