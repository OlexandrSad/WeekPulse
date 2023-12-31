//
//  NotificationCentr.swift
//  WeekPulse
//
//  Created by Олександр on 31.12.2023.
//

import Foundation
import UserNotifications

class NotificationCentr {
    
    let notificationCentr = UNUserNotificationCenter.current()
    
    
    func requestAuthorization() {
        notificationCentr.requestAuthorization(options: [.alert, .badge, .sound]) { granded, error in
            guard granded else { return }
            self.notificationCentr.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
            }
        }
    }
    
    
    func sendNotification(task: TaskEntity, minutes: Int) {
        let calendar = Calendar.current
        let currentDate = Date()
        let futureDate = task.dedline ?? Date()
        var timeDifference = calendar.dateComponents([.second], from: currentDate, to: futureDate)
       
        if let seconds = timeDifference.second {
            let newSeconds = max(seconds - (minutes*60), 0)
            timeDifference.second = newSeconds
        }
        let title = task.title?.prefix(10)
        
        guard let timeInterval = timeDifference.second, timeInterval > 0, let id = task.id, let title = title else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task \"\(String(describing: title))\""
        content.body = "will be expired in \(minutes) minutes"
        content.sound = UNNotificationSound.default
        let trigger  = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCentr.add(request) { error in
            if let error = error {
                print("Error notification request \(String(describing: error.localizedDescription))")
            }
        }
    }
    
}



