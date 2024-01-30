//
//  SettingsViewController.swift
//  WeekPulse
//
//  Created by Олександр on 29.01.2024.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var notifyPicker: UIPickerView!
    @IBOutlet weak var showWeatherLabel: UILabel!
    @IBOutlet weak var showWeatherSwitch: UISwitch!
    @IBOutlet weak var townConstLabel: UILabel!
    @IBOutlet weak var townLabel: UILabel!
    @IBOutlet weak var showFirstLabel: UILabel!
    @IBOutlet weak var showFirstSegment: UISegmentedControl!
    
    var settings = CoreDataManager.shared.getSettings()
    var latitude: String?
    var longitude: String?
    var minutes: Int?
    let coreDataManager = CoreDataManager.shared
    let firstSegment = "Keyboard"
    let secondSegment = "Weather"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
        setSegment(segment: showFirstSegment)
        
        townLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(townTapped(_:)))
        townLabel.addGestureRecognizer(tapGesture)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setViews(settings: settings)
    }
    
    
    @objc private func townTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let townVC = storyboard.instantiateViewController(withIdentifier: "SearchTownVC") as! SearchTownViewController
       
        townVC.town = townLabel.text
        townVC.complitionHundler = {[weak self] updatedTown in
            let townKey = updatedTown.keys.first!
            self?.townLabel.text = townKey
            if let coordinate = updatedTown[townKey] {
                self?.latitude = coordinate[0]
                self?.longitude = coordinate[1]
            }
        }
        present(townVC, animated: true)
    }
    
    
    private func setLabels() {
        navigationItem.title = "Settings"
        notifyLabel.text = "Dedline notifications before (minutes)"
        showWeatherLabel.text = "Show the weather?"
        townConstLabel.text = "Town"
        showFirstLabel.text = "Show first"
    }
    
    
    private func setViews(settings: SettingsEntity?) {
        guard let settings = settings else { return }
        notifyPicker.delegate = self
        notifyPicker.dataSource = self
       
        let minits = Int(settings.minutes)
        minutes = minits
        notifyPicker.selectRow(minits - 1, inComponent: 0, animated: false)
        
        showWeatherSwitch.isOn = settings.showWeath
        if !showWeatherSwitch.isOn {
            townLabel.alpha = 0
            townConstLabel.alpha = 0
            showFirstLabel.alpha = 0
            showFirstSegment.alpha = 0
        }
        
        townLabel.text = settings.town
        townLabel.layer.borderColor = UIColor.lightGray.cgColor
        townLabel.layer.borderWidth = 1
        townLabel.layer.cornerRadius = 5
        
        showFirstSegment.selectedSegmentIndex = Int(settings.showFirst)
        
        latitude = settings.lat
        longitude = settings.lon
    }
    
    
    private func setSegment(segment: UISegmentedControl) {
        segment.selectedSegmentIndex = 0
        segment.setTitle(firstSegment, forSegmentAt: 0)
        segment.setTitle(secondSegment, forSegmentAt: 1)
    }
    
    
    @IBAction func switchAction(_ sender: UISwitch) {
        if !sender.isOn {
            townLabel.alpha = 0
            townConstLabel.alpha = 0
            showFirstLabel.alpha = 0
            showFirstSegment.alpha = 0
        } else {
            townLabel.alpha = 1
            townConstLabel.alpha = 1
            showFirstLabel.alpha = 1
            showFirstSegment.alpha = 1
        }
    }
    
    
    private func saveAlert() {
        let alert = UIAlertController(title: "Save Settings", message: "Are you sure?", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        let actionOK = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.saveNewSettings()
        }
        alert.addAction(actionCancel)
        alert.addAction(actionOK)
        self.present(alert, animated: true)
    }
    
    
    private func saveNewSettings() {
        guard let town = townLabel.text,
              let lat = latitude,
              let lon = longitude,
              let minutes = minutes
        else { return }

        coreDataManager.saveSettings(minutes: minutes, showWeath: showWeatherSwitch.isOn, town: town,
                                     lat: lat, lon: lon, shosFirst: showFirstSegment.selectedSegmentIndex)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        saveAlert()
    }
    
}


extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        minutes = row + 1
    }
    
}
