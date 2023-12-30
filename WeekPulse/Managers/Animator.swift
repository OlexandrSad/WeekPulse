//
//  Animator.swift
//  WeekPulse
//
//  Created by Олександр on 30.12.2023.
//

import Foundation
import UIKit

class Animator {
    
    func makeAnimation(task: TaskEntity?, label: UILabel, view: UIView) {
        guard let task = task, let taskDedline = task.dedline, task.isOn else { return }
        let today = Date()
        
        if taskDedline < today {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.autoreverse, .repeat], animations: {
                label.textColor = .red
                label.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { _ in
                label.layer.removeAllAnimations()
                view.layer.removeAllAnimations()
                label.textColor = .gray
                label.transform = CGAffineTransform(scaleX: 1, y: 1)
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
}
