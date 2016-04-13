//
//  NewsCollectionViewController.swift
//  MyCocoaChina
//
//  Created by LeeTenten on 2016/4/13.
//  Copyright © 2016年 LeeTenten. All rights reserved.
//

import UIKit
import MJRefresh

class NewsCollectionViewController: NewsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // 耗时的操作
            self.getDbData()
            dispatch_async(dispatch_get_main_queue(), {
                // 更新界面
                self.tableView?.reloadData()
            });
        });
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.tableViewArray.count != CollectionNewsData.MR_findAll()?.count {
            self.getDbData()
        }
    }
    
    override func setupMjRefresh() {
        let header = MJRefreshNormalHeader.init {
            self.getDbData()
            self.tableView?.reloadData()
        }
        
        header.lastUpdatedTimeLabel.hidden = true;
        header.setTitle("下滑更新資料", forState: MJRefreshState.Idle)
        header.setTitle("放開開始更新", forState: MJRefreshState.Pulling)
        header.setTitle("更新資料中", forState: MJRefreshState.Refreshing)
    
        self.tableView?.mj_header = header
//        self.tableView?.mj_header.beginRefreshing()
    }
    
    func getDbData() -> Void {
        var collectArray :[Dictionary<String,String>] = []
        
        var allDataArray = CollectionNewsData.MR_findAll() ?? []
        allDataArray = allDataArray.reverse()
        
        
        for obj  in allDataArray {
            let newobj  = obj as! CollectionNewsData
            var dic : Dictionary<String,String> = [:]
            dic["newsId"] = newobj.newsId
            dic["title"] = newobj.title
            dic["con"] = newobj.con
            dic["date"] = newobj.date
            dic["imageUrl"] = newobj.photoImageUrl
            dic["url"] = newobj.url
            
            collectArray.append(dic)
            
        }
        
        self.tableViewArray = collectArray
        self.tableView?.mj_header.endRefreshing()

    }
    func deleteCollectionData(index:NSIndexPath) -> Void {
        
        for obj in CollectionNewsData.MR_findByAttribute("newsId", withValue: self.tableViewArray[index.row]["newsId"]!)!{
            let newobj  = obj as! CollectionNewsData
            newobj.MR_deleteEntityInContext(managedObjectContext())
        }
        managedObjectContext().MR_saveToPersistentStoreAndWait()
        
        self.getDbData()
        self.tableView?.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! NewsCell
        cell.updateLabelColor(false)
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.deleteCollectionData(indexPath)
        }
    }
}