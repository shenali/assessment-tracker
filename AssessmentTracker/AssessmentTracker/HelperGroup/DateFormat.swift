//
//  DateFormatter.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/15/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//

import Foundation

public class DateFormat {
    //Returns formatted date
    public func formatInputDate(_ newDate: Date) -> String {
        let formatDate : DateFormatter = DateFormatter()
        formatDate.dateFormat = "dd MMM yyyy HH:mm"
        return formatDate.string(from: newDate)
    }
}
