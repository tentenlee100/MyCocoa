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
        tableView?.tableFooterView = UIView()
        title = "收藏"
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // 耗时的操作
            self.getDbData()
            DispatchQueue.main.async(execute: {
                // 更新界面
                self.tableView?.reloadData()
            });
        });
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.tableViewArray.count != CollectionNewsData.mr_findAll()?.count {
            self.getDbData()
        }
    }
    
    override func setupMjRefresh() {
        let header = MJRefreshNormalHeader.init {
            self.getDbData()
            self.tableView?.reloadData()
        }
        
        header?.lastUpdatedTimeLabel.isHidden = true;
        header?.setTitle("下滑更新資料", for: MJRefreshState.idle)
        header?.setTitle("放開開始更新", for: MJRefreshState.pulling)
        header?.setTitle("更新資料中", for: MJRefreshState.refreshing)
    
        self.tableView?.mj_header = header
//        self.tableView?.mj_header.beginRefreshing()
    }
    
    func getDbData() -> Void {
        var collectArray :[Dictionary<String,String>] = []
        
        
        for obj  in CollectionNewsData.mr_findAll()!.reversed() {
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
    func deleteCollectionData(_ index:IndexPath) -> Void {
        
        for obj in CollectionNewsData.mr_find(byAttribute: "newsId", withValue: self.tableViewArray[index.row]["newsId"]!)!{
            let newobj  = obj as! CollectionNewsData
            newobj.mr_deleteEntity(in: managedObjectContext())
        }
        managedObjectContext().mr_saveToPersistentStoreAndWait()
        
        self.getDbData()
        self.tableView?.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! NewsCell
        cell.updateLabelColor(false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteCollectionData(indexPath)
        }
    }
}
