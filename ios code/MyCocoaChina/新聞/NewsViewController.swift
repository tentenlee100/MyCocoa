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
import WebImage
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        callRootApi();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - private method
    func setupMjRefresh() -> Void {
        let header = MJRefreshNormalHeader.init(refreshingBlock: {[weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tableViewArray = []
            weakSelf.pageNumber = 2
            weakSelf.tableView?.reloadData()
            
            weakSelf.callRootApi()
        })
        
        
        
        header?.lastUpdatedTimeLabel.isHidden = true;
        header?.setTitle("下滑更新資料", for: MJRefreshState.idle)
        header?.setTitle("放開開始更新", for: MJRefreshState.pulling)
        header?.setTitle("更新資料中", for: MJRefreshState.refreshing)
        
        
        let footer = MJRefreshAutoNormalFooter.init { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.callMoreApi()
        }
        footer?.setTitle("正在更新中", for: .refreshing)
        footer?.setTitle("已無資料", for: .noMoreData)
        footer?.setTitle("上滑繼續載入", for: .idle)
        
        tableView?.mj_header = header
        tableView?.mj_footer = footer
        tableView?.mj_footer.endRefreshingWithNoMoreData()
        tableView?.mj_header.beginRefreshing()
    }
    func callRootApi() -> Void {
        
        tableView?.mj_footer.endRefreshingWithNoMoreData()
        
        
        Alamofire.request(rootApiUrl()).responseData {[weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            print(response.request ?? "request is null")
            print(response.response ?? "response is null")
            print(response.result)
            
            var htmlString = NSString(data: response.data!, encoding:String.Encoding.utf8.rawValue)
            
            let openCCService = OpenCCService.init(converterType: .S2TW)
            
            htmlString = openCCService?.convert(htmlString! as String) as NSString?
            
            let doc = Kanna.HTML(html: htmlString as! String , encoding: String.Encoding.utf8)
            //                let doc = Kanna.HTML(url: NSURL.init(string: rootApiUrl())!, encoding: NSUTF8StringEncoding)
            var array: [Dictionary<String, String>] = []
            var dic : Dictionary<String, String> = [:]
            
            for ul in doc!.body!.xpath("//li[@class='articlelist clearfix']/p/a | //li[@class='articlelist clearfix']/div/div/a/img |//li[@class='articlelist clearfix']/div/div[@class='con']/p | //li[@class='articlelist clearfix']/div/div/p[@class='click']/span") {
                
                if ul.tagName! == "a" , let title = ul.text , title.characters.count > 0  {
                    dic = [:]
                    
                    dic["title"] = title
                }
                if let url = ul["href"] , url.characters.count > 0 {
                    
                    if let startIndex = url.range(of: "id")?.lowerBound {
                        dic["newsId"] = url.substring(from: url.index(startIndex, offsetBy: 3))
                    }
                    
                    
                    //                    dic["newsId"] = url.substringWithRange(idRange!.startIndex.advancedBy(3) ..< url.endIndex)
                    
                    dic["url"] = url
                    continue
                }
                if let src = ul["src"] , src.characters.count > 0 {
                    dic["imageUrl"] = ul["src"]
                    continue
                }
                if let className = ul["class"] , className == "article_con" ,  let con = ul.text ,  con.characters.count > 0 {
                    dic["con"] = con
                    continue
                }
                
                if let tagName = ul.tagName , tagName == "span" ,  ul["class"] == nil ,  let date = ul.text , date.characters.count > 0 {
                    dic["date"] = date
                    array.append(dic)
                    continue
                }
                
            }
            
            weakSelf.tableViewArray = array
            weakSelf.tableView?.reloadData()
            print("array:\(array)")
            weakSelf.tableView?.mj_header.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                // your function here
                guard let weakSelf = self else {
                    return
                }
                weakSelf.tableView?.mj_footer.resetNoMoreData()
                weakSelf.tableView?.mj_footer.beginRefreshing()
            }
            
            
        }
        
    }
    
    func callMoreApi() -> Void {
        
        Alamofire.request(morePageApiUrl(pageNumber)).responseData {(response) in
            
            
            print(response.request ?? "request is null")
            print(response.response ?? "response is null")
            print(response.result)
            
            if response.result.isFailure
            {
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                
                //Validate user input
                var htmlString = NSString(data: response.data!, encoding:String.Encoding.utf8.rawValue)
                
                let openCCService = OpenCCService.init(converterType: .S2TW)
                htmlString = openCCService?.convert(htmlString! as String) as NSString?
                
                let doc = Kanna.HTML(html: htmlString as! String , encoding: String.Encoding.utf8)
                
                if ((doc) == nil) {
                    return
                }
                
                var array: [Dictionary<String, String>] = []
                var dic : Dictionary<String, String> = [:]
                
                for ul in doc!.body!.xpath("//li[@class='articlelist clearfix']/p/a | //li[@class='articlelist clearfix']/div/div/a/img |//li[@class='articlelist clearfix']/div[@class='article_border']/div[@class='con']/p | //li[@class='articlelist clearfix']/div/div/p[@class='click']/span") {
                    
                    
                    if ul.tagName! == "a" , let title = ul.text , title.characters.count > 0  {
                        dic = [:]
                        
                        dic["title"] = title
                    }
                    if let url = ul["href"] , url.characters.count > 0 {
                        
                        if let startIndex = url.range(of: "id")?.lowerBound {
                            dic["newsId"] = url.substring(from: url.index(startIndex, offsetBy: 3))
                        }
                        
                        
                        //                    dic["newsId"] = url.substringWithRange(idRange!.startIndex.advancedBy(3) ..< url.endIndex)
                        
                        dic["url"] = url
                        continue
                    }
                    if let src = ul["src"] , src.characters.count > 0 {
                        dic["imageUrl"] = ul["src"]
                        continue
                    }
                    if let tagName = ul.tagName  , tagName == "p" , ul["class"] == nil , let con = ul.text ,  con.characters.count > 0 {
                        dic["con"] = con
                        continue
                    }
                    
                    if let tagName = ul.tagName , tagName == "span" ,  ul["class"] == nil ,  let date = ul.text , date.characters.count > 0 {
                        dic["date"] = date
                        array.append(dic)
                        continue
                    }
                    
                }
                
                // Go back to the main thread to update the UI
                DispatchQueue.main.async { [weak self] in
                    guard let weakSelf = self else {
                        return
                    }
                    weakSelf.tableViewArray += array
                    weakSelf.tableView?.reloadData()
                    weakSelf.pageNumber += 1
                    weakSelf.tableView?.mj_footer.endRefreshing()
                    
                }
            }
            
            
            
            
            
        }
        
        
        
    }
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
        
        let data = ReadNewsData.mr_findFirst(byAttribute: "newsId", withValue: tableViewArray[indexPath.row]["newsId"]!)
        
        if  (data == nil && tableViewArray[indexPath.row]["newsId"] != nil ){
            let newsId = ReadNewsData.mr_createEntity()
            newsId?.newsId = tableViewArray[indexPath.row]["newsId"]!
            managedObjectContext().mr_saveToPersistentStoreAndWait()
        }
        
        if ((tableView.mj_footer) != nil){
            let  cell = tableView.cellForRow(at: indexPath) as! NewsCell
            cell.updateLabelColor(true)
        }
        
        
        myWebviewController.title = tableViewArray[indexPath.row]["title"]!
        myWebviewController.url = URL(string: "http://www.cocoachina.com/cms/\(tableViewArray[indexPath.row]["url"]!)")!
        myWebviewController.dataDic = tableViewArray[indexPath.row]
        navigationController?.pushViewController(myWebviewController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return tableViewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsCell
        cell.titleLabel!.text = tableViewArray[indexPath.row]["title"]
        
        if let imageUrl = tableViewArray[indexPath.row]["imageUrl"] {
            cell.photoImageView?.sd_setImage(with: URL(string: imageUrl), completed: { (image, error, cacheType, imageUrl) in
                
            })
        }else{
            cell.photoImageView!.image = nil
        }
        cell.conLabel?.text = tableViewArray[indexPath.row]["con"]
        cell.dateLabel?.text = tableViewArray[indexPath.row]["date"]
        
        let data = ReadNewsData.mr_findFirst(byAttribute: "newsId", withValue: tableViewArray[indexPath.row]["newsId"]!)
        
        if  (data != nil && tableViewArray[indexPath.row]["newsId"] != nil ){
            cell.updateLabelColor(true)
        }else{
            cell.updateLabelColor(false)
            
        }
        
        
        return cell
    }
    
}
