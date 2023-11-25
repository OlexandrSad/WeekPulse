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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setPriorityView(color: .red)
    }
    
    func setPriorityView(color: UIColor) {
        priorityView.backgroundColor = color
        priorityView.layer.cornerRadius = 15
        priorityView.layer.borderWidth = 3
        priorityView.layer.borderColor = UIColor.black.cgColor
        priorityView.layer.shadowRadius = 15
        priorityView.layer.shadowColor = color.cgColor
        priorityView.layer.shadowOffset = CGSize(width: 0, height: 0)
        priorityView.layer.shadowOpacity = .pi
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
