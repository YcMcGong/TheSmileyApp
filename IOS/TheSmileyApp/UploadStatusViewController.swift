//
//  UploadStatusViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/10/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit

class UploadStatusViewController: UIViewController {

    @IBOutlet weak var errorIndicatorText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorIndicatorText.text = uploadStatusIndicator
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
