//
//  CampViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/6/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class CampViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var ExpNumText: UILabel!
    @IBOutlet weak var ExperienceText: UILabel!
    @IBOutlet weak var NameText: UILabel!
    @IBOutlet weak var EmailText: UILabel!
    @IBOutlet weak var enterSmileyButton: UIButton!
    
    //Find user location for map vew camera
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var savedLat:Double = 10101 // code to indicate the userLat and userLng has never been set
//        var savedLng:Double = 10101
        let savedLat = UserDefaults.standard.double(forKey: "userLat")
        let savedLng = UserDefaults.standard.double(forKey: "userLng")
        
        if (savedLat != 0.0) && (savedLng != 0.0) {
            currentUser.userLat = savedLat
            currentUser.userLng = savedLng
        }
        else{
            print("else")
            self.enterSmileyButton.isEnabled = false //Hold until location aquired.
        }
        
        // Request User Infomation
        requestProfileInfo(email:currentUser.email)
        
        //Present Data
        self.ExpNumText.text = currentUser.exp_id
        self.ExperienceText.text = currentUser.experience
        self.NameText.text = currentUser.name
        self.EmailText.text = currentUser.email
        
        // Request Friendlist and Places
        requestFriendList(email: currentUser.email)
        requestPlaces(email: currentUser.email, rule:"default")
        
        // Request current location
        if currentUser.needLocationUpdate == true{
            //Request user current location
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
            currentUser.needLocationUpdate = false
        }
        else{
            self.enterSmileyButton.isEnabled = true
        }
    }
    
    //Location Related Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            currentUser.userLat = location.coordinate.latitude
            currentUser.userLng = location.coordinate.longitude
            UserDefaults.standard.setValue(currentUser.userLat, forKey: "userLat")
            UserDefaults.standard.setValue(currentUser.userLng, forKey: "userLng")
//            print("Found Location: \(location)")
            //Release the enter map button
            self.enterSmileyButton.isEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Fail to find user location: \(error.localizedDescription)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Enter_Smiley(_ sender: Any) {
//        input =
//            [
//                ["https://www.materdei.org/pics/alumni/facebook.png", "-33.870001", "151.21000001"],
//                ["https://upload.wikimedia.org/wikipedia/commons/d/d5/Japan_small_icon.png", "-33.88", "151.25"]
//        ]
//        requestPlaces(email: currentUser.email, rule:"default")
    }

}
