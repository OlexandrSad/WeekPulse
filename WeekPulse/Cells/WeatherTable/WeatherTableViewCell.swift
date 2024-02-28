//
//  WeatherTableViewCell.swift
//  WeekPulse
//
//  Created by Олександр on 29.01.2024.
//

import UIKit

final class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempConstLabel: UILabel!
    @IBOutlet weak var windConstLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tempConstLabel.text = "t, ℃"
        windConstLabel.text = "Wind, m/s"
    }
    
    func setViews(array: [String]) {
        timeLabel.text = array[0]
        tempLabel.text = array[1]
        windLabel.text = array[2]
        iconImageView.image = UIImage(named: array[3])
        conditionLabel.text = array[4]
    }
}
