//
//  AssessmentModel.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/15/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//

import Foundation
import CoreData

extension Assessment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assessment> {
        return NSFetchRequest<Assessment>(entityName: "Assessment")
    }
    @NSManaged public var moduleName: String
    @NSManaged public var assessmentName: String
    @NSManaged public var markAwarded: Double
    @NSManaged public var contribution: Double
    @NSManaged public var addToCalendar: Bool
    @NSManaged public var dueDate: NSDate
    @NSManaged public var level: String
    @NSManaged public var notes: String
    @NSManaged public var beginDate: NSDate
    @NSManaged public var calendarIdentifier: String?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension Assessment {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
