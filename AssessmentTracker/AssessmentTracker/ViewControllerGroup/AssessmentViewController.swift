//
//  AssessmentViewController.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/15/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//

import UIKit
import CoreData

class AssessmentViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {

    var taskViewController: TaskViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet var assessmentTable: UITableView!
    
    let projectFormulas: ProjectFormulas = ProjectFormulas()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let splitView = splitViewController {
            let controllers = splitView.viewControllers
            taskViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? TaskViewController
        }
        let cellName = UINib(nibName: "AssessmentTableCell", bundle: nil)
        tableView.register(cellName, forCellReuseIdentifier: "AssessmentCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        selectRow()
    }

    @objc
    func insertNewObject(_ sender: Any) {
        let fetchedResult = self.fetchedResultsController.managedObjectContext
        do {
            try fetchedResult.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "showAssessmentDetails", sender: object)
        }
    }
    
    // Maps seques
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAssessmentDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! TaskViewController
                controller.selectedProject = object as Assessment
            }
        }
        
        if segue.identifier == "addAssessment" {
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 460, height: 600)
            }
        }
        
        if segue.identifier == "editAssessment" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! AddAssessmentViewController
                controller.editAssessment = object as Assessment
                  controller.preferredContentSize = CGSize(width: 460, height: 600)
            }
        }
    }

        // Setting up table views
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentCell", for: indexPath) as! AssessmentTableCell
        let assessment = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withAssessment: assessment)
        cell.cellDelegate = self
        
        let backgroundView = UIView()
        backgroundView.backgroundColor =  UIColor.init(red: (83.0/255.0), green: (83.0/255.0), blue: (83.0/255.0), alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        selectRow()
    }

    func configureCell(_ cell: AssessmentTableCell, withAssessment assessment: Assessment) {
        let assessmentProgress = projectFormulas.calculateAssesmentProgress(assessment.tasks!.allObjects as! [Task])
        
        cell.commonInit(assessment.assessmentName, taskProgress: CGFloat(assessmentProgress),dueDate: assessment.dueDate as Date, notes: assessment.notes, moduleName: assessment.moduleName, level: assessment.level, markAwarded: assessment.markAwarded as Double, contribution: assessment.contribution as Double)
    }

    var fetchedResultsController: NSFetchedResultsController<Assessment> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Assessment> = Assessment.fetchRequest()
       
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "beginDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        selectRow()
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Assessment>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)! as! AssessmentTableCell, withAssessment: anObject as! Assessment)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)! as! AssessmentTableCell, withAssessment: anObject as! Assessment)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        
        selectRow()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func selectRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        if tableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                self.performSegue(withIdentifier: "showAssessmentDetails", sender: object)
            }
        } else {
            let empty = {}
            self.performSegue(withIdentifier: "showAssessmentDetails", sender: empty)
        }
    }
}

extension AssessmentViewController: AssessmentTableCellDelegate {
    func customCell(cell: AssessmentTableCell, sender button: UIButton, data data: String) {
    }
}
