 //
//  PlaceViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/6/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PlaceViewController: UIViewController {

    //UI Outputs
    @IBOutlet weak var CoverImg: UIImageView!
    @IBOutlet weak var AttractionName: UILabel!
    @IBOutlet weak var AddressView: UILabel!
    @IBOutlet weak var IntroView: UITextView!
    @IBOutlet weak var explorerIDText: UILabel!
    @IBOutlet weak var explorerNameText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        // Do any additional setup after loading the view.
//        GetData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//    func GetData()
//    {
//        //Request and Load Places
//
//        let parameters: Parameters = [
//            "attraction": currentUser.PlaceToSee
//        ]
//        Alamofire.request("https://thatsmileycompany.com/attraction", method: .get, parameters: parameters).responseJSON
//            {   response in
//
//                let result = response.result.value
//                let data = JSON(result!)
//
//                //Load Data to Place View
//                let url = data["url"].stringValue
//                let icon_url = URL(string: url)!
//                let img = try? Data(contentsOf: icon_url)
//                let IMG = UIImage(data: img!)
//                self.CoverImg.image = IMG
//
//                self.AttractionName.text = data["Name"].stringValue
//                self.AddressView.text = data["Address"].stringValue
//                self.explorerIDText.text = data["ExpID"].stringValue
//                self.explorerNameText.text = data["ExpName"].stringValue
//                self.IntroView.text = data["Intro"].stringValue
//
//        }
//
//    }
    
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
