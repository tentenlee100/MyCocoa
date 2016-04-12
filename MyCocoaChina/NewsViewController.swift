//
//  NewsViewController.swift
//  MyCocoaChina
//
//  Created by LeeTenten on 2016/4/11.
//  Copyright © 2016年 LeeTenten. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SafariServices
import SDWebImage
import MJRefresh
import JSQWebViewController


class NewsViewController: UIViewController,UITableViewDelegate {
    @IBOutlet var tableView : UITableView?
    
    var tableViewArray:[Dictionary<String,String>] = []
    var pageNumber : UInt = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension;
        self.tableView?.estimatedRowHeight = 100;
        
        self.setupMjRefresh()
        
        print(morePageApiUrl(1))
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        callRootApi();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
// MARK: - private method
    func setupMjRefresh() -> Void {
        let header = MJRefreshNormalHeader.init {
            self.tableViewArray = []
            self.pageNumber = 2
            self.tableView?.reloadData()
            
            self.callRootApi()
        }
        
        header.lastUpdatedTimeLabel.hidden = true;
        header.setTitle("下滑更新資料", forState: MJRefreshState.Idle)
        header.setTitle("放開開始更新", forState: MJRefreshState.Pulling)
        header.setTitle("更新資料中", forState: MJRefreshState.Refreshing)
        
        
        let footer = MJRefreshAutoNormalFooter.init {
            self.callMoreApi()
        }
        self.tableView?.mj_header = header
        self.tableView?.mj_footer = footer
        self.tableView?.mj_header.beginRefreshing()
    }
    func callRootApi() -> Void {
//old -----------------
        
//        let doc = Kanna.HTML(url: NSURL.init(string: rootApiUrl())!, encoding: NSUTF8StringEncoding)
//        var array: [Dictionary<String, String>] = []
//        for ul in doc!.body!.xpath("//ul[@class='roll-list']//li//a") {
//            array.append(["title":ul.text!,"link":ul["href"]! ])
//        }
//        self.tableViewArray = array
//        self.tableView?.reloadData()
//        print("array:\(array)")
        
//-----------------
        //old
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // 耗时的操作
            let doc = Kanna.HTML(url: NSURL.init(string: rootApiUrl())!, encoding: NSUTF8StringEncoding)
            var array: [Dictionary<String, String>] = []
            var dic : Dictionary<String, String> = [:]
            
            for ul in doc!.body!.xpath("//li[@class='articlelist clearfix']/p/a | //li[@class='articlelist clearfix']/div/div/a/img |//li[@class='articlelist clearfix']/div/div[@class='con']/p | //li[@class='articlelist clearfix']/div/div/p[@class='click']/span") {
                
                if (ul.tagName == "a" && ul.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    dic = [:]
                    dic["title"] = ul.text
                }
                if (ul["href"]?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    dic["url"] = ul["href"]
                }
                if (ul["src"]?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    dic["imageUrl"] = ul["src"]
                }
                if (ul["class"] == "article_con" && ul.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    dic["con"] = ul.text
                }
                if (ul.tagName == "span" && ul["class"] == nil &&  ul.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    dic["date"] = ul.text
                    array.append(dic)
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                // 更新界面
                self.tableViewArray = array
                self.tableView?.reloadData()
                //        print("array:\(array)")
                self.tableView?.mj_header.endRefreshing()
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
                    self.callMoreApi()
                }
            });
        });

    }
    
    func callMoreApi() -> Void {
        print(morePageApiUrl(pageNumber))
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // 耗时的操作
            let doc = Kanna.HTML(url: NSURL.init(string:morePageApiUrl(self.pageNumber))!, encoding: NSUTF8StringEncoding)
            if ((doc) == nil) {
                return
            }
            var array: [Dictionary<String, String>] = []
            var dic : Dictionary<String, String> = [:]
            print(doc)
            for ul in doc!.body!.xpath("//li[@class='articlelist clearfix']/p/a | //li[@class='articlelist clearfix']/div/div/a/img |//li[@class='articlelist clearfix']/div/div[@class='con']/p | //li[@class='articlelist clearfix']/div/div/p[@class='click']/span") {
                
                if (ul.tagName == "a" && ul.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    dic = [:]
                    dic["title"] = ul.text
                }
                if (ul["href"]?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    dic["url"] = ul["href"]
                }
                if (ul["src"]?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    dic["imageUrl"] = ul["src"]
                }
                if (ul.tagName == "p" && ul["class"] != "click" && ul.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    dic["con"] = ul.text
                }
                if (ul.tagName == "span" && ul["class"] == nil &&  ul.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    dic["date"] = ul.text
                    array.append(dic)
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                // 更新界面
                self.tableViewArray += array
                self.tableView?.reloadData()
                self.pageNumber += 1
                self.tableView?.mj_footer.endRefreshing()
            });
        });
        
        
        

        
    }
// MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        let myVc = MyWebViewController.loadFromStoryboard()
        myVc?.title = self.tableViewArray[indexPath.row]["title"]!
//        myVc?.hidesBottomBarWhenPushed = true
        myVc!.url = NSURL(string: "http://www.cocoachina.com/cms/\(self.tableViewArray[indexPath.row]["url"]!)")!
        
        self.navigationController?.pushViewController(myVc!, animated: true)
        
        
//        if #available(iOS 9.0, *) {
//            let svc = SFSafariViewController(URL: NSURL(string: "http://www.cocoachina.com/cms/\(self.tableViewArray[indexPath.row]["url"]!)")!)
//            self.presentViewController(svc, animated: true, completion: nil)
//            
//        } else {
//            // Fallback on earlier versions
//            let vc = WebViewController.init(url: NSURL(string: "http://www.cocoachina.com/cms/\(self.tableViewArray[indexPath.row]["url"]!)")!)
//            vc.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return self.tableViewArray.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsCell
        cell.titleLabel!.text = self.tableViewArray[indexPath.row]["title"]
        cell.photoImageView!.sd_setImageWithURL(NSURL(string: self.tableViewArray[indexPath.row]["imageUrl"]!),completed:{ (image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
            //            (self.tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade))!
        })
        cell.conLabel?.text = self.tableViewArray[indexPath.row]["con"]
        cell.dateLabel?.text = self.tableViewArray[indexPath.row]["date"]

        
        return cell
    }
    
}