//
//  RelationshipViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/6/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit

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
        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        let arr = ["Eggs", "Milk", "Tom"]
//        for i in arr {
//            Friends.addFriend(newFriend: i)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Table.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendList.friendlist[0].count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendViewCell
        
        cell.friendNameText?.text = FriendList.friendlist[0][indexPath.row]
        cell.friendEmailText?.text = FriendList.friendlist[1][indexPath.row]
        cell.friendExplorerNumText?.text = FriendList.friendlist[2][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            Friends.removeFriend(atIndex: indexPath.row)
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

}
