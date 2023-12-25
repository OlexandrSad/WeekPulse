//
//  ToTaskVCProtocol.swift
//  WeekPulse
//
//  Created by Олександр on 25.12.2023.
//

import Foundation

protocol ToTaskVCProtocol {
    var dateFromVC: Date {get set}
    var task: TaskEntity? {get set}
}
