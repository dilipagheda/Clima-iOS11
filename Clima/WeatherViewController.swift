//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController , CLLocationManagerDelegate, ChangeCityViewControllerDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "faf86c7996440252fc1748e7fa68c63b"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherData = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
    
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String, params:[String:String]){
        Alamofire.request(url,method:.get, parameters:params).validate().responseJSON { response in
            switch response.result {
            case .success:
                    let weatherData : JSON = JSON(response.result.value!)
                    self.updateWeatherData(json:weatherData)
            case .failure(let error):
                    print(error)
                    self.cityLabel.text = "Connection Issues!"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON) {
        
        if let temp = json["main"]["temp"].double {
            weatherData.temperature = Int(temp - 273.15)
            weatherData.city = json["name"].stringValue
            weatherData.condition = json["weather"][0]["id"].intValue
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition)
            
            //update UI
            updateUIWithWeatherData()
        }else {
            cityLabel.text = "Weather unavailable!"

        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        temperatureLabel.text = "\(weatherData.temperature)°"
        cityLabel.text = weatherData.city
        weatherIcon.image = UIImage(named: weatherData.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate=nil
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            print("latitude:\(latitude) longitude:\(longitude)")
            //get weather data now using above coordinates
            let parameters : [String:String] = ["lat":latitude, "lon":longitude, "appid":APP_ID]
            getWeatherData(url:WEATHER_URL, params:parameters)
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable!"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city:String){
        cityLabel.text = city
        
        //get weather data for this city
        let params:[String:String] = ["q":city, "appid":APP_ID]
        getWeatherData(url: WEATHER_URL, params: params)
      
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let changeCityVC = segue.destination as! ChangeCityViewController
            changeCityVC.delegate = self
        }
    }
    
    
    
    
}


