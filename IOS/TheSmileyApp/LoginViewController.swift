//
//  LoginViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/6/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire

struct User {
    var email:String!
    var login:Bool!
}
var Places = [[String]]()
class FriendList: NSObject {
    
    //    static var friendlist:[[String]] = []
    //
    //    func addFriend( newFriend:String, emailID: String, ExNum: String){
    //        FriendList.friendlist[0].append(newFriend) //Name
    //        FriendList.friendlist[1].append(emailID) //ID
    //        FriendList.friendlist[2].append(ExNum) //Explore Number
    //    }
    //
    //    func removeFriend( atIndex: Int){
    //        // Need a remove function to goes back to server
    //        FriendList.friendlist.remove(at: atIndex)
    //    }
    static var friendlist:[String] = []
    
    func addFriend( newFriend:String){
        FriendList.friendlist.append(newFriend) //Name
    }
    
    func removeFriend( atIndex: Int){
        // Need a remove function to goes back to server
        FriendList.friendlist.remove(at: atIndex)
    }
}

var Friends = FriendList()
var currentUser = User()

//-------------------------------------------------------
class LoginViewController: UIViewController {

    @IBOutlet weak var EmailText: UITextField!
    @IBOutlet weak var SecretText: UITextField!
    @IBOutlet weak var LoginIndicator: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let CampController = storyBoard.instantiateViewController(withIdentifier: "CampController") as! CampViewController
                self.present(CampController, animated: true, completion: nil)
            case .failure:
                self.LoginIndicator.text = "Login not successfull, please try again"
            }
        }
    }
}
