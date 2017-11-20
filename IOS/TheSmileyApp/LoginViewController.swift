//
//  LoginViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/6/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBOutlet weak var EmailText: UITextField!
    @IBOutlet weak var SecretText: UITextField!
    @IBOutlet weak var LoginIndicator: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        // Read the stored email and psw
        do {
            self.EmailText.text = UserDefaults.standard.string(forKey: "smileyEmail")
            self.SecretText.text = UserDefaults.standard.string(forKey: "smileyPassword")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Login(_ sender: Any) {
        let email = EmailText.text!
        let password = SecretText.text!
        let parameters: Parameters = [
            "email": email,
            "password": password
        ]
        Alamofire.request("https://thatsmileycompany.com/user", method: .post, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                currentUser.email = email
                currentUser.login = true
                //Login Success, now store the email and password in app
                UserDefaults.standard.setValue(email, forKey: "smileyEmail")
                UserDefaults.standard.setValue(password, forKey: "smileyPassword")
//                //Open the Camp Page
//                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let CampController = storyBoard.instantiateViewController(withIdentifier: "CampController") as! CampViewController
//                self.present(CampController, animated: true, completion: nil)
                self.requestProfileInfoWhenLogin(email: currentUser.email)
                
            case .failure:
                self.LoginIndicator.text = "Login not successfull, please try again"
            }
        }
    }
    
    func requestProfileInfoWhenLogin(email:String)
    {
        //Request User Infomation
        
        let parameters: Parameters = [
            "email": email
        ]
        Alamofire.request("https://thatsmileycompany.com/profile", method: .get, parameters: parameters).responseJSON
            {   response in
                let result = response.result.value
                let data = JSON(result!)

                //Present Data
                currentUser.exp_id = data["ID"].stringValue
                currentUser.experience = data["experience"].stringValue
                currentUser.name = data["name"].stringValue
                
                //Open the Camp Page
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let CampController = storyBoard.instantiateViewController(withIdentifier: "CampController") as! CampViewController
                self.present(CampController, animated: true, completion: nil)
        }
    }
}

