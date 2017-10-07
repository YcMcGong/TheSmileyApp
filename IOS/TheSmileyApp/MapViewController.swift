//
//  MapViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/5/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import GoogleMaps

//Pass on values
var PlaceToSee = String()

//View Functions
class MapViewController: UIViewController, GMSMapViewDelegate {
    var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let home_button: UIButton = UIButton(type: .infoLight)
        
        home_button.frame = CGRect(origin: CGPoint(x:0,y:30), size: CGSize(width: 100, height: 25))
        home_button.addTarget(self, action: #selector(self.GoToHome), for: .touchUpInside)
        home_button.tag=2
        home_button.setTitle("Home", for: [])
        
        let create_button: UIButton = UIButton(type: .infoDark)
        create_button.frame = CGRect(origin: CGPoint(x:0,y:65), size: CGSize(width: 100, height: 25))
        create_button.addTarget(self, action: #selector(self.CreateAttraction), for: .touchUpInside)
        create_button.tag=3
        create_button.setTitle("Create", for: [])
        
        view.addSubview(home_button)
        view.addSubview(create_button)
    }
        
    @objc func GoToHome(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let CampController = storyBoard.instantiateViewController(withIdentifier: "CampController") as! CampViewController
        self.present(CampController, animated: true, completion: nil)
    }

    @objc func CreateAttraction(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let UploadController = storyBoard.instantiateViewController(withIdentifier: "UploadController") as! UploadViewController
        self.present(UploadController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 12.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        self.view = mapView
        
        for place in input{

            let marker = GMSMarker()
            let lat = Double(place[1])!
            let lng = Double(place[2])!
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            marker.title = place[0]
            marker.groundAnchor = CGPoint(x:0.5, y:0.5)
//            marker.snippet = "Australia"
            marker.icon = LoadIMG(url: place[0])
            marker.map = mapView
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        PlaceToSee = marker.title!
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let PlaceController = storyBoard.instantiateViewController(withIdentifier: "PlaceController") as! PlaceViewController
        self.present(PlaceController, animated: true, completion: nil)
        return true
    }
    
    func LoadIMG(url: String) -> UIImage!
    {
        let icon_url = URL(string: url)!
        let data = try? Data(contentsOf: icon_url)
        let IMG = UIImage(data: data!)
        
        return IMG
    }
    
    
    
}
