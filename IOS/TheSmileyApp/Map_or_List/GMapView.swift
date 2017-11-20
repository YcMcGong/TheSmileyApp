//
//  MapViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/5/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

// Mapping reminder: Place[0:url, 1: lat, 2:lng, 3:name, 4:discover, 5:rating]

import UIKit
import GoogleMaps

class markerUrlData{
    var marker_url: String
    init(setUrl input_url: String) {
        marker_url = input_url
    }
}

//View Functions
//class MapViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate {
class GMapView: UIViewController, GMSMapViewDelegate {
    
    var mapView: GMSMapView!
    //    private var clusterManager: GMUClusterManager!
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        //        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let camera = GMSCameraPosition.camera(withLatitude: currentUser.userLat, longitude: currentUser.userLng, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true;
        mapView.settings.myLocationButton = true
        
        //Usinf Custom Style for the map
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        mapView.delegate = self
        self.view = mapView

        for (index, place) in Places.enumerated(){
            let marker = GMSMarker()
            let lat = Double(place[1])!
            let lng = Double(place[2])!
            let markerURL = markerUrlData(setUrl: place[0])
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            marker.title = "test" //place[3]
            marker.userData = markerURL
            marker.groundAnchor = CGPoint(x:0.5, y:0.5)
            marker.snippet = "Australia" //place[4]

            // Use makrer holder instead than loading everytime
            marker.icon = PlacesMarker[index]
            marker.map = mapView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        currentUser.PlaceToSee = (marker.userData as! markerUrlData).marker_url
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let PlaceController = storyBoard.instantiateViewController(withIdentifier: "WebPlaceViewController") as! WebPlaceViewController
        self.present(PlaceController, animated: true, completion: nil)
    }
    
}


