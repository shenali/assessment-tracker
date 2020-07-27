//
//  UITableView.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/16/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func hasRowAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    func setEmptyMessage(_ message: String,_ messageColour: UIColor) {
        let messageL = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageL.text = message
        messageL.textColor = messageColour
        messageL.numberOfLines = 0;
        messageL.textAlignment = .center;
        messageL.font = UIFont(name: "System", size: 16)
        messageL.sizeToFit()
        
        self.backgroundView = messageL;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
