//
//  TaskTableViewCell.swift
//  WeekPulse
//
//  Created by Олександр on 25.11.2023.
//

import UIKit

final class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var priorityView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dedlineLabel: UILabel!
    @IBOutlet weak var isOnSwitch: UISwitch!
    
    let animator = Animator()
    private let dateFormatter = DateFormatter()
    private let colorPriorityView: [UIColor] = [.green, .yellow, .red, .systemGray3]
    
    var taskEntity: TaskEntity? {
        didSet {
            setInCell(taskEntity: taskEntity)
            if let task = taskEntity, task.isOn {
                animator.makeAnimation(task: taskEntity, label: dedlineLabel, view: priorityView)
            } else {
                dedlineLabel.layer.removeAllAnimations()
                priorityView.layer.removeAllAnimations()
            }
            
        }
    }
    
    
    private func setInCell(taskEntity: TaskEntity?) {
        guard let task = taskEntity, let date = task.dedline else { return }
        titleLabel.text = task.title
        
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
            NotificationManager.shared.setNotification(for: task)
        } else {
            NotificationManager.shared.deleteNotification(for: task)
        }
    }
    
}
