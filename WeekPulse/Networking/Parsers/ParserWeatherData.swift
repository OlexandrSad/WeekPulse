//
//  ParserWeatherData.swift
//  WeekPulse
//
//  Created by Олександр on 17.01.2024.
//
import UIKit
import Foundation

class ParserWeatherData {
    
    func setViews(weatherData: WeatherData, weatherLabel: UILabel, town: String, dayVC: Date,
                  timeLeftLabel: UILabel, timeCentrLabel: UILabel, timeRightLabel: UILabel,
                  tempLeftLabel: UILabel, tempCentrLabel: UILabel, tempRightLabel: UILabel,
                  windLeftLabel: UILabel, windCentrLabel: UILabel, windRightLabel: UILabel,
                  leftImageView: UIImageView, centrImageView: UIImageView, rightImageView: UIImageView) {
        
        weatherLabel.text = town
        
        let arrays = createArrays(weatherData: weatherData)
        let indexSelectedArray = findArray(arrays: arrays, dayVC: dayVC)
        
        if let indexOfChosedArray = indexSelectedArray {
            let selectedArray = arrays[indexOfChosedArray]
            
            let stringsArray = createStringArray(array: selectedArray, indexInArrays: indexOfChosedArray, arraysCount: arrays.count)
            
            timeLeftLabel.text = stringsArray[0]
            timeCentrLabel.text = stringsArray[1]
            timeRightLabel.text = stringsArray[2]
            tempLeftLabel.text = stringsArray[3]
            windLeftLabel.text = stringsArray[4]
            leftImageView.image = UIImage(named: stringsArray[5])
            tempCentrLabel.text = stringsArray[6]
            windCentrLabel.text = stringsArray[7]
            centrImageView.image = UIImage(named: stringsArray[8])
            tempRightLabel.text = stringsArray[9]
            windRightLabel.text = stringsArray[10]
            rightImageView.image = UIImage(named: stringsArray[11])
        } else {
            timeLeftLabel.text = "-"
            timeCentrLabel.text = "-"
            timeRightLabel.text = "-"
            tempLeftLabel.text = "-"
            windLeftLabel.text = "-"
            leftImageView.image = UIImage(named: "-")
            tempCentrLabel.text = "-"
            windCentrLabel.text = "-"
            centrImageView.image = UIImage(named: "-")
            tempRightLabel.text = "-"
            windRightLabel.text = "-"
            rightImageView.image = UIImage(named: "-")
        }
    }
    
    
    private func createArrays(weatherData: WeatherData) -> [[List]] {
        var arrays = [[List]]()
        var count = 0
        var tempDay = String(weatherData.list?.first?.date?.prefix(10) ?? "")
        guard let list = weatherData.list else { return [[]] }
        
        for element in list {
            let shortDay = String(element.date?.prefix(10) ?? "")
            
            if tempDay == shortDay {
                if arrays.isEmpty {
                    arrays.append([])
                    arrays[count].append(element)
                } else {
                    arrays[count].append(element)
                }
            } else {
                arrays.append([])
                count += 1
                tempDay = shortDay
                arrays[count].append(element)
            }
        }
        return arrays
    }
    
    
    private func findArray(arrays: [[List]], dayVC: Date) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateVC = dateFormatter.string(from: dayVC)
        var selectedArray: Int?
        
        for (index, element) in arrays.enumerated() {
            let dateFromArray = String(element.first?.date?.prefix(10) ?? "")
            if dateFromArray == dateVC {
                selectedArray = index
            }
        }
        return selectedArray
    }
    
    
    private func createStringArray(array: [List], indexInArrays: Int, arraysCount: Int) -> [String] {
        var stringArray = [String]()
        
        if arraysCount == 5 {
            stringArray = fullArray(array: array, timePoints: ["03:00", "12:00", "21:00"], index1: 1, index2: 4, index3: 7)
        } else {
            switch indexInArrays {
            case 0: stringArray = startArray(array: array)
            case 1,2,3,4:
                stringArray = fullArray(array: array, timePoints: ["03:00", "12:00", "21:00"], index1: 1, index2: 4, index3: 7)
            case 5: stringArray = endArray(array: array)
            default: break
            }
        }
        return stringArray
    }
    
    
    private func fullArray(array: [List], timePoints: [String], index1: Int?, index2: Int?, index3: Int?) -> [String] {
        var stringArray = timePoints
        let indexes = [index1, index2, index3]
        for index in indexes {
            let temp = index != nil ? array[index!].main?.temp : nil
            let wind = index != nil ? array[index!].wind?.speed : nil
            let icon = index != nil ? array[index!].weather?[0].icon : nil
            
            stringArray.append(index != nil ? String(format: "%.1f", temp!) : "-")
            stringArray.append(index != nil ? String(wind!) : "-")
            stringArray.append(index != nil ? String(icon!) : "-")
        }
        return stringArray
    }
    
    
    private func startArray(array: [List]) -> [String]  {
        var stringArray = [String]()
        switch array.count {
        case 7:
            stringArray = fullArray(array: array, timePoints: ["03:00", "12:00", "21:00"], index1: 0, index2: 3, index3: 6)
        case 6:
            stringArray = fullArray(array: array, timePoints: ["06:00", "12:00", "21:00"], index1: 0, index2: 2, index3: 5)
        case 5:
            stringArray = fullArray(array: array, timePoints: ["09:00", "15:00", "21:00"], index1: 0, index2: 2, index3: 4)
        case 4:
            stringArray = fullArray(array: array, timePoints: ["12:00", "18:00", "21:00"], index1: 0, index2: 2, index3: 3)
        case 3:
            stringArray = fullArray(array: array, timePoints: ["15:00", "18:00", "21:00"], index1: 0, index2: 1, index3: 2)
        case 2:
            stringArray = fullArray(array: array, timePoints: ["-", "18:00", "21:00"], index1: nil, index2: 0, index3: 1)
        case 1:
            stringArray = fullArray(array: array, timePoints: ["-", "-", "21:00"], index1: nil, index2: nil, index3: 0)
        default:
            break
        }
        return stringArray
    }
    
    
    private func endArray(array: [List]) -> [String] {
        var stringArray = [String]()
        switch array.count {
        case 7:
            stringArray = fullArray(array: array, timePoints: ["03:00", "12:00", "18:00"], index1: 1, index2: 4, index3: 6)
        case 6:
            stringArray = fullArray(array: array, timePoints: ["03:00", "12:00", "-"], index1: 1, index2: 4, index3: nil)
        case 5:
            stringArray = fullArray(array: array, timePoints: ["03:00", "12:00", "-"], index1: 1, index2: 4, index3: nil)
        case 4:
            stringArray = fullArray(array: array, timePoints: ["03:00", "09:00", "-"], index1: 1, index2: 3, index3: nil)
        case 3:
            stringArray = fullArray(array: array, timePoints: ["03:00", "-", "-"], index1: 1, index2: nil, index3: nil)
        case 2:
            stringArray = fullArray(array: array, timePoints: ["03:00", "-", "-"], index1: 1, index2: nil, index3: nil)
        case 1:
            stringArray = fullArray(array: array, timePoints: ["00:00", "-", "-"], index1: 0, index2: nil, index3: nil)
        default:
            break
        }
        return stringArray
    }
    
}
