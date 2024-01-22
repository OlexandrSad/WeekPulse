//
//  SearchTownViewController.swift
//  WeekPulse
//
//  Created by Олександр on 21.01.2024.
//

import UIKit

class SearchTownViewController: UIViewController {
    
    @IBOutlet weak var fullLocation: UILabel!
    @IBOutlet weak var townTextField: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    let networkManager = NetworkManager.shared
    var complitionHundler: (([String: [String]]) -> Void)?
    var onlyNameArray = [String]()
    
    var townsDict = [String: [String]]() {
        didSet {
            onlyNameArray.removeAll()
            for name in townsDict.keys {
                onlyNameArray.append(name)
            }
            DispatchQueue.main.async { [weak self] in
                self?.searchResultsTableView.reloadData()
            }
        }
    }
    
    var town: String? {
        didSet {
            searchTown(town: town)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
       
        townTextField.delegate = self
        
        fullLocation.text = town
        if let town = town, let onlyTownIndex = town.firstIndex(of: ",") {
            let onlyTown = String(town.prefix(upTo: onlyTownIndex))
            townTextField.text = onlyTown
        }
    }
    
    
    private func searchTown(town: String?) {
        if let town = town, !town.isEmpty {
            
            networkManager.fetchTownData(town: town) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let townModel):
                    self.townsDict = ParserTownData().createTownsArray(townModel: townModel)
                case .failure(let error):
                    if let networkingError = error as? NetworkingError, networkingError == .noInternet {
                        DispatchQueue.main.async {
                            self.alertNoInternet()
                        }
                    }
                    print(error)
                }
            }
        }
    }
    
    
    private func alertNoInternet() {
        let alert = UIAlertController(title: "Error", message: "There is no internet", preferredStyle: .alert)
        
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            alert.dismiss(animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stringTown = onlyNameArray[indexPath.row]
        
        if let coordinates = townsDict[stringTown] {
            complitionHundler?([stringTown: coordinates])
        }
        self.dismiss(animated: true)
    }
    
}


extension SearchTownViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        townsDict.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "📌 \(onlyNameArray[indexPath.row])"
        return cell
    }
    
}


extension SearchTownViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == townTextField, let text = textField.text {
            if !text.isEmpty {
                town = textField.text
            } else {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 3
                Animator().shakeAnimation(view: textField)
                town = textField.text
            }
        }
        return true
    }
    
}
