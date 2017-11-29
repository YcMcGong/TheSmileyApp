//
//  WebPlaceViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 11/19/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WebPlaceViewController: UIViewController {
    
    @IBOutlet weak var LikeButton: UIButton!
    @IBOutlet weak var DislikeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.LikeButton.isEnabled = false
        self.DislikeButton.isEnabled = false
        // Check if the user has liked or disliked
        
        let parameters: Parameters = [
            "attraction": currentUser.PlaceToSee
        ]
        Alamofire.request("https://thatsmileycompany.com/like", method: .get, parameters: parameters).responseJSON
            {   response in
                let result = response.result.value
                let data = JSON(result!)
                
                // Present Data
                let rating = data["rating"].stringValue
                
                // Enable like or dislike
                if (rating == "0"){
                    self.LikeButton.isEnabled = true
                    self.DislikeButton.isEnabled = true
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func LikeIt(_ sender: Any) {
        let parameters: Parameters = [
            "attraction": currentUser.PlaceToSee,
            "like": "1"
        ]
        Alamofire.request("https://thatsmileycompany.com/like", method: .post, parameters: parameters)
        // User can only submit like or unlike once
        self.LikeButton.isEnabled = false
        self.DislikeButton.isEnabled = false
    }
    
    @IBAction func DislikeIt(_ sender: Any) {
        let parameters: Parameters = [
            "attraction": currentUser.PlaceToSee,
            "like": "-1"
        ]
        Alamofire.request("https://thatsmileycompany.com/like", method: .post, parameters: parameters)
        // User can only submit like or unlike once
        self.LikeButton.isEnabled = false
        self.DislikeButton.isEnabled = false
    }

}
