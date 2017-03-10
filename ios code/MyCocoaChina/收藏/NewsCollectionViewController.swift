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
        
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.getDbData()

            //Validate user input
            
            
            // Go back to the main thread to update the UI
            DispatchQueue.main.async {  [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.tableView?.reloadData()

            }
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tableViewArray.count != CollectionNewsData.mr_findAll()?.count {
            getDbData()
        }
    }
    
    override func setupMjRefresh() {
        let header = MJRefreshNormalHeader.init { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.getDbData()
            weakSelf.tableView?.reloadData()
        }
        
        header?.lastUpdatedTimeLabel.isHidden = true;
        header?.setTitle("下滑更新資料", for: MJRefreshState.idle)
        header?.setTitle("放開開始更新", for: MJRefreshState.pulling)
        header?.setTitle("更新資料中", for: MJRefreshState.refreshing)
    
        tableView?.mj_header = header
//        tableView?.mj_header.beginRefreshing()
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
        
        tableViewArray = collectArray
        tableView?.mj_header.endRefreshing()

    }
    func deleteCollectionData(_ index:IndexPath) -> Void {
        
        for obj in CollectionNewsData.mr_find(byAttribute: "newsId", withValue: tableViewArray[index.row]["newsId"]!)!{
            let newobj  = obj as! CollectionNewsData
            newobj.mr_deleteEntity(in: managedObjectContext())
        }
        managedObjectContext().mr_saveToPersistentStoreAndWait()
        
        getDbData()
        tableView?.reloadData()
        
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
            deleteCollectionData(indexPath)
        }
    }
}
