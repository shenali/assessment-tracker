//
//  AssessmentTableCell.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/16/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//
import UIKit

class AssessmentTableCell: UITableViewCell {
    
    var cellDelegate: AssessmentTableCellDelegate?

    @IBOutlet weak var levelNameLabel: UILabel!
    @IBOutlet weak var modelNameLabel: UILabel!
    @IBOutlet weak var assessmentNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var contributionLabel: UILabel!
    @IBOutlet weak var marksLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // View configuration for state selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    var notes: String = "Not Available"
    
    func commonInit(_ projectName: String, taskProgress: CGFloat, dueDate: Date, notes: String, moduleName: String, level: String, markAwarded: Double, contribution: Double  ) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        
        //set up values added in add assessment to master view
        modelNameLabel.text = moduleName
        levelNameLabel.text = "Level: \(level)"
        assessmentNameLabel.text = projectName
        dueDateLabel.text = "Deadline: \(formatter.string(from: dueDate))"
        marksLabel.text = "Marks:  \(Int(markAwarded))%"
        contributionLabel.text =  "Contribution:  \(Int(contribution))%"
        self.notes = notes
    }
}

protocol AssessmentTableCellDelegate {
    func customCell(cell: AssessmentTableCell, sender button: UIButton, data data: String)
}
