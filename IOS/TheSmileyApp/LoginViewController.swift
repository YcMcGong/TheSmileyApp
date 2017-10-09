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

struct User {
    var email:String!
    var target_friend_email:String!
    var login:Bool!
    var PlaceToSee:String!
}

var Places = [[String]]()
class FriendList: NSObject {
    
    static var friendlist:[[String]] = []
    
    func initFriend(rows: Int){
        for _ in stride(from: 0, to: rows, by: 1){
            FriendList.friendlist.append([])
        }
    }
    func addFriend( newFriend:String, emailID: String, ExNum: String){
        FriendList.friendlist[0].append(newFriend) //Name
        FriendList.friendlist[1].append(emailID) //ID
        FriendList.friendlist[2].append(ExNum) //Explore Number
    }
    
    func removeFriend( atIndex: Int){
        // Need a remove function to goes back to server
        let parameters: Parameters = [
            "email": FriendList.friendlist[1][atIndex]
        ]
        Alamofire.request("https://thatsmileycompany.com/friendlist", method: .delete, parameters: parameters).validate(statusCode: 200..<300).responseJSON { response in
            switch response.result {
            case .success:
                FriendList.friendlist[0].remove(at: atIndex)
                FriendList.friendlist[1].remove(at: atIndex)
                FriendList.friendlist[2].remove(at: atIndex)
            case .failure:
                print("Fail to delete")
            }
        }
    }
    
    func removeAllFriend(){
        FriendList.friendlist.removeAll()
    }
    
    
//    static var friendlist:[String] = []
//
//    func addFriend( newFriend:String){
//        FriendList.friendlist.append(newFriend) //Name
//    }
//
//    func removeFriend( atIndex: Int){
//        // Need a remove function to goes back to server
//        FriendList.friendlist.remove(at: atIndex)
//    }
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

func requestPlaces(email:String, rule:String)
{
    //Request and Load Places
    
    let parameters: Parameters = [
        "email": email,
        "rule" : rule
    ]
    Alamofire.request("https://thatsmileycompany.com/map", method: .get, parameters: parameters).validate().responseJSON
        {   response in
            switch response.result {
            case .success:
                let result = response.result.value
                let data = JSON(result!)
                
                //Load Data to Places
                Places.removeAll()
                for (index, place):(String, JSON) in data {
                    let i = Int(index)!
                    Places.append([])
                    Places[i].append(place["url"].stringValue)
                    Places[i].append(place["lat"].stringValue)
                    Places[i].append(place["lng"].stringValue)
                }
            case .failure:
                print("empty map")
            }
    }
}
