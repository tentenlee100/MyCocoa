//
//  CollectionNewsData+CoreDataProperties.swift
//  MyCocoaChina
//
//  Created by LeeTenten on 2016/4/13.
//  Copyright © 2016年 LeeTenten. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CollectionNewsData {

    @NSManaged var newsId: String?
    @NSManaged var title: String?
    @NSManaged var con: String?
    @NSManaged var date: String?
    @NSManaged var photoImageUrl: String?
    @NSManaged var url: String?

}
