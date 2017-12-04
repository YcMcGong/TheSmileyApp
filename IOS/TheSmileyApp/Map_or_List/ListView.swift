//
//  RelationshipViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/6/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

// Mapping reminder: Place[0:url, 1: lat, 2:lng, 3:name, 4:discover, 5:rating]
import UIKit
import Alamofire
import SwiftyJSON

class AttractionViewCell: UITableViewCell {
    @IBOutlet weak var attractionImage: UIImageView!
    @IBOutlet weak var attractionNameText: UILabel!
    @IBOutlet weak var discoverText: UILabel!
    @IBOutlet weak var ratingText: UILabel!
}

class ListView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var addFriendEmailText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Places.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttractionCell", for: indexPath) as! AttractionViewCell
        
        // Use Image marker holder instead
        cell.attractionImage?.image = PlacesMarker[indexPath.row]
        cell.attractionNameText?.text = Places[indexPath.row][3]
        cell.discoverText?.text = Places[indexPath.row][4]
        cell.ratingText?.text = Places[indexPath.row][5]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        currentUser.PlaceToSee = Places[indexPath.row][0]
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let PlaceController = storyBoard.instantiateViewController(withIdentifier: "WebPlaceViewController") as! WebPlaceViewController
        self.present(PlaceController, animated: true, completion: nil)
    }
    
    
}
