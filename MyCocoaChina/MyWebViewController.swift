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

class MyWebViewController: UIViewController ,UIWebViewDelegate{
    
    var url : NSURL = NSURL()
    var dataDic : Dictionary<String,String> = [:]
    
    @IBOutlet var webview : UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview?.scrollView.contentInset = UIEdgeInsets.init(top: -85, left: 0, bottom: 0, right: 0)
        self.webview?.scrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        let addCollectionBarItem  = UIBarButtonItem(image: UIImage(named: "favorite"), landscapeImagePhone: UIImage(named: "favorite"), style: .Plain, target: self, action: #selector(MyWebViewController.addCollectionAction(_:)))
        
        self.navigationItem.rightBarButtonItem = addCollectionBarItem
        
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
                let openCCService = OpenCCService.init(converterType: .S2TW)
                htmlString = openCCService.convert(htmlString! as String)
                
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
    
    func addCollectionAction(sender: AnyObject)  {
        
        
        
        let data = ReadNewsData.MR_findFirstByAttribute("newsId", withValue: self.dataDic["newsId"]!)
        
        if  (data != nil && self.dataDic["newsId"] == nil ){
            print("已收藏")
            return;
        }else{
            
            let collectionData = CollectionNewsData.MR_createEntity()
            collectionData?.newsId = self.dataDic["newsId"]!
            collectionData?.title = self.dataDic["title"]!
            collectionData?.con = self.dataDic["con"]!
            collectionData?.date = self.dataDic["date"]!
            collectionData?.photoImageUrl = self.dataDic["imageUrl"]!
            collectionData?.url = self.dataDic["url"]!
            
            managedObjectContext().MR_saveToPersistentStoreAndWait()
            
            
            
        }
        
        
        
        
        let alertController = UIAlertController(title: "收藏成功", message: nil, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel , handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) { 
            
        }
        
        
    }
    //MARK - UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL != self.url {
            return false
        }else{
            return true
        }
    }
}