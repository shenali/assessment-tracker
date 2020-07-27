//
//  AddTaskViewController.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/16/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import EventKit

class AddTaskViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UNUserNotificationCenterDelegate {
    
    var tasks: [NSManagedObject] = []
    var beginDatePickerShown = false
    var dueDatePickerVisible = false
    var taskProgressPickerVisible = false
    var chosenAssessment: Assessment?
    var editingMode: Bool = false
    
    let currentDate = Date()
    let newDateFormat: DateFormat = DateFormat()
    let notificationCenter = UNUserNotificationCenter.current()

    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var progressLabel: UITextField!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var addTaskButton: UIBarButtonItem!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet var addNotificationSwitch: UISwitch!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var setReminderSwitch: UISwitch!
    
    var startTaskEdit: Task? {
        didSet {
            editingMode = true
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure User Notification Center
        notificationCenter.delegate = self
        
        // set end date picker maximum date to project end date
        dueDatePicker.maximumDate = chosenAssessment!.dueDate as! Date
        
        if !editingMode {
            // Set start date to current
            startDatePicker.minimumDate = currentDate
            startDateLabel.text = newDateFormat.formatInputDate(currentDate)
            
            // End date set to one minute more than current time
            var time = Date()
            time.addTimeInterval(TimeInterval(60.00))
            dueDateLabel.text = newDateFormat.formatInputDate(time)
            dueDatePicker.minimumDate = time
            
            // Settings the placeholder for notes UITextView
            notesTextView.delegate = self
            
            // Setting the initial task progress
            progressSlider.value = 0
            progressLabel.text = "0%"
        }
        
        configureView()
        toggleAddButtonEnability()
    }
    
    func configureView() {
        if editingMode {
            self.navigationItem.title = "Edit Task"
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        
        if let task = startTaskEdit {
            if let textField = taskNameTextField {
                textField.text = task.name
            }
            if let textView = notesTextView {
                textView.text = task.notes
            }
            if let label = startDateLabel {
                label.text = newDateFormat.formatInputDate(task.beginDate as Date)
            }
            if let datePicker = startDatePicker {
                datePicker.date = task.beginDate as Date
            }
            if let label = dueDateLabel {
                label.text = newDateFormat.formatInputDate(task.dueDate as Date)
            }
            if let datePicker = dueDatePicker {
                datePicker.date = task.dueDate as Date
            }
            if let label = progressLabel {
                label.text = "\(Int(task.progress))%"
            }
            if let slider = progressSlider {
                slider.value = task.progress / 100
            }
        }
    }
    
    @IBAction func handleAddButtonClick(_ sender: UIBarButtonItem) {
        if validate() {
            let taskName = taskNameTextField.text
            let notes = notesTextView.text
            let dueDate = dueDatePicker.date
            let beginDate = startDatePicker.date
            let progress = Float(progressSlider.value * 100)
              let eventStore = EKEventStore()
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)!
            
            var task = NSManagedObject()
            
            if editingMode {
                task = (startTaskEdit as? Task)!
            } else {
                task = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            
            task.setValue(taskName, forKeyPath: "name")
            task.setValue(notes, forKeyPath: "notes")
            task.setValue(beginDate, forKeyPath: "beginDate")
            task.setValue(dueDate, forKeyPath: "dueDate")
            task.setValue(progress, forKey: "progress")
            
            chosenAssessment?.addToTasks((task as? Task)!)
            
            if (EKEventStore.authorizationStatus(for: .reminder) != EKAuthorizationStatus.authorized) {
                    eventStore.requestAccess(to: .event, completion: {
                    granted, error in
                        self.AddReminder(eventStore : eventStore, title: taskName!, note: notes!, endDate: dueDate)
                    }) }
            else {
                    AddReminder(eventStore: eventStore, title: taskName!, note: notes!, endDate: dueDate)
                 }
            
            do {
                try managedContext.save()
                tasks.append(task)
            } catch _ as NSError {
                let alert = UIAlertController(title: "Error", message: "An error occured while saving the task.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill the required fields.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        // Dismiss PopOver
        dismissAddTaskPopOver()
    }
    
    @IBAction func handleStartDateChange(_ sender: UIDatePicker) {
        startDateLabel.text = newDateFormat.formatInputDate(sender.date)
        
        // Set end date minimum to one minute ahead the start date
        let dueDate = sender.date.addingTimeInterval(TimeInterval(60.00))
        dueDatePicker.minimumDate = dueDate
        dueDateLabel.text = newDateFormat.formatInputDate(dueDate)
    }
    
    @IBAction func handleEndDateChange(_ sender: UIDatePicker) {
        dueDateLabel.text = newDateFormat.formatInputDate(sender.date)
        
        // Set start date maximum to one minute before the end date
        startDatePicker.maximumDate = sender.date.addingTimeInterval(-TimeInterval(60.00))
    }
    
    @IBAction func handleCancelButtonClick(_ sender: UIBarButtonItem) {
        dismissAddTaskPopOver()
    }

    @IBAction func handleTaskNameChange(_ sender: Any) {
        toggleAddButtonEnability()
    }
    
    @IBAction func handleProgressChange(_ sender: UISlider) {
        let progress = Int(sender.value * 100)
        progressLabel.text = "\(progress)%"
    }
    
    
    @IBAction func SetUpReminder(_ sender: Any) {
    }
    // Create Reminder
    func AddReminder(eventStore: EKEventStore, title: String, note: String, endDate: Date) {
        if setReminderSwitch.isOn {
            eventStore.requestAccess(to: EKEntityType.reminder, completion: {
               granted, error in
               if (granted) && (error == nil) {
            
                 let reminder:EKReminder = EKReminder(eventStore: eventStore)
                 reminder.title = title
                 reminder.notes = note

                 let alarmTime = endDate.addingTimeInterval(10)
                 let alarm = EKAlarm(absoluteDate: alarmTime)
                 reminder.addAlarm(alarm)

                 reminder.calendar = eventStore.defaultCalendarForNewReminders()


                 do {
                   try eventStore.save(reminder, commit: true)
                 } catch {
                   print("Cannot save")
                   return
                 }
                 print("Reminder saved")
               }
              })
        }
     }


    
    // Check if the required fields are empty or not
    func validate() -> Bool {
        if !(taskNameTextField.text?.isEmpty)! && !(notesTextView.text == "Notes") && !(notesTextView.text?.isEmpty)! {
            return true
        }
        return false
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.black {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        toggleAddButtonEnability()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        toggleAddButtonEnability()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Notes"
            textView.textColor = UIColor.lightGray
        }
        toggleAddButtonEnability()
    }
    
    // Handle add button
    func toggleAddButtonEnability() {
        if validate() {
            addTaskButton.isEnabled = true;
        } else {
            addTaskButton.isEnabled = false;
        }
    }
    
    // Dismiss the add task popup
    func dismissAddTaskPopOver() {
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
}

extension AddTaskViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            taskNameTextField.becomeFirstResponder()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            notesTextView.becomeFirstResponder()
        }

        if(indexPath.section == 1 && indexPath.row == 0) {
            beginDatePickerShown = !beginDatePickerShown
            tableView.reloadData()
        }
        if(indexPath.section == 1 && indexPath.row == 2) {
            dueDatePickerVisible = !dueDatePickerVisible
            tableView.reloadData()
        }

        if(indexPath.section == 2 && indexPath.row == 0) {
            taskProgressPickerVisible = !taskProgressPickerVisible
            tableView.reloadData()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            if beginDatePickerShown == false {
                return 0.0
            }
            return 200.0
        }
        if indexPath.section == 1 && indexPath.row == 3 {
            if dueDatePickerVisible == false {
                return 0.0
            }
            return 200.0
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            if taskProgressPickerVisible == false {
                return 0.0
            }
            return 100.0
        }

        if indexPath.section == 0 && indexPath.row == 1 {
            return 90.0
        }
        
        return 50.0
    }
}
