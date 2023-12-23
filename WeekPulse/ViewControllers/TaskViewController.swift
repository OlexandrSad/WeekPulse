//
//  TaskViewController.swift
//  WeekPulse
//
//  Created by Олександр on 24.11.2023.
//

import UIKit

class TaskViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var prioritySegment: UISegmentedControl!
    @IBOutlet weak var dedlineDatePicker: UIDatePicker!
    @IBOutlet weak var descrTextView: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    
    let maxLenghtTitle = 30
    let titlePlaceholder = "Enter task title"
    let descrPlaceholder = "1. Enter task description\n2.\n3.\n..."
 
    var counterTitleChars = 0 {
        didSet {
            countLabel.text = "\(counterTitleChars)/\(maxLenghtTitle)"
        }
    }
    
    let today = Date()
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    var dateFromVC = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        setTitleVC(date: dateFromVC)
    }
    
    
    private func setTitleVC(date: Date) {
        let weekDay = calendar.component(.weekday, from: date)
        let weekDayString = dateFormatter.weekdaySymbols[weekDay - 1]
        
        if weekDayString == "Saturday" || weekDayString == "Sunday" {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
        }
        
        dateFormatter.dateFormat = "MMMM dd"
        navigationItem.title = dateFormatter.string(from: date)
    }
        

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }

    
    func setViews() {
        titleTextField.delegate = self
        titleTextField.placeholder = titlePlaceholder
        titleTextField.clearButtonMode = .always
        
        countLabel.text = "0/\(maxLenghtTitle)"
        
        prioritySegment.selectedSegmentIndex = 2
            
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateFromVCStr = dateFormatter.string(from: dateFromVC)
        let todayStr = dateFormatter.string(from: today)
        if dateFromVCStr == todayStr {
            dedlineDatePicker.minimumDate = calendar.date(byAdding: .minute, value: 1, to: today)
        }
        dedlineDatePicker.date = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: today) ?? today
        
        descrTextView.delegate = self
        descrTextView.textColor = .lightGray
        descrTextView.text = descrPlaceholder
        descrTextView.layer.borderColor = UIColor.lightGray.cgColor
        descrTextView.layer.borderWidth = 2
        descrTextView.layer.cornerRadius = 5
        
        let tapOnClearScreen = UITapGestureRecognizer(target: self, action: #selector(hideAllKeyboard))
        view.addGestureRecognizer(tapOnClearScreen)
    }
    
    
    @objc func hideAllKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
    }
    
}


// MARK: - UITextFieldDelegate
extension TaskViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let count = textField.text?.count else { return true }
        
        if count == maxLenghtTitle {
            if string.isEmpty {
                counterTitleChars = count - 1
            } else {
                counterTitleChars = count
                return false
            }
        } else {
            counterTitleChars = string.isEmpty ? count - 1 : count + 1
        }
        
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            descrTextView.becomeFirstResponder()
        }
        return true
    }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        counterTitleChars = 0
        return true
    }
}


// MARK: - UITextViewDelegate
extension TaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == descrPlaceholder {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = descrPlaceholder
            textView.textColor = .lightGray
        }
    }
}
