//
//  TaskViewController.swift
//  WeekPulse
//
//  Created by Олександр on 24.11.2023.
//

import UIKit

class TaskViewController: UIViewController, ToTaskVCProtocol {

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
    var task: TaskEntity?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews(task: task)
        setTitleVC(date: dateFromVC)
        
        let tapOnClearScreen = UITapGestureRecognizer(target: self, action: #selector(hideAllKeyboard))
        view.addGestureRecognizer(tapOnClearScreen)
    }

    
    func setViews(task: TaskEntity?) {
        titleTextField.delegate = self
        titleTextField.clearButtonMode = .always
        descrTextView.delegate = self
        descrTextView.layer.borderColor = UIColor.lightGray.cgColor
        descrTextView.layer.borderWidth = 2
        descrTextView.layer.cornerRadius = 5
        
        if let task = task {
            guard let count = task.title?.count, let date = task.dedline else { return }
            titleTextField.text = task.title
            countLabel.text = "\(count)/\(maxLenghtTitle)"
            prioritySegment.selectedSegmentIndex = Int(task.priority)
            dedlineDatePicker.setDate(date, animated: true)
            descrTextView.text = task.descript
        } else {
            titleTextField.placeholder = titlePlaceholder
            countLabel.text = "0/\(maxLenghtTitle)"
            prioritySegment.selectedSegmentIndex = 2
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let dateFromVCStr = dateFormatter.string(from: dateFromVC)
            let todayStr = dateFormatter.string(from: today)
            if dateFromVCStr == todayStr {
                dedlineDatePicker.minimumDate = calendar.date(byAdding: .minute, value: 5, to: today)
            }
            dedlineDatePicker.date = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: dateFromVC) ?? today
            descrTextView.textColor = .lightGray
            descrTextView.text = descrPlaceholder
        }
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    
    @objc func hideAllKeyboard() {
        view.endEditing(true)
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
    
    
    private func alertNoTitle() {
        let alert = UIAlertController(title: "Error", message: "Please enter task title", preferredStyle: .alert)
        titleTextField.layer.cornerRadius = 5
        titleTextField.layer.borderWidth = 2
        titleTextField.layer.borderColor = UIColor.red.cgColor
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.titleTextField.layer.borderWidth = 0
            alert.dismiss(animated: true)
        }
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        guard let title = titleTextField.text, title != "" else { alertNoTitle()
            return }
        
        let priority = prioritySegment.selectedSegmentIndex
        let date = dedlineDatePicker.date
        var desctipt = ""
        
        if descrTextView.text != descrPlaceholder, !descrTextView.text.isEmpty {
            desctipt = descrTextView.text
        }
        
        let alert = UIAlertController(title: "Save task", message: "Are you sure?", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        let actionOK = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            CoreDataManager.shared.UpdateOrCreateTask(title: title,
                                                      ptiority: priority,
                                                      dedline: date,
                                                      descript: desctipt,
                                                      taskEntity: self?.task)
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(actionCancel)
        alert.addAction(actionOK)
        self.present(alert, animated: true)
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
