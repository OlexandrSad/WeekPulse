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
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherView: UIView!
    
    let maxLenghtTitle = 40
    let titlePlaceholder = "Enter task title"
    let descrPlaceholder = "1. Enter task description\n2.\n3.\n..."
    let colorPriority: [UIColor] = [.green, .yellow, .red]
 
    var counterTitleChars = 0 {
        didSet {
            countLabel.text = "\(counterTitleChars)/\(maxLenghtTitle)"
        }
    }
    
    let today = Date()
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    var dateFromVC: Date?
    var task: TaskEntity?
    var whoCreated: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleTF(textField: titleTextField, task: task)
        setDescrTV(textView: descrTextView, task: task)
        setCountLabel(label: countLabel, task: task)
        setPriority(segment: prioritySegment, task: task)
        setPicker(picker: dedlineDatePicker, task: task, date: dateFromVC, today: today)
        removeWeather(task: task, date: dateFromVC, textView: descrTextView, label: weatherLabel, view: weatherView)
        setTitleVC(date: dateFromVC)
        
        let tapOnClearScreen = UITapGestureRecognizer(target: self, action: #selector(hideAllKeyboard))
        view.addGestureRecognizer(tapOnClearScreen)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    
    @objc func hideAllKeyboard() {
        view.endEditing(true)
    }
    
    
    private func setTitleTF(textField: UITextField, task: TaskEntity?) {
        textField.becomeFirstResponder()
        textField.delegate = self
        textField.clearButtonMode = .always
        
        if let task = task {
            textField.text = task.title
        } else {
            textField.placeholder = titlePlaceholder
        }
    }
    
    
    private func setDescrTV(textView: UITextView, task: TaskEntity?) {
        textView.delegate = self
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 2
        textView.layer.cornerRadius = 5
        
        if let task = task {
            descrTextView.text = task.descript
        } else {
            descrTextView.textColor = .lightGray
            descrTextView.text = descrPlaceholder
        }
    }
    
    
    private func setCountLabel(label: UILabel, task: TaskEntity?) {
        if let task = task, let count = task.title?.count {
            label.text = "\(count)/\(maxLenghtTitle)"
        } else {
            label.text = "0/\(maxLenghtTitle)"
        }
    }
    
    
    private func setPriority(segment: UISegmentedControl, task: TaskEntity?) {
        if let task = task {
            segment.selectedSegmentIndex = Int(task.priority)
        } else {
            segment.selectedSegmentIndex = 2
        }
        segment.selectedSegmentTintColor = colorPriority[segment.selectedSegmentIndex]
        segment.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        sender.selectedSegmentTintColor = colorPriority[sender.selectedSegmentIndex]
    }
    
    
    private func setPicker(picker: UIDatePicker, task: TaskEntity?, date: Date?, today: Date) {
        if let task = task, let dedline = task.dedline {
            dedlineDatePicker.setDate(dedline, animated: true)
            
            if whoCreated == "AllTasksViewControllerID" {
                dedlineDatePicker.datePickerMode = .dateAndTime
                dedlineDatePicker.minimumDate = calendar.date(byAdding: .minute, value: 5, to: today)
            }
        } else {
            
            if let date = date {
                dateFormatter.dateFormat = "YYYY-MM-dd"
                let dateFromVCStr = dateFormatter.string(from: date)
                let todayStr = dateFormatter.string(from: today)
                
                if dateFromVCStr == todayStr {
                    dedlineDatePicker.minimumDate = calendar.date(byAdding: .minute, value: 5, to: today)
                }
                
                dedlineDatePicker.date = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: date) ?? today
            } else {
                dedlineDatePicker.datePickerMode = .dateAndTime
                let components = calendar.dateComponents([.year, .month, .day], from: today)
                
                if let startOfDay = calendar.date(from: components) {
                    dedlineDatePicker.minimumDate = calendar.date(byAdding: .day, value: 7, to: startOfDay)
                }
            }
        }
    }

    
    private func removeWeather(task: TaskEntity?, date: Date?, textView: UITextView?, label: UILabel, view: UIView) {
        if let task = task, let dedline = task.dedline {
            let components = calendar.dateComponents([.year, .month, .day], from: Date())
            let startToday = calendar.date(from: components) ?? Date()
            let plusSevenDays = calendar.date(byAdding: .day, value: 7, to: startToday)
            
            if let plusSeven = plusSevenDays, plusSeven < dedline {
                removeViews(textView: textView, label: label, view: view)
            }
        } else {
            
            if date == nil {
                removeViews(textView: textView, label: label, view: view)
            }
        }
    }
    
    
    private func removeViews(textView: UITextView?, label: UILabel, view: UIView) {
        view.removeFromSuperview()
        label.removeFromSuperview()
        
        if let descrTextView = textView {
            let newConstraint = NSLayoutConstraint(item: descrTextView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -100)
            newConstraint.isActive = true
        }
    }
    
    
    private func setTitleVC(date: Date?) {
        guard let date = date else { return }
        
        let weekDay = calendar.component(.weekday, from: date)
        let weekDayString = dateFormatter.weekdaySymbols[weekDay - 1]

        if weekDayString == "Saturday" || weekDayString == "Sunday" {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
        }
        
        dateFormatter.dateFormat = "MMMM dd"
        navigationItem.title = dateFormatter.string(from: date)
    }
    
    
    private func alertNoTitle(view: UIView) {
        let animator = Animator()
        let alert = UIAlertController(title: "Error", message: "Please enter task title", preferredStyle: .alert)
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.red.cgColor
        present(alert, animated: true)
        animator.shakeAnimation(view: view)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            view.layer.borderWidth = 0
            alert.dismiss(animated: true)
        }
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        guard let title = titleTextField.text, title != "" else { alertNoTitle(view: titleTextField)
            return }
        
        let priority = prioritySegment.selectedSegmentIndex
        let date = dedlineDatePicker.date
        dateFormatter.dateFormat = "YYYY-MM-dd (EEEE)"
        let dedlineStr = dateFormatter.string(from: date)
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
                                                      dedlineStr: dedlineStr,
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
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text else { return true }
        
        let maxLength = 500
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= maxLength
    }
    
}
