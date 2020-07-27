//
//  TaskCellView.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/16/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//
import UIKit

class TaskCellView: UITableViewCell {
    
    var cellDelegate: TaskCellViewDelegate?
 
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var completedLevelLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var taskProgress: LinearProgressBar!
    @IBOutlet weak var daysLeftProgress: CircularProgressBar!
    
    let currentDate: Date = Date()
    let gradients: Gradients = Gradients()
    let newDateFormat: DateFormat = DateFormat()
    let projectFormulas: ProjectFormulas = ProjectFormulas()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
  // View configuration for state selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var notes: String = "Not Available"
    
    func commonInit(_ taskName: String, taskProgress: CGFloat, beginDate: Date, dueDate: Date, notes: String, taskNo: Int) {
        let (daysLeft, hoursLeft, minutesLeft) = projectFormulas.calculateTimeDifference(currentDate, endDate: dueDate)
        let remainingDaysPercentage = projectFormulas.calculateTimePercentageLeft(beginDate, endDate: dueDate)
        
        taskNameLabel.text = taskName
        daysLeftLabel.text = "Time Left : \(daysLeft)d \(hoursLeft)h \(minutesLeft)m "
        
        // Display the task progress to the linear progress bar
        DispatchQueue.main.async {
            let colours = self.gradients.colorForProgress(Int(taskProgress))
            self.taskProgress.startGradientColor = colours[0]
            self.taskProgress.endGradientColor = colours[1]
            self.taskProgress.progress = taskProgress / 100
        }
        //Display the days left in circular progress bar
        DispatchQueue.main.async {
            let colours = self.gradients.colorForProgress(remainingDaysPercentage, negative: true)
            self.daysLeftProgress?.customTitle = "\(daysLeft)"
            self.daysLeftProgress?.customSubtitle = "More days"
            self.daysLeftProgress?.startGradientColor = colours[0]
            self.daysLeftProgress?.endGradientColor = colours[1]
            self.daysLeftProgress?.progress =  CGFloat(remainingDaysPercentage) / 100
        }
        completedLevelLabel.text = "\(Int(taskProgress))% Completed"
        notesLabel.text = "Notes:  \(notes)"
        self.notes = notes
    }
}


protocol TaskCellViewDelegate {
    func viewNotes(cell: TaskCellView, sender button: UIButton, data data: String)
}
