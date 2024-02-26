//
//  TaskViewController.swift
//  WeekPulse
//
//  Created by Олександр on 24.11.2023.
//

import UIKit

final class TaskViewController: UIViewController, ToTaskVCProtocol {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var prioritySegment: UISegmentedControl!
    @IBOutlet weak var dedlineDatePicker: UIDatePicker!
    @IBOutlet weak var descrTextView: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherStack: UIStackView!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var timeCentrLabel: UILabel!
    @IBOutlet weak var timeRightLabel: UILabel!
    @IBOutlet weak var tempLeftLabel: UILabel!
    @IBOutlet weak var tempCentrLabel: UILabel!
    @IBOutlet weak var tempRightLabel: UILabel!
    @IBOutlet weak var windLeftLabel: UILabel!
    @IBOutlet weak var windCentrLabel: UILabel!
    @IBOutlet weak var windRightLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var centrImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    let maxLenghtTitle = 40
    let titlePlaceholder = "Enter task title"
    let descrPlaceholder = "1. Enter task description\n2.\n3.\n..."
    let colorPriority: [UIColor] = [.green, .yellow, .red]
    let today = Date()
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    let networkManger = NetworkManager.shared
    let settings = CoreDataManager.shared.getSettings()
    
    var dateFromVC: Date?
    var task: TaskEntity?
    var whoCreated: String?
    var town: String?
    var latitude: String?
    var longitude: String?
    var counterTitleChars = 0 {
        didSet {
            countLabel.text = "\(counterTitleChars)/\(maxLenghtTitle)"
        }
    }
    
    
// MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setWeatherSettings()
        setTitleTF(textField: titleTextField, task: task)
        setDescrTV(textView: descrTextView, task: task)
        setCountLabel(label: countLabel, task: task)
        setPriority(segment: prioritySegment, task: task)
        setPicker(picker: dedlineDatePicker, task: task, date: dateFromVC, today: today)
        removeWeather(task: task, date: dateFromVC, textView: descrTextView, label: weatherLabel, stack: weatherStack)
        setTitleVC(date: dateFromVC)
        setWeather(lat: latitude, lon: longitude)
        
        let tapOnClearScreen = UITapGestureRecognizer(target: self, action: #selector(hideAllKeyboard))
        view.addGestureRecognizer(tapOnClearScreen)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if settings?.showWeath == true, settings?.showFirst == 0 {
            titleTextField.becomeFirstResponder()
        } else if settings?.showWeath == false {
            titleTextField.becomeFirstResponder()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    
// MARK: Set functions
    private func setWeatherSettings() {
        town = settings?.town
        latitude = settings?.lat
        longitude = settings?.lon
    }
    
    
    private func setTitleTF(textField: UITextField, task: TaskEntity?) {
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
    
    
    private func setPicker(picker: UIDatePicker, task: TaskEntity?, date: Date?, today: Date) {
        if let task = task, let dedline = task.dedline {
            dedlineDatePicker.setDate(dedline, animated: true)
            
            if whoCreated == "AllTasksViewControllerID" {
                dedlineDatePicker.datePickerMode = .dateAndTime
            }
            picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
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
    
    
    private func setWeather(lat: String?, lon: String?) {
        
        guard let lat = lat, let lon = lon, let town = town else { return }
        networkManger.fetchWeatherData(lat: lat, lon: lon) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let weatherData):
                guard let dateFromVC = self.dateFromVC, self.weatherStack != nil else { return }
                ParserWeatherData().setViews(weatherData: weatherData, weatherLabel: self.weatherLabel, town: town, dayVC: dateFromVC,
                                             timeLeftLabel: self.timeLeftLabel, timeCentrLabel: self.timeCentrLabel, timeRightLabel: self.timeRightLabel,
                                             tempLeftLabel: self.tempLeftLabel, tempCentrLabel: self.tempCentrLabel, tempRightLabel: self.tempRightLabel,
                                             windLeftLabel: self.windLeftLabel, windCentrLabel: self.windCentrLabel, windRightLabel: self.windRightLabel,
                                             leftImageView: self.leftImageView, centrImageView: self.centrImageView, rightImageView: self.rightImageView)
            case .failure(let error):
                print(error)
            }
        }
    }

    
// MARK: Remove weather
    private func removeWeather(task: TaskEntity?, date: Date?, textView: UITextView?, label: UILabel, stack: UIStackView) {
        
        guard settings?.showWeath == true else {removeViews(textView: textView, label: label, stack: stack)
            return }
        if let task = task, let dedline = task.dedline {
            let components = calendar.dateComponents([.year, .month, .day], from: Date())
            let startToday = calendar.date(from: components) ?? Date()
            let plusSevenDays = calendar.date(byAdding: .day, value: 7, to: startToday)
            
            if let plusSeven = plusSevenDays, plusSeven < dedline {
                removeViews(textView: textView, label: label, stack: stack)
            }
        } else {
            
            if date == nil {
                removeViews(textView: textView, label: label, stack: stack)
            }
        }
    }
    
    
    private func removeViews(textView: UITextView?, label: UILabel, stack: UIStackView) {
        stack.removeFromSuperview()
        label.removeFromSuperview()
        
        if let descrTextView = textView {
            let newConstraint = NSLayoutConstraint(item: descrTextView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -100)
            newConstraint.isActive = true
        }
    }
    
    
// MARK: @objc functions
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        sender.selectedSegmentTintColor = colorPriority[sender.selectedSegmentIndex]
    }
    
    
    @objc func hideAllKeyboard() {
        view.endEditing(true)
    }
    
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let currentDate = Date()
        
        if sender.date < currentDate {
            let newDate = currentDate.addingTimeInterval(5 * 60)
            dedlineDatePicker.setDate(newDate, animated: true)
        }
    }

    
// MARK: Alerts
    private func alertNoTitle(view: UIView) {
        let animator = Animator()
        let alert = UIAlertController(title: "Error", message: "Please enter task title", preferredStyle: .alert)
        
        present(alert, animated: true)
        animator.shakeAnimation(view: view)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
    
    
    private func saveAlert() {
        let alert = UIAlertController(title: "Save task", message: "Are you sure?", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        let actionOK = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.saveTaskAndSetNotification()
        }
        alert.addAction(actionCancel)
        alert.addAction(actionOK)
        self.present(alert, animated: true)
    }
    
    
// MARK: Save task
    private func saveTaskAndSetNotification() {
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
        
        let taskForNotification = CoreDataManager.shared.UpdateOrCreateTask(title: title, ptiority: priority, dedline: date,
                                                                            dedlineStr: dedlineStr, descript: desctipt, taskEntity: self.task)
        
        if let task = taskForNotification {
            NotificationManager.shared.setNotification(for: task)
        }
        self.navigationController?.popViewController(animated: true)
    }

    
// MARK: Actions
    @IBAction func saveButton(_ sender: Any) {
        saveAlert()
    }
    
    
    @IBAction func searchTownButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let townVC = storyboard.instantiateViewController(withIdentifier: "SearchTownVC") as! SearchTownViewController
       
        townVC.town = weatherLabel.text
        townVC.complitionHundler = {[weak self] updatedTown in
            let townKey = updatedTown.keys.first!
            self?.town = townKey
            if let coordinate = updatedTown[townKey] {
                self?.latitude = coordinate[0]
                self?.longitude = coordinate[1]
                self?.setWeather(lat: coordinate[0], lon: coordinate[1])
            }
        }
        present(townVC, animated: true)
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
