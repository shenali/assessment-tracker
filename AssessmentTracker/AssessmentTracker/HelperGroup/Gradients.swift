//
//  Gradients.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/15/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//

import Foundation
import UIKit

public class Gradients {
    public func colorForProgress(_ percentage: Int, negative: Bool = false) -> [UIColor] {
        let _default: [UIColor] = [UIColor.red, UIColor.orange]
        
        let redColor: [UIColor] = [UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 69/255, blue: 69/255, alpha: 1.00)]
        
        let greenColor: [UIColor] = [UIColor(red: 50/255, green: 200/255, blue: 0/255, alpha: 1.00), UIColor(red: 151/255, green: 255/255, blue: 49/255, alpha: 1.00)]
        
        let orangeColor: [UIColor] = [UIColor(red: 255/255, green: 126/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 155/255, blue: 57/255, alpha: 1.00)]

        //Returns colour gradients for progress
        if !negative {
            if percentage <= 33 {
                return redColor
            } else if percentage <= 66 {
                return orangeColor
            } else if percentage <= 100 {
                return greenColor
            }
            return _default
        }
        else {  //returns gradient for days left
            if percentage <= 33 {
                return greenColor
            } else if percentage <= 66 {
                return orangeColor
            } else if percentage <= 100 {
                return redColor
            }
            return _default
        }
        return _default
    }
}
