//
//  TaskTableViewCell.swift
//  WeekPulse
//
//  Created by Олександр on 25.11.2023.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var priorityView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dedlineLabel: UILabel!
    @IBOutlet weak var isOnSwitch: UISwitch!
    
    private let colorPriorityView: [UIColor] = [.green, .yellow, .red, .systemGray3]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setPriorityView(taskIsOn: true, priority: 2)
    }
    
    private func setPriorityView(taskIsOn: Bool, priority: Int) {
        priorityView.layer.cornerRadius = 15
        priorityView.layer.borderWidth = 3
        priorityView.layer.shadowRadius = 15
        priorityView.layer.shadowOffset = CGSize(width: 0, height: 0)
        priorityView.layer.shadowOpacity = .pi
        
        if taskIsOn {
            titleLabel.textColor = .black
            priorityView.layer.borderColor = UIColor.black.cgColor
            priorityView.backgroundColor = colorPriorityView[priority]
            priorityView.layer.shadowColor = colorPriorityView[priority].cgColor
        } else {
            titleLabel.textColor = .lightGray
            priorityView.layer.borderColor = UIColor.gray.cgColor
            priorityView.backgroundColor = colorPriorityView.last
            priorityView.layer.shadowColor = colorPriorityView.last?.cgColor
        }
    }
    
}
