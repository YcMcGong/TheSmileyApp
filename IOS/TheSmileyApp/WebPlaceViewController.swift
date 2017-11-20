//
//  WebPlaceViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 11/19/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire

class WebPlaceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func LikeIt(_ sender: Any) {
        let parameters: Parameters = [
            "attraction": currentUser.PlaceToSee,
            "like": "like"
        ]
        Alamofire.request("https://thatsmileycompany.com/like", method: .post, parameters: parameters)
    }
    
    @IBAction func DislikeIt(_ sender: Any) {
        let parameters: Parameters = [
            "attraction": currentUser.PlaceToSee,
            "like": "dislike"
        ]
        Alamofire.request("https://thatsmileycompany.com/like", method: .post, parameters: parameters)
    }

}
