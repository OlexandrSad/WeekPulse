//
//  TasksTableViewCell.swift
//  WeekPulse
//
//  Created by Олександр on 04.01.2024.
//

import UIKit

class TasksTableViewCell: UITableViewCell {

    @IBOutlet weak var priorityView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptLabel: UILabel!
    @IBOutlet weak var dedlineLabel: UILabel!
    @IBOutlet weak var isOnSwitch: UISwitch!
    
    private let dateFormatter = DateFormatter()
    
    private let colorPriorityView: [UIColor] = [.green, .yellow, .red, .systemGray3]
    
    var taskEntity: TaskEntity? {
        didSet {
            setInCell(taskEntity: taskEntity)
        }
    }
    
    
    private func setInCell(taskEntity: TaskEntity?) {
        guard let task = taskEntity, let date = task.dedline else { return }
        titleLabel.text = task.title
        descriptLabel.text = task.descript
        
        let colorForPriority = colorPriorityView[Int(task.priority)]
        priorityView.backgroundColor = colorForPriority

        dateFormatter.dateFormat = "HH:mm"
        dedlineLabel.text = dateFormatter.string(from: date)
         
        isOnSwitch.isOn = task.isOn
        
        let index = Int(task.priority)
        setPriorityView(taskIsOn: task.isOn, priority: index)
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

    
    @IBAction func isOnTaskSwitch(_ sender: UISwitch) {
        taskEntity?.isOn = sender.isOn
        CoreDataManager.shared.saveContext()
        
        guard let task = taskEntity else { return }
        if sender.isOn {
            NotificationCentr.shared.setNotification(for: task)
        } else {
            NotificationCentr.shared.deleteNotification(for: task)
        }
    }
    
}
