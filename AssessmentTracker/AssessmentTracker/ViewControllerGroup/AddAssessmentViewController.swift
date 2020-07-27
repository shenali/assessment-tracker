//
//  AddAssessmentViewController.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/16/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import EventKit
import UserNotifications

class AddAssessmentViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate {
    
    var assessments: [NSManagedObject] = []
    var isDatePickerShown = false
    var editingAllowed: Bool = false
    let currentDate = Date();
    
    let newDateFormat: DateFormat = DateFormat()
    var reminders: [EKReminder]!
    let center = UNUserNotificationCenter.current()
    
    @IBOutlet weak var assessmentNameTextV: UITextField!
    @IBOutlet weak var moduleNameTextV: UITextField!
    @IBOutlet weak var levelNameTextV: UITextField!
    @IBOutlet weak var weightTextV: UITextField!
    @IBOutlet weak var marksTextV: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var addProjectButton: UIBarButtonItem!
    @IBOutlet weak var dueDateLabel: UITextField!
    @IBOutlet var addToCalendarSwitch: UISwitch!
    @IBOutlet weak var endDatePicker: UIDatePicker!
  
    var editAssessment: Assessment? {
        didSet {
            // Update the UI
            editingAllowed = true
            UIConfiguration()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
           center.requestAuthorization(options: [.alert,.sound]) { (granted, error) in
               
           }
        endDatePicker.minimumDate = currentDate
        
         //Date is initially set one hour ahead of current time
        if !editingAllowed {
            var time = Date()
            time.addTimeInterval(TimeInterval(60.00 * 60.00))
            dueDateLabel.text = newDateFormat.formatInputDate(time)
            notesTextView.delegate = self
        }
        UIConfiguration()
        addButtonToggle()
    }
    
    
    
    func UIConfiguration() {
        if editingAllowed {
            self.navigationItem.title = "Edit Assessment"
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        
        if let assessment = editAssessment {
            if let projectName = assessmentNameTextV { projectName.text = editAssessment?.assessmentName }
            
            if let notes = notesTextView { notes.text = editAssessment?.notes }
            
            if let modulename = moduleNameTextV { modulename.text = editAssessment?.moduleName }
            
            if let level = levelNameTextV { level.text = editAssessment?.level }
            
            if let contribution = weightTextV { contribution.text =  String(editAssessment!.contribution) }
            
            if let marks = marksTextV { marks.text = String(editAssessment!.markAwarded) }
            
            if let endDate = dueDateLabel { endDate.text = newDateFormat.formatInputDate(editAssessment?.dueDate as! Date)}
            
            if let endDatePicker = endDatePicker { endDatePicker.date = editAssessment?.dueDate as! Date }
            
            if let addToCalendar = addToCalendarSwitch { addToCalendar.setOn((editAssessment?.addToCalendar)!, animated: true)}
        }
    }
        
    @IBAction func handleAddButtonClick(_ sender: UIBarButtonItem) {
        if validateEmptyFields() {
            var calendarIdentifier = ""
            var addedToCalendar = false
            var eventDeleted = false
            let addToCalendarFlag = Bool(addToCalendarSwitch.isOn)
            let eventStore = EKEventStore()
            
            let moduleName = moduleNameTextV.text
            let level = levelNameTextV.text
            let contribution = weightTextV.text
            let marks = marksTextV.text
            let projectName = assessmentNameTextV.text
            let endDate = endDatePicker.date
            let notes = notesTextView.text

            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Assessment", in: managedContext)!
             var assessment = NSManagedObject()

                     
            if editingAllowed {
                assessment = (editAssessment as? Assessment)!
            } else {
                assessment = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            
            if addToCalendarFlag {
                if editingAllowed {
                    if let assessment = editAssessment {
                        if !assessment.addToCalendar {
                            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                                eventStore.requestAccess(to: .event, completion: {
                                    granted, error in
                                    calendarIdentifier = self.EKEventCreate(eventStore, title: projectName!, beginDate: self.currentDate, endDate: endDate)
                                })
                            } else {
                                calendarIdentifier = EKEventCreate(eventStore, title: projectName!, beginDate: currentDate, endDate: endDate)
                   
                            }
                        }
                    }
                } else {
                    if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                        eventStore.requestAccess(to: .event, completion: {
                            granted, error in
                            calendarIdentifier = self.EKEventCreate(eventStore, title: projectName!, beginDate: self.currentDate, endDate: endDate)

                        })
                    } else {
                        calendarIdentifier = EKEventCreate(eventStore, title: projectName!, beginDate: currentDate, endDate: endDate)

                    }
                }
                if calendarIdentifier != "" {
                    addedToCalendar = true
                }
            } else {
                if editingAllowed {
                    if let assessment = editAssessment {
                        if assessment.addToCalendar {
                            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                                eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
                                    eventDeleted = self.EKEventDelete(eventStore, eventIdentifier: assessment.calendarIdentifier!)
                                })
                            } else {
                                eventDeleted = EKEventDelete(eventStore, eventIdentifier: assessment.calendarIdentifier!)
                            }
                        }
                    }
                }
            }
            
            if eventDeleted {
                addedToCalendar = false
            }
            
            assessment.setValue(projectName, forKeyPath: "assessmentName")
            assessment.setValue(notes, forKeyPath: "notes")
            assessment.setValue(moduleName, forKey: "moduleName")
            assessment.setValue(level, forKey: "level")
            assessment.setValue((contribution as! NSString).doubleValue, forKey: "contribution")
            assessment.setValue((marks as! NSString).doubleValue, forKey: "markAwarded")

            if editingAllowed {
                assessment.setValue(editAssessment?.beginDate, forKeyPath: "beginDate")
            } else {
                assessment.setValue(currentDate, forKeyPath: "beginDate")
            }
            
            assessment.setValue(endDate, forKeyPath: "dueDate")
            assessment.setValue(addedToCalendar, forKeyPath: "addToCalendar")
            assessment.setValue(calendarIdentifier, forKey: "calendarIdentifier")
            
            print(assessment)
            
            do {
                try managedContext.save()
                assessments.append(assessment)
            } catch _ as NSError {
                let alert = UIAlertController(title: "Error", message: "Couldn't save the assessment", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Fill the required fields", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        dissmissAssessmentPopUp()
    }
    // Create event
    func EKEventCreate(_ eventStore: EKEventStore, title: String, beginDate: Date, endDate: Date) -> String {
        let event = EKEvent(eventStore: eventStore)
        var identifier = ""
        
        event.title = title
        event.startDate = beginDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            let aInterval: TimeInterval = -5 * 60
            let alaram = EKAlarm(relativeOffset: aInterval)
            event.addAlarm(alaram)
            try eventStore.save(event, span: .thisEvent)
            identifier = event.eventIdentifier
        } catch {
            let alert = UIAlertController(title: "Error", message: "Calendar event could not be created!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        return identifier
    }
    // Removes event
    func EKEventDelete(_ eventStore: EKEventStore, eventIdentifier: String) -> Bool {
        var success = false
        let eventToRemove = eventStore.event(withIdentifier: eventIdentifier)
        if eventToRemove != nil {
            do {
                try eventStore.remove(eventToRemove!, span: .thisEvent)
                success = true
            } catch {
                let alert = UIAlertController(title: "Error", message: "Calendar event could not be deleted!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                success = false
            }
        }
        return success
    }
    
    
    @IBAction func handleDateChange(_ sender: UIDatePicker) {
        dueDateLabel.text = newDateFormat.formatInputDate(sender.date)
    }
    
    @IBAction func handleCancelButtonClick(_ sender: UIBarButtonItem) {
        dissmissAssessmentPopUp()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        addButtonToggle()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        addButtonToggle()
    }
    
    // Handle add button
    func addButtonToggle() {
        if validateEmptyFields() {
            addProjectButton.isEnabled = true;
        } else {
            addProjectButton.isEnabled = false;
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
        }
        addButtonToggle()
    }
    
    // Dissmiss the add assessment popup
    func dissmissAssessmentPopUp() {
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
    // Empty feild validation
    func validateEmptyFields() -> Bool {
        if !(assessmentNameTextV.text?.isEmpty)! && !(notesTextView.text == "Notes") && !(notesTextView.text?.isEmpty)! && !(moduleNameTextV.text?.isEmpty)! && !(weightTextV.text?.isEmpty)! && !(marksTextV.text?.isEmpty)!{
            return true
        }
        return false
    }
}

extension AddAssessmentViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            assessmentNameTextV.becomeFirstResponder()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            notesTextView.becomeFirstResponder()
        }

        if(indexPath.section == 1 && indexPath.row == 0) {
            isDatePickerShown = !isDatePickerShown
            tableView.reloadData()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            if isDatePickerShown == false {
                return 0.0
            }
            return 200.0
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            return 90.0
        }
        
        return 60.0
    }
}
