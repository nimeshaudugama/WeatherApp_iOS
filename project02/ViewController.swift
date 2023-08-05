//
//  ViewController.swift
//  project02
//
//  Created by Nimesha Jayathissa on 2023-07-26.
//
import CoreLocation
import UIKit

protocol WeatherSymbolProvider {
    func weatherConditionSymbol(for code: Int) -> UIImage?
}




class ViewController: UIViewController,CLLocationManagerDelegate,WeatherSymbolProvider,UITextFieldDelegate {
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var labelWeather: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var temperatureToggleSwitch: UISegmentedControl!
    
    @IBOutlet weak var labelWeatherText: UILabel!
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    
    @IBOutlet weak var WeatherImage: UIImageView!
    
    var weatherDataArray: [WeatherData] = []

    
    
    private let citiesSegue = "goToCities"
    
    
    var locationManager: CLLocationManager!
    
    var isCelsiusSelected = true
    var weatherData: WeatherData?


   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
       
        temperatureToggleSwitch.selectedSegmentIndex = 0
        searchTextField.delegate = self
        
        
    }
    
    







    
    
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            checkLocationAuthorization()
        }
    
    func checkLocationAuthorization() {

        
        let status = locationManager.authorizationStatus
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    // Location services are authorized, enable the location button
                    locationButton.isEnabled = true
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                case .denied, .restricted:
                   
                    locationButton.isEnabled = false
                @unknown default:
                    break
                }
    }
    
    
    
    
    func startUpdatingLocation() {
            locationManager.startUpdatingLocation()
        }


    @IBAction func onLocationTapped(_ sender: UIButton) {
        
        checkLocationAuthorization()
//               if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
//                    startUpdatingLocation()
//                }
        
        
        
        let status = locationManager.authorizationStatus
           switch status {
           case .authorizedWhenInUse, .authorizedAlways:
               // Location services are authorized, enable the location button
               locationButton.isEnabled = true
               startUpdatingLocation()
           case .notDetermined:
               locationManager.requestWhenInUseAuthorization()
           case .denied, .restricted:
               
               locationButton.isEnabled = false
           @unknown default:
               break
           }
    }
    
    

    func weatherConditionSymbol(for code: Int) -> UIImage? {
        // Define the colors you want to use
        let colors: [UIColor] = [.white , .systemYellow]

        // Create a symbol configuration with the desired colors
        let config = UIImage.SymbolConfiguration(paletteColors: colors)

        switch code {
        case 1003: // Partly Cloudy
            // Set the preferred symbol configuration for the specific SF Symbol
            return UIImage(systemName: "cloud.sun.fill")?.withConfiguration(config)
        case 1009: // Overcast
            return UIImage(systemName: "smoke.fill")?.withConfiguration(config)
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246: // Rain
            return UIImage(systemName: "cloud.rain.fill")?.withConfiguration(config)
        case 1030: // Mist
            return UIImage(systemName: "aqi.medium")?.withConfiguration(config)
        case 1135: // Fog
            return UIImage(systemName: "humidity")?.withConfiguration(config)
        case 1000: // Sunny
            return UIImage(systemName: "sun.max.fill")?.withConfiguration(config)
        // Add more cases for other weather conditions
        default:
            return nil
        }
    }

      


    
    
    
    func reverseGeocodeLocation(latitude: Double, longitude: Double) {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: latitude, longitude: longitude)

            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Reverse geocoding error: \(error.localizedDescription)")
                    return
                }

                if let placemark = placemarks?.first {
                    if let city = placemark.locality, let country = placemark.country {
                        // Update the locationLabel with the current location name
                        self.locationLabel.text = "\(city), \(country)"
                    }
                }
            }
        }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            // Get the user's current location
            if let location = locations.last {
                // Stop updating the location to save battery
                locationManager.stopUpdatingLocation()

                // Fetch weather data for the current location using latitude and longitude
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                print("Received location update: Lat: \(latitude), Lon: \(longitude)")
                
                // Reverse geocode the location to get the location name
                reverseGeocodeLocation(latitude: latitude, longitude: longitude)
                fetchWeatherData(latitude: latitude, longitude: longitude)
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                // Location services have been authorized, enable the location button
                locationButton.isEnabled = true
            } else {
                // Location services have been denied, disable the location button
                locationButton.isEnabled = false
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           // Handle any location errors
       
           print("Location error: \(error.localizedDescription)")
       }


   


    @IBAction func onTempratureToggle(_ sender: UISegmentedControl) {
    
    
//        isCelsiusSelected = (sender.selectedSegmentIndex == 0)
//
//                if let weatherData = weatherData {
//                    let temperature = isCelsiusSelected ? weatherData.current.temp_c : weatherData.current.temp_f
//                    let temperatureString = String(format: "%.1f", temperature)
//                    let unitSymbol = isCelsiusSelected ? "°C" : "°F"
//                    labelWeather.text = "\(temperatureString) \(unitSymbol)"
//                }
//            }
        
        isCelsiusSelected = (sender.selectedSegmentIndex == 0)

          if let weatherData = weatherData {
              let temperature = isCelsiusSelected ? weatherData.current.temp_c : weatherData.current.temp_f
              let temperatureString = String(format: "%.1f", temperature)
              let unitSymbol = isCelsiusSelected ? "°C" : "°F"
              
              // Perform UI updates on the main thread
              DispatchQueue.main.async {
                  self.labelWeather.text = "\(temperatureString) \(unitSymbol)"
              }
          }
      }
    
   
    
    
   
    
    
    
    @IBAction func onCitiesButtonTapped(_ sender: UIButton) {
        
        
        
        
       // performSegue(withIdentifier: "goToCities", sender: self)
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if needed
           if let citiesVC = storyboard.instantiateViewController(withIdentifier: "CitiesViewController") as? CitiesViewController {
               citiesVC.delegate = self
               citiesVC.weatherDataArray = weatherDataArray
               citiesVC.weatherSymbolProvider = self
               
               // Push the CitiesViewController onto the navigation stack
               self.navigationController?.pushViewController(citiesVC, animated: true)
           }
         
        
    }
//

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToCities" {
                if let citiesVC = segue.destination as? CitiesViewController {
                    citiesVC.delegate = self
                    citiesVC.weatherDataArray = weatherDataArray
                    citiesVC.weatherSymbolProvider = self
                }
            }
        }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hide the keyboard
        // Call your search function here
        performSearch()
        return true
    }


    
    @IBAction func onSearchButtonTapped(_ sender: UIButton) {
        performSearch()
        
        searchTextField.text = ""
        
    }
    
    
        func performSearch (){
        
        if let location = searchTextField.text, !location.isEmpty {
            locationLabel.text=location
            
//            let newCity = WeatherData(location: Location(name: location, region: "", country: "", lat: 0, lon: 0, tz_id: "", localtime_epoch: 0, localtime: ""), current: Current(temp_c: 1, temp_f: 0, condition: WeatherCondition(text: "", icon: "",code: 0))) // You might need to set other properties based on your data structure
            
//            let newCity = WeatherData(location: Location(name: location, region: "", country: "", lat: 0, lon: 0, tz_id: "", localtime_epoch: 0, localtime: ""), current: nil)
//            weatherDataArray.append(newCity)
//            searchTextField.text = ""
    
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(location) { [weak self] (placemarks, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    return
                }
                
               
                if let placemark = placemarks?.first, let latitude = placemark.location?.coordinate.latitude, let longitude = placemark.location?.coordinate.longitude {
                    self.fetchWeatherData(latitude: latitude, longitude: longitude)
                    
                } else {
                 
                    print("No location found for the entered text")
                    
                    if let clError = error as? CLError, clError.code == .geocodeFoundNoResult {
                            let alertController = UIAlertController(title: "Error", message: "No location found for the entered text.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            present(alertController, animated: true, completion: nil)
                    }}
            }
        } else {
         
        }
    }
    

   
    
    
    
        func fetchWeatherData(latitude: Double, longitude: Double) {
            
            let apiKey = "49522dd53ff94e11a7f235942232607"
            let apiUrl = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(latitude),\(longitude)"
            
            
               if let url = URL(string: apiUrl) {
                  
                   let task = URLSession.shared.dataTask(with: url) { data, response, error in
                       
                       if let error = error {
                           print("Error fetching weather data: \(error.localizedDescription)")
                           return
                       }

                       // Check if data is available
                       guard let data = data else {
                           print("No data received")
                           return
                       }

                       do {
                           // Decode the JSON data into a dictionary using JSONDecoder
                           let jsonDecoder = JSONDecoder()
                          // jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                           let weatherData = try jsonDecoder.decode(WeatherData.self, from: data)
                           self.weatherData = weatherData
                           self.weatherDataArray.append(weatherData)
                       
                           // Update the temperature label based on the default temperature unit (Celsius by default)
                           self.onTempratureToggle(self.temperatureToggleSwitch)
                           
                           let weatherConditionCode = weatherData.current.condition.code
                           
                           if let weatherSymbol = self.weatherConditionSymbol(for: weatherConditionCode) {
                                                   // Update the weatherImageView on the main thread
            DispatchQueue.main.async {
                                                       self.WeatherImage.image = weatherSymbol
                                                   }
                                               } else {
                                                   // If no symbol is found for the weather condition code, you can set a default image
                                                   // For example:
                                                   // self.weatherImageView.image = UIImage(systemName: "questionmark.circle.fill")
                                               }


                           // Access the weather description from the weatherData object
                           let weatherDescription = weatherData.current.condition.text
                           
                           let weatherTempareature = String (format: "%.1f",weatherData.current.temp_c)
                               // Update the label on the main thread
                               DispatchQueue.main.async {
                                   self.labelWeatherText.text = weatherDescription
                                   
                                   //self.labelWeather.text = weatherTempareature
                                   
                                   
                               }
                           
                       } catch {
                           print("Error decoding weather data: \(error.localizedDescription)")
                       }
                   }

                   // Start the URLSession task
                   task.resume()
               }
            
            
            
           
            
            
            
        }

}


extension ViewController: CitiesViewControllerDelegate {
    func citiesViewControllerDidUpdateData(_ newData: [WeatherData]) {
        weatherDataArray = newData
        //tableView.reloadData()
        
        
    }
}


