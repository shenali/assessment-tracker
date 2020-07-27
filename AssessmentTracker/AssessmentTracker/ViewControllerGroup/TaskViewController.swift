//
//  TaskViewController.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/16/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class TaskViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var daysRemainingProgressBar: CircularProgressBar!
    @IBOutlet weak var projectDetailView: UIView!
    @IBOutlet weak var addTaskButton: UIBarButtonItem!
    @IBOutlet weak var editTaskButton: UIBarButtonItem!
    @IBOutlet weak var addToCalendarButton: UIBarButtonItem!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var assessmentProgress: LinearProgressBar!
    
    let newDateFormat: DateFormat = DateFormat()
    let projectFormulas: ProjectFormulas = ProjectFormulas()
    let gradients: Gradients = Gradients()
    
    var taskViewController: TaskViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    let currentDate = Date()
    
    var selectedProject: Assessment? {
        didSet {
            UIConfiguration()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIConfiguration()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        self.managedObjectContext = appDelegate.persistentContainer.viewContext
        let cellName = UINib(nibName: "TaskCellView", bundle: nil)
        taskTable.register(cellName, forCellReuseIdentifier: "TaskCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Default task row selection
        let indexPath = IndexPath(row: 0, section: 0)
        if taskTable.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
            taskTable.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        }
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let fetchedResult = self.fetchedResultsController.managedObjectContext
        let newTask = Task(context: fetchedResult)
        do {
            try fetchedResult.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    //Configure ui and set values
    func UIConfiguration() {
        if let assessment = selectedProject {
            if let nameLabel = projectNameLabel {
                nameLabel.text = assessment.assessmentName
            }
            if let dueDateLabel = dueDateLabel {
                dueDateLabel.text = "Due Date: \(newDateFormat.formatInputDate(assessment.dueDate as Date))"
            }
            
            if let notesLabel = notesLabel {
                notesLabel.text = "Notes: \(assessment.notes)"
                   }
            
            if let levelLabel = levelLabel {
                levelLabel.text = "Level:  \(assessment.level)"
                   }
            
            if let markLabel = markLabel {
                    markLabel.text = "Mark:  \(Int(assessment.markAwarded))%"
                       }
                
            if let weightLabel = weightLabel {
                weightLabel.text = "Weight:  \(Int(assessment.contribution))%"
                       }
                
            let tasks = (assessment.tasks!.allObjects as! [Task])
            let projectProgress = projectFormulas.calculateAssesmentProgress(tasks)
            let daysLeftProgress = projectFormulas.calculateTimePercentageLeft(assessment.beginDate as Date, endDate: assessment.dueDate as Date)
            var daysRemaining = self.projectFormulas.calculateDaysLeft(self.currentDate, endDate: assessment.dueDate as Date)
            
            if daysRemaining < 0 {
                daysRemaining = 0
            }
            
            if let progressLabel = progressLabel {
                               progressLabel.text = "\(projectProgress)% completed"
                                  }
            
            DispatchQueue.main.async {
                let colours = self.gradients.colorForProgress(projectProgress)
                self.assessmentProgress?.startGradientColor = colours[0]
                self.assessmentProgress?.endGradientColor = colours[1]
                self.assessmentProgress?.progress = CGFloat(projectProgress) / 100

              }
              
            DispatchQueue.main.async {
                let colours = self.gradients.colorForProgress(daysLeftProgress, negative: true)
                self.daysRemainingProgressBar?.customTitle = "\(daysRemaining)"
                self.daysRemainingProgressBar?.customSubtitle = "More days"
                self.daysRemainingProgressBar?.startGradientColor = colours[0]
                self.daysRemainingProgressBar?.endGradientColor = colours[1]
                self.daysRemainingProgressBar?.progress =  CGFloat(daysLeftProgress) / 100
            }
        }
        
        if selectedProject == nil {
            taskTable.isHidden = true
            projectDetailView.isHidden = true
        }
    }

    //The add button functionality handled
    @IBAction func handleAddEventClick(_ sender: Any) {
        let eventStore = EKEventStore()
        
        if let assessment = selectedProject {
            if !assessment.addToCalendar {
                if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                    eventStore.requestAccess(to: .event, completion: {
                        granted, error in
                        self.createEvent(eventStore, title: assessment.assessmentName, beginDate: assessment.beginDate as Date, endDate: assessment.dueDate as Date)})
                } else {
                    createEvent(eventStore, title: assessment.assessmentName, beginDate: assessment.beginDate as Date, endDate: assessment.dueDate as Date)
                }
                let alert = UIAlertController(title: "Success", message: "The project was added to the Calendar!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Warning", message: "The project is already on the Calendar!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func handleRefreshClick(_ sender: Any) {
    }

//    Add task identifier
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddTaskViewController
            controller.chosenAssessment = selectedProject
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 400, height: 495)
            }
        }
//    Edit task identifier
        if segue.identifier == "editTask" {
            if let indexPath = taskTable.indexPathForSelectedRow {
                let fetchedObject = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! AddTaskViewController
                controller.startTaskEdit = fetchedObject as Task
                controller.chosenAssessment = selectedProject
                controller.preferredContentSize = CGSize(width: 400, height: 495)
            }
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
           switch type {
           case .insert:
               taskTable.insertSections(IndexSet(integer: sectionIndex), with: .fade)
           case .delete:
               taskTable.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
           default:
               return
           }
       }
       
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
           switch type {
           case .insert:
               taskTable.insertRows(at: [newIndexPath!], with: .fade)
           case .delete:
               taskTable.deleteRows(at: [indexPath!], with: .fade)
           case .update:
               configureCell(taskTable.cellForRow(at: indexPath!)! as! TaskCellView, withTask: anObject as! Task, index: indexPath!.row)
           case .move:
               configureCell(taskTable.cellForRow(at: indexPath!)! as! TaskCellView, withTask: anObject as! Task, index: indexPath!.row)
               taskTable.moveRow(at: indexPath!, to: newIndexPath!)
           }
           UIConfiguration()
       }
       
       func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           taskTable.endUpdates()
       }
       
    //define number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        if selectedProject == nil {
            projectDetailView.isHidden = true
        //    projectProgressBar.isHidden = true
            assessmentProgress.isHidden = true
            daysRemainingProgressBar.isHidden = true
            addTaskButton.isEnabled = false
            editTaskButton.isEnabled = false
            addToCalendarButton.isEnabled = false
            taskTable.setEmptyMessage("Insert a new assessment", UIColor.black)
            //return 0
        }
        
        if sectionInfo.numberOfObjects == 0 {
            editTaskButton.isEnabled = false
            taskTable.setEmptyMessage("There are no tasks added for this assessment", UIColor.black)
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCellView
        let task = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withTask: task, index: indexPath.row)
        cell.cellDelegate = self
        let backgroundView = UIView()
          backgroundView.backgroundColor =  UIColor.init(red: (83.0/255.0), green: (83.0/255.0), blue: (83.0/255.0), alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: TaskCellView, withTask task: Task, index: Int) {
        cell.commonInit(task.name, taskProgress: CGFloat(task.progress), beginDate: task.beginDate as Date, dueDate: task.dueDate as Date, notes: task.notes, taskNo: index + 1)
    }
    
    var fetchedResultsController: NSFetchedResultsController<Task> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        if selectedProject != nil {
            let predicate = NSPredicate(format: "%K == %@", "project", selectedProject as! Assessment)
            fetchRequest.predicate = predicate
        }

        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "beginDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "\(UUID().uuidString)-project")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        taskTable.beginUpdates()
    }
    
   
    // Event initiated in ekStore
    func createEvent(_ eventStore: EKEventStore, title: String, beginDate: Date, endDate: Date) -> String {
        let event = EKEvent(eventStore: eventStore)
        var identifier = ""
        
        event.title = title
        event.startDate = beginDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            identifier = event.eventIdentifier
           
        } catch {
            let alert = UIAlertController(title: "Error", message: "Couldn't create calendar event", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        return identifier
    }
}


extension TaskViewController: TaskCellViewDelegate {
    func viewNotes(cell: TaskCellView, sender button: UIButton, data data: String) {
    }
}
