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


class NewsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var tableView : UITableView?
    let myWebviewController : MyWebViewController = MyWebViewController.loadFromStoryboard()!
    
    var tableViewArray:[Dictionary<String,String>] = []
    var pageNumber : UInt = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 100
        tableView?.tableFooterView = UIView()
        setupMjRefresh()
        
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
        let header = MJRefreshNormalHeader.init(refreshingBlock: {[unowned self] in
            self.tableViewArray = []
            self.pageNumber = 2
            self.tableView?.reloadData()
            
            self.callRootApi()
        })

        
        
        header.lastUpdatedTimeLabel.hidden = true;
        header.setTitle("下滑更新資料", forState: MJRefreshState.Idle)
        header.setTitle("放開開始更新", forState: MJRefreshState.Pulling)
        header.setTitle("更新資料中", forState: MJRefreshState.Refreshing)
        
        
        let footer = MJRefreshAutoNormalFooter.init { [unowned self] in
            self.callMoreApi()
        }
        footer.setTitle("正在更新中", forState: .Refreshing)
        footer.setTitle("已無資料", forState: .NoMoreData)
        footer.setTitle("上滑繼續載入", forState: .Idle)

        tableView?.mj_header = header
        tableView?.mj_footer = footer
        tableView?.mj_footer.endRefreshingWithNoMoreData()
        tableView?.mj_header.beginRefreshing()
    }
    func callRootApi() -> Void {

        self.tableView?.mj_footer.endRefreshingWithNoMoreData()

        Alamofire.request(.GET, rootApiUrl() , parameters: nil)
            .responseData { [unowned self] response in
                print(response.request)
                print(response.response)
                print(response.result)
                
                var htmlString = NSString(data: response.data!, encoding:NSUTF8StringEncoding)
                
                let openCCService = OpenCCService.init(converterType: .S2TW)
                
                htmlString = openCCService.convert(htmlString! as String)
                
                let doc = Kanna.HTML(html: htmlString as! String , encoding: NSUTF8StringEncoding)
                //                let doc = Kanna.HTML(url: NSURL.init(string: rootApiUrl())!, encoding: NSUTF8StringEncoding)
                var array: [Dictionary<String, String>] = []
                var dic : Dictionary<String, String> = [:]
                
                for ul in doc!.body!.xpath("//li[@class='articlelist clearfix']/p/a | //li[@class='articlelist clearfix']/div/div/a/img |//li[@class='articlelist clearfix']/div/div[@class='con']/p | //li[@class='articlelist clearfix']/div/div/p[@class='click']/span") {
                    
                    if (ul.tagName == "a" && ul.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                        dic = [:]
                        dic["title"] = ul.text
                    }
                    if (ul["href"]?.characters.count > 0) {
                        let url = ul["href"] ?? ""
                        let idRange = url.rangeOfString("id")
                        dic["newsId"] = url.substringWithRange(idRange!.startIndex.advancedBy(3) ..< url.endIndex)

                        dic["url"] = url
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

                self.tableViewArray = array
                self.tableView?.reloadData()
                //        print("array:\(array)")
                self.tableView?.mj_header.endRefreshing()

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
                    [unowned self] in
                    self.tableView?.mj_footer.resetNoMoreData()
                    self.tableView?.mj_footer.beginRefreshing()
                }
                
        }

    }
    
    func callMoreApi() -> Void {
        
        Alamofire.request(.GET, morePageApiUrl(self.pageNumber) , parameters: nil)
            .responseData { [unowned self] response in
                print(response.request)
                print(response.response)
                print(response.result)
                
                if response.result.isFailure
                {
                    return
                }
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    [unowned self] in
                    var htmlString = NSString(data: response.data!, encoding:NSUTF8StringEncoding)
                    
                    let openCCService = OpenCCService.init(converterType: .S2TW)
                    htmlString = openCCService.convert(htmlString! as String)
                    
                    let doc = Kanna.HTML(html: htmlString as! String , encoding: NSUTF8StringEncoding)
                    
                    if ((doc) == nil) {
                        return
                    }
                    
                    var array: [Dictionary<String, String>] = []
                    var dic : Dictionary<String, String> = [:]
                    
                    for ul in doc!.body!.xpath("//li[@class='articlelist clearfix']/p/a | //li[@class='articlelist clearfix']/div/div/a/img |//li[@class='articlelist clearfix']/div/div[@class='con']/p | //li[@class='articlelist clearfix']/div/div/p[@class='click']/span") {
                        
                        if (ul.tagName == "a" && ul.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                            dic = [:]
                            dic["title"] = ul.text
                        }
                        if (ul["href"]?.characters.count > 0) {
                            let url = ul["href"] ?? ""
                            let idRange = url.rangeOfString("id")
                            dic["newsId"] = url.substringWithRange(idRange!.startIndex.advancedBy(3) ..< url.endIndex)
                            dic["url"] = url
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
                        [unowned self] in
                        self.tableViewArray += array
                        self.tableView?.reloadData()
                        self.pageNumber += 1
                        self.tableView?.mj_footer.endRefreshing()
                    })
                })
                

                
                
        }
        

        
    }
// MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        let data = ReadNewsData.MR_findFirstByAttribute("newsId", withValue: self.tableViewArray[indexPath.row]["newsId"]!)
        
        if  (data == nil && self.tableViewArray[indexPath.row]["newsId"] != nil ){
            let newsId = ReadNewsData.MR_createEntity()
            newsId?.newsId = self.tableViewArray[indexPath.row]["newsId"]!
            managedObjectContext().MR_saveToPersistentStoreAndWait()
        }
        
        if ((self.tableView?.mj_footer) != nil){
            let  cell = tableView.cellForRowAtIndexPath(indexPath) as! NewsCell
            cell.updateLabelColor(true)
        }

        
        self.myWebviewController.title = self.tableViewArray[indexPath.row]["title"]!
        self.myWebviewController.url = NSURL(string: "http://www.cocoachina.com/cms/\(self.tableViewArray[indexPath.row]["url"]!)")!
        self.myWebviewController.dataDic = self.tableViewArray[indexPath.row]
        self.navigationController?.pushViewController(self.myWebviewController, animated: true)

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return self.tableViewArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsCell
        cell.titleLabel!.text = self.tableViewArray[indexPath.row]["title"]
        
        if let imageUrl = self.tableViewArray[indexPath.row]["imageUrl"] {
            cell.photoImageView!.sd_setImageWithURL(NSURL(string: imageUrl),completed:{ (image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
            })
        }else{
            cell.photoImageView!.image = nil
        }
        cell.conLabel?.text = self.tableViewArray[indexPath.row]["con"]
        cell.dateLabel?.text = self.tableViewArray[indexPath.row]["date"]

        let data = ReadNewsData.MR_findFirstByAttribute("newsId", withValue: self.tableViewArray[indexPath.row]["newsId"]!)

        if  (data != nil && self.tableViewArray[indexPath.row]["newsId"] != nil ){
            cell.updateLabelColor(true)
        }else{
            cell.updateLabelColor(false)

        }
        
        
        return cell
    }
    
}