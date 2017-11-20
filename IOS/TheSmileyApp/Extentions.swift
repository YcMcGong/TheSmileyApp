//
//  Extentions.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/8/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

// set up structures
struct User {
    var email:String!
    var target_friend_email:String!
    var login:Bool!
    var PlaceToSee:String!
    var userLat:Double!
    var userLng:Double!
    var needLocationUpdate = true
    // User Profile
    var experience:String!
    var exp_id:String!
    var name:String!
}

var Places = [[String]]()
var PlacesMarker = [UIImage]()
class FriendList: NSObject {
    
    static var friendlist:[[String]] = []
    
//    func initFriend(rows: Int){
//        for _ in stride(from: 0, to: rows, by: 1){
//            FriendList.friendlist.append([])
//        }
//    }
    func addFriend( newFriend:String, emailID: String, ExNum: String){
//        FriendList.friendlist[0].append(newFriend) //Name
//        FriendList.friendlist[1].append(emailID) //ID
//        FriendList.friendlist[2].append(ExNum) //Explore Number
        let oneNewFriend:[String] = [newFriend, emailID, ExNum]
        FriendList.friendlist.append(oneNewFriend)
    }
    
    func removeFriend( atIndex: Int){
        // Need a remove function to goes back to server
        let parameters: Parameters = [
            "email": FriendList.friendlist[atIndex][1]
        ]
        
        FriendList.friendlist.remove(at: atIndex) // Delete the associate row in the Datasource
        
        Alamofire.request("https://thatsmileycompany.com/friendlist", method: .delete, parameters: parameters).validate(statusCode: 200..<300).responseJSON { response in
            switch response.result {
            case .success:
//                FriendList.friendlist.remove(at: atIndex)
                print("delete suceed")
            case .failure:
                print("Fail to delete")
            }
        }
    }
    
    func removeAllFriend(){
        FriendList.friendlist.removeAll()
    }
}

// create friendlist and user objects
var Friends = FriendList()
var currentUser = User()

// extensions
extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

// request for updating
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
                PlacesMarker.removeAll()
                for (index, place):(String, JSON) in data {
                    let i = Int(index)!
                    Places.append([])
                    Places[i].append(place["url"].stringValue)
                    Places[i].append(place["lat"].stringValue)
                    Places[i].append(place["lng"].stringValue)
                    // Update the image holder
                    PlacesMarker.append(LoadIMG(url: place["url"].stringValue))
                }
            case .failure:
                print("empty map")
            }
    }
}

func requestProfileInfo(email:String)
{
    //Request User Infomation
    
    let parameters: Parameters = [
        "email": email
    ]
    Alamofire.request("https://thatsmileycompany.com/profile", method: .get, parameters: parameters).responseJSON
        {   response in
            let result = response.result.value
            let data = JSON(result!)
            print(data)
            print("almo")
            //Present Data
            currentUser.exp_id = data["ID"].stringValue
            currentUser.experience = data["experience"].stringValue
            currentUser.name = data["name"].stringValue
    }
}

func requestFriendList(email:String)
{
    //Request Friendlist
    let parameters: Parameters = [
        "email": email
    ]
    Alamofire.request("https://thatsmileycompany.com/friendlist", method: .get, parameters: parameters).validate().responseJSON
        {   response in
            switch response.result {
                case .success:
                    let result = response.result.value
                    let friends = JSON(result!)
                
                    //Load Data to Friendlist
                    Friends.removeAllFriend()
//                    Friends.initFriend(rows: 3) // 3 attraibutes for each friend
                    for (_, friend):(String, JSON) in friends {
                        Friends.addFriend(newFriend: friend["name"].stringValue, emailID: friend["email"].stringValue, ExNum: friend["explorer_num"].stringValue)
                    }
                case .failure:
                    print("empty friend")
            }
    }
}

//Function to load image as UIImage
func LoadIMG(url: String) -> UIImage!
{
    let icon_url = URL(string: url)!
    let data = try? Data(contentsOf: icon_url)
    let IMG = UIImage(data: data!, scale:2)
    
    return IMG
}

