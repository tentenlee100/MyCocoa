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
    
    var url : NSURL = NSURL() {
        didSet{
            loadUrlHtml()
        }
    }
    var dataDic : Dictionary<String,String> = [:]
    
    @IBOutlet var webview : UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview?.scrollView.contentInset = UIEdgeInsets.init(top: -85, left: 0, bottom: 0, right: 0)
        webview?.scrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        let addCollectionBarItem  = UIBarButtonItem(image: UIImage(named: "favorite"), landscapeImagePhone: UIImage(named: "favorite"), style: .Plain, target: self, action: #selector(addCollectionAction(_:)))
        
        navigationItem.rightBarButtonItem = addCollectionBarItem
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        userActivity!.invalidate()
//        webview?.loadHTMLString(String() , baseURL: url)

    }

    class func loadFromStoryboard() -> MyWebViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MyWebViewController") as? MyWebViewController
    }
    
    func loadUrlHtml() {
        webview?.loadHTMLString(String() , baseURL: url)
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        Alamofire.request(.GET, url.absoluteString! , parameters: nil)
            .responseData { [weak self] response in
                guard let weakSelf = self else {
                    return
                }
                
                print(response.request)
                print(response.response)
                print(response.result)
                
            
                
                guard let responseData = response.data else {
                    let alertView = UIAlertController.init(title: "取不到資料", message: nil, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction.init(title: "確定", style: .Cancel, handler: { [weak self] (action) in
                        guard let weakSelf = self else {
                            return
                        }
                        weakSelf.navigationController?.popViewControllerAnimated(true)
                        })
                    alertView.addAction(cancelAction)
                    weakSelf.presentViewController(alertView, animated: true, completion: nil)
                    MBProgressHUD.hideHUDForView(weakSelf.view, animated: true)

                    return
                }
                guard var htmlString = NSString(data: responseData, encoding:NSUTF8StringEncoding) else {
                    let alertView = UIAlertController.init(title: "取不到資料", message: nil, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction.init(title: "確定", style: .Cancel, handler: { [weak self] (action) in
                        guard let weakSelf = self else {
                            return
                        }
                        weakSelf.navigationController?.popViewControllerAnimated(true)
                        })
                    alertView.addAction(cancelAction)
                    weakSelf.presentViewController(alertView, animated: true, completion: nil)
                    MBProgressHUD.hideHUDForView(weakSelf.view, animated: true)

                    return
                }
                
                let openCCService = OpenCCService.init(converterType: .S2TW)
                htmlString = openCCService.convert(htmlString as String)
                
                let startRange : NSRange = htmlString.rangeOfString("<header>")
                let endRange : NSRange = htmlString.rangeOfString("</header>")
                
                if (startRange.location != NSNotFound && endRange.location != NSNotFound){
                    htmlString = htmlString.stringByReplacingCharactersInRange(NSRange.init(location: startRange.location, length: endRange.location + endRange.length - startRange.location) , withString: "")
                }
                print("htmlString:\(htmlString)")
                
                weakSelf.webview?.loadHTMLString(String(htmlString) , baseURL: weakSelf.url)
                
                let myActivity = NSUserActivity.init(activityType:"com.ddmc.MyCocoaChina")
                myActivity.webpageURL = weakSelf.url
                weakSelf.userActivity = myActivity
        }
    }
    
    
    func addCollectionAction(sender: AnyObject?)  {
        
        
        let data = ReadNewsData.MR_findFirstByAttribute("newsId", withValue: dataDic["newsId"]!)
        
        if  (data != nil && dataDic["newsId"] == nil ){
            print("已收藏")
            return;
        }else{
            
            let collectionData = CollectionNewsData.MR_createEntity()
            collectionData?.newsId = dataDic["newsId"]!
            collectionData?.title = dataDic["title"]!
            collectionData?.con = dataDic["con"]!
            collectionData?.date = dataDic["date"]!
            collectionData?.photoImageUrl = dataDic["imageUrl"]!
            collectionData?.url = dataDic["url"]!
            
            managedObjectContext().MR_saveToPersistentStoreAndWait()
            
            
            
        }
        
        
        let alertController = UIAlertController(title: "收藏成功", message: nil, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel , handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true) { 
            
        }
        
        
    }
    //MARK - UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL != url {
            if ((request.URL?.absoluteString!.containsString("googleads.g")) != true) {

                UIApplication.sharedApplication().openURL(request.URL!)
            }
            
            return false
        }else{
            return true
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        MBProgressHUD.hideHUDForView(view, animated: true)

    }
}
