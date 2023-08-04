//
//  CitiesViewController.swift
//  project02
//
//  Created by Nimesha Jayathissa on 2023-08-01.
//

import UIKit
import CoreLocation


protocol CitiesViewControllerDelegate: AnyObject {
    func citiesViewControllerDidUpdateData(_ newData: [WeatherData])
}


class CitiesViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    

    
    
   
    
    weak var delegate: CitiesViewControllerDelegate?
    var weatherSymbolProvider: WeatherSymbolProvider?
    
    private var goBack = "goToBack"
    
   
    

       var weatherDataArray: [WeatherData] = []
    var weatherDataUpdated: (([WeatherData]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
}
    
   

    
    
    @IBAction func onBackButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: goBack, sender: self)
        weatherDataUpdated?(weatherDataArray)
          delegate?.citiesViewControllerDidUpdateData(weatherDataArray)
          self.navigationController?.popViewController(animated: true)
        tableView.reloadData()
        
      }
  }

  extension CitiesViewController: UITableViewDelegate, UITableViewDataSource {
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return weatherDataArray.count
      }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as!CustomTableViewCell

          let weatherData = weatherDataArray[indexPath.row]
          cell.locationLabel?.text = weatherData.location.name
          cell.tempLabel?.text = "\(String(format: "%.1f", weatherData.current.temp_c))°C"
          
          if let weatherSymbolProvider = weatherSymbolProvider {
                      let conditionCode = weatherData.current.condition.code
                      if let weatherSymbol = weatherSymbolProvider.weatherConditionSymbol(for: conditionCode) {
                          cell.imageView?.image = weatherSymbol
                      } else {
                          cell.imageView?.image = nil
                      }
                  } else {
                      cell.imageView?.image = nil
                  }

          return cell
      }
  }
