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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GetData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func GetData()
    {
        Alamofire.request("https://smileyappios.appspot.com").responseJSON
        {   response in
            
            let result = response.result.value
            let test = JSON(result!)
            
            //Get image
            let url = "https://ichef.bbci.co.uk/news/660/cpsprodpb/1325A/production/_88762487_junk_food.jpg"
            let icon_url = URL(string: url)!
            let data = try? Data(contentsOf: icon_url)
            let IMG = UIImage(data: data!)
            self.CoverImg.image = IMG
            
            self.AttractionName.text = test["one"].stringValue
            self.AddressView.text = test["two"].stringValue
        }

    }

}
