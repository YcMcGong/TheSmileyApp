//
//  MapOrListViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 11/19/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit

class MapOrListViewController: UIViewController {


    @IBOutlet weak var MapViewContainer: UIView!
    @IBOutlet weak var ListViewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapViewContainer.isHidden = false
        ListViewContainer.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SegmentSelect(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            MapViewContainer.isHidden = false
            ListViewContainer.isHidden = true
            break
        case 1:
            MapViewContainer.isHidden = true
            ListViewContainer.isHidden = false
            break
        default:
            break;
        }
    }
    

}
