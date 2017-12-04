//
//  SignupViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/7/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire

class SignupViewController: UIViewController {

    @IBOutlet weak var EmailText: UITextField!
    @IBOutlet weak var PasswordText: UITextField!
    @IBOutlet weak var PasswordAgainText: UITextField!
    @IBOutlet weak var NameText: UITextField!
    @IBOutlet weak var SignupIndicator: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Signup(_ sender: Any) {
        
        let email = EmailText.text!
        let password = PasswordText.text!
        let password_again = PasswordAgainText.text!
        let name = NameText.text!
        
        if checkIfValid(email: email, password: password, password_again: password_again, name: name){
            let parameters: Parameters = [
                "email": email,
                "password": password,
                "name": name
            ]
            Alamofire.request("https://thatsmileycompany.com/create_user", method: .post, parameters: parameters).validate(statusCode: 200..<300).responseJSON { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    currentUser.email = email
                    currentUser.name = name
                    currentUser.login = true
                    
                    //Login Success, now store the email and password in app
                    UserDefaults.standard.setValue(email, forKey: "smileyEmail")
                    UserDefaults.standard.setValue(password, forKey: "smileyPassword")
                    
                    // redirect to the camp page
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let CampController = storyBoard.instantiateViewController(withIdentifier: "CampController") as! CampViewController
                    self.present(CampController, animated: true, completion: nil)
                case .failure:
                    self.SignupIndicator.text = "Server Error"
                }
            }
        }
        
        else{
            self.SignupIndicator.text = "Password Not Matching"
        }
        
        
    }
    
    func checkIfValid(email: String, password: String, password_again: String, name: String) ->Bool
    {
        if password == password_again{
            return true
        }
        else {return false}
    }
}
