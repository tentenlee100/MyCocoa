//
//  NewsCell.swift
//  MyCocoaChina
//
//  Created by LeeTenten on 2016/4/11.
//  Copyright © 2016年 LeeTenten. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var conLabel: UILabel?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var photoImageView: UIImageView?
    
    func updateLabelColor(_ on:Bool) -> Void {
        let color = on ? UIColor.lightGray : UIColor.black
        
        titleLabel?.textColor = color
        conLabel?.textColor = color
        dateLabel?.textColor = color
    }
    
}

