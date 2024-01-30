//
//  WeatherViewController.swift
//  WeekPulse
//
//  Created by Олександр on 28.01.2024.
//

import UIKit

class WeatherViewController: UIViewController {

    @IBOutlet weak var weatherTable: UITableView!
    @IBOutlet weak var townLabel: UILabel!
    
    let networkManger = NetworkManager.shared
    let settings = CoreDataManager.shared.getSettings()
    var town: String?
    var latitude: String?
    var longitude: String?
    var sourseArray = [[String: [[String]]]]() {
        didSet {
            weatherTable.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setWeatherSettings()
        townLabel.text = town
        setTable()
    }
    
    
    private func setTable() {
        weatherTable.delegate = self
        weatherTable.dataSource = self
        let nib = UINib(nibName: "WeatherTableViewCell", bundle: nil)
        weatherTable.register(nib, forCellReuseIdentifier: "WeatherCell")
        createDataArray(lat: latitude, lon: longitude) {[weak self] dataArray in
            self?.sourseArray = dataArray
        }
    }
    
    
    private func setWeatherSettings() {
        town = settings?.town
        latitude = settings?.lat
        longitude = settings?.lon
    }
    
    
    private func createDataArray(lat: String?, lon: String?, completion: @escaping ([[String: [[String]]]]) -> Void) {
        guard let lat = lat, let lon = lon else { return }
        var array = [[String: [[String]]]]()
        networkManger.fetchWeatherData(lat: lat, lon: lon) { result in
            switch result {
            case .success(let weatherData):
                array = ParserWeatherData().arrayForWeatherVC(weatherData: weatherData)
                completion(array)
            case .failure(let error):
                print(error)
                completion(array)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionName = sourseArray[section].keys.first
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
        headerView.backgroundColor = UIColor.systemGray6
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.text = sectionName
        headerView.addSubview(label)
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sourseArray.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let newCount = sourseArray[section].first?.value.count {
            count = newCount
        }
        return count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = weatherTable.dequeueReusableCell(withIdentifier: "WeatherCell") as! WeatherTableViewCell
        let dict = sourseArray[indexPath.section]
        if let key = dict.keys.first {
            if let arrays = dict[key] {
                let array = arrays[indexPath.row]
                cell.setViews(array: array)
            }
            
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
