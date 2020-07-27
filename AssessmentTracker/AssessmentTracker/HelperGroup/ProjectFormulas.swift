//
//  ProjectFormulas.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/15/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//

import Foundation

public class ProjectFormulas {
    let currentDate = Date()
        
    //Calculating the progress of the assessment
    public func calculateAssesmentProgress(_ tasks: [Task]) -> Int {
          var totalAssessmentProgress: Float = 0
          var assessmentProgress: Int = 0
          
          if tasks.count > 0 {
              for task in tasks {
                  totalAssessmentProgress += task.progress
              }
              assessmentProgress = Int(totalAssessmentProgress) / tasks.count
          }
          
          return assessmentProgress
      }
    
    //Calculating remaining days
    public func calculateDaysLeft(_ beginDate: Date, endDate: Date) -> Int {
        let latestCalendar = Calendar.current
        guard let beginDate = latestCalendar.ordinality(of: .day, in: .era, for: beginDate) else {
            return 0
        }
        guard let endDate = latestCalendar.ordinality(of: .day, in: .era, for: endDate) else {
            return 0
        }
        
        let remainingDays = endDate - beginDate
        
        return remainingDays
    }
    
    //Calculate the percentage of time left
    public func calculateTimePercentageLeft(_ beginDate: Date, endDate: Date) -> Int {
        var timePercentage = 100
        let timeSpent = calculateTimeDifferenceInSecs(beginDate, endDate: endDate)
        let timeLeft = calculateTimeDifferenceInSecs(currentDate, endDate: endDate)
        
        //Perform the calculation if more than 0 time is spent
        if timeSpent > 0 {
            timePercentage = Int(100 - ((timeLeft / timeSpent) * 100))
        }
        
        return timePercentage
    }
    
    //Calculating the time difference in days hours and minutes
    public func calculateTimeDifference(_ beginDate: Date, endDate: Date) -> (Int, Int, Int) {
        let secsToDay: Double = 86400
        let secsToHour: Double = 3600
        let secsToMinute: Double = 60
        
        let timeGap: TimeInterval? = endDate.timeIntervalSince(beginDate)
 
        let daysGap = Int((timeGap! / secsToDay))
        let hoursGap = Int((timeGap! / secsToHour))
        let minutesGap = Int((timeGap! / secsToMinute))
        
        //Performing time calculations and setting 0 if time is negative
        var remainingDays = daysGap
        if remainingDays < 0 {
            remainingDays = 0
        }
        var remainingHours = hoursGap - (daysGap * 24)
        if remainingHours < 0 {
            remainingHours = 0
        }
        var remainingMinutes = minutesGap - (hoursGap * 60)
        if remainingMinutes < 0 {
            remainingMinutes = 0
        }
        
        return (remainingDays, remainingHours, remainingMinutes)
    }
    
    //Calculating the time difference in Seconds
    public func calculateTimeDifferenceInSecs(_ beginDate: Date, endDate: Date) -> Double {
        let timeGap: TimeInterval? = endDate.timeIntervalSince(beginDate)

        if Double(timeGap!) < 0 {
          return 0
        }
      
        return Double(timeGap!)
  }
    
}
