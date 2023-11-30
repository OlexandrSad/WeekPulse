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
    
    let currentDate = Date()
    let calendar = Calendar.current
    
    let maxLenghtForTitleTask = 30
    let titlePlaceholder = "Enter task title"
    let descrPlaceholder = "1. Enter task description\n2.\n3.\n..."
    var dayForColorTitleVC = "Sat"
 
    var counterTitleChars = 0 {
        didSet {
            countLabel.text = "\(counterTitleChars)/\(maxLenghtForTitleTask)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        
        if dayForColorTitleVC == "Sat" || dayForColorTitleVC == "Sun" {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
        }
    }
        

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }

    
    func setViews() {
        titleTextField.delegate = self
        titleTextField.placeholder = titlePlaceholder
        titleTextField.clearButtonMode = .always
        
        countLabel.text = "0/\(maxLenghtForTitleTask)"
        
        prioritySegment.selectedSegmentIndex = 2
        
        dedlineDatePicker.minimumDate = calendar.date(byAdding: .minute, value: 5, to: currentDate)
        dedlineDatePicker.date = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: currentDate) ?? currentDate
        
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
        
        if count == maxLenghtForTitleTask {
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
            textField.resignFirstResponder()
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
