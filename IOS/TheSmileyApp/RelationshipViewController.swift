//
//  RelationshipViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/6/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FriendViewCell: UITableViewCell {
    @IBOutlet weak var friendEmailText: UILabel!
    @IBOutlet weak var friendExplorerLable: UILabel!
    @IBOutlet weak var friendExperienceLabel: UILabel!
    @IBOutlet weak var friendExplorerNumText: UILabel!
    @IBOutlet weak var friendExpText: UILabel!
    @IBOutlet weak var friendNameText: UILabel!
}

class RelationshipViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var addFriendEmailText: UITextField!
    
    override func viewDidLoad() {
        print(FriendList.friendlist)
        super.viewDidLoad()
        self.hideKeyboard()
//        // Do any additional setup after loading the view.
//        let arr = ["Eggs", "Milk", "Tom"]
//        for i in arr {
//            Friends.addFriend(newFriend: i)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("finish table")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count")
        print(FriendList.friendlist.count)
        return FriendList.friendlist.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendViewCell
        
//        cell.friendNameText?.text = FriendList.friendlist[0][indexPath.row]
//        cell.friendEmailText?.text = FriendList.friendlist[1][indexPath.row]
//        cell.friendExplorerNumText?.text = FriendList.friendlist[2][indexPath.row]
        cell.friendNameText?.text = FriendList.friendlist[indexPath.row][0]
        cell.friendEmailText?.text = FriendList.friendlist[indexPath.row][1]
        cell.friendExplorerNumText?.text = FriendList.friendlist[indexPath.row][2]

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            Friends.removeFriend(atIndex: indexPath.row)
//            requestFriendList(email: currentUser.email)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        currentUser.target_friend_email = FriendList.friendlist[1][indexPath.row]
        requestPlaces(email: currentUser.target_friend_email, rule: "showall")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let MapController = storyBoard.instantiateViewController(withIdentifier: "MapController") as! MapViewController
        self.present(MapController, animated: true, completion: nil)
    }
    
    @IBAction func addFriend(_ sender: Any) {
        
        //Request Friendlist
        let friend_email = self.addFriendEmailText.text!
        let parameters: Parameters = [
            "email": friend_email
        ]
        Alamofire.request("https://thatsmileycompany.com/friendlist", method: .post, parameters: parameters).responseJSON
            {   response in
                }
        usleep(500000) // Add a 0.5s delay to make sure the database is already correctly updated
        modifiedToAllowUpdateTable_requestFriendList(email: currentUser.email)
    }
    
    func modifiedToAllowUpdateTable_requestFriendList(email:String)
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
                    
                    // Update Table
//                    self.Table.beginUpdates()
                    self.Table.insertRows(at: [IndexPath(row: FriendList.friendlist.count-1, section: 0)], with: .automatic)
//                    self.Table.endUpdates()
                    
                case .failure:
                    print("empty friend")
                }
        }
    }
    

}
