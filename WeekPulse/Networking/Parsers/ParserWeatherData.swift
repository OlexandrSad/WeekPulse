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
            
            timeLeftLabel.text = stringsArray[0][0]
            tempLeftLabel.text = stringsArray[0][1]
            windLeftLabel.text = stringsArray[0][2]
            leftImageView.image = UIImage(named: stringsArray[0][3])
            
            timeCentrLabel.text = stringsArray[1][0]
            tempCentrLabel.text = stringsArray[1][1]
            windCentrLabel.text = stringsArray[1][2]
            centrImageView.image = UIImage(named: stringsArray[1][3])
            
            timeRightLabel.text = stringsArray[2][0]
            tempRightLabel.text = stringsArray[2][1]
            windRightLabel.text = stringsArray[2][2]
            rightImageView.image = UIImage(named: stringsArray[2][3])
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
                }
                arrays[count].append(element)
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
    
    
    private func createStringArray(array: [List], indexInArrays: Int, arraysCount: Int) -> [[String]] {
        var stringArray = [[String]]()
        
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
    
    
    private func fullArray(array: [List], timePoints: [String], index1: Int?, index2: Int?, index3: Int?) -> [[String]] {
        var arrays = [[String]]()
        let indexes = [index1, index2, index3]
        for (index, value) in indexes.enumerated() {
            var stringArray = [String]()
            let temp = value != nil ? array[value!].main?.temp : nil
            let wind = value != nil ? array[value!].wind?.speed : nil
            let icon = value != nil ? array[value!].weather?[0].icon : nil
            let cond = value != nil ? array[value!].weather?[0].description : nil
            
            stringArray.append(timePoints[index])
            stringArray.append(value != nil ? String(format: "%.1f", temp!) : "-")
            stringArray.append(value != nil ? String(wind!) : "-")
            stringArray.append(value != nil ? String(icon!) : "-")
            stringArray.append(value != nil ? String(cond!) : "-")
            arrays.append(stringArray)
        }
        return arrays
    }
    
    
    private func startArray(array: [List]) -> [[String]]  {
        var stringArray = [[String]]()
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
    
    
    private func endArray(array: [List]) -> [[String]] {
        var stringArray = [[String]]()
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
    
    
    func arrayForWeatherVC(weatherData: WeatherData) -> [[String: [[String]]]] {
        var arrayDict = [[String: [[String]]]]()
        let arrays = createArrays(weatherData: weatherData)
        for (index, array) in arrays.enumerated() {
            let date = String(arrays[index].first?.date?.prefix(10) ?? "")
            var stringsArray = createStringArray(array: array, indexInArrays: index, arraysCount: arrays.count)
            for (index, element) in stringsArray.enumerated() {
                if element[0] == "-" {
                    stringsArray.remove(at: index)
                }
            }
            arrayDict.append([date: stringsArray])
        }
        return arrayDict
    }
    
}
