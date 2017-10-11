//
//  WebViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/10/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://thatsmileycompany.com/LookUpPlace/" + currentUser.PlaceToSee)!
        webView.load(URLRequest(url:url))
        webView.allowsBackForwardNavigationGestures = true
        // Do any additional setup after loading the view.
        
        // Add a return button
        let home_button: UIButton = UIButton(type: .infoLight)
        
        home_button.frame = CGRect(origin: CGPoint(x:0,y:30), size: CGSize(width: 100, height: 25))
        home_button.addTarget(self, action: #selector(self.GoToHome), for: .touchUpInside)
        home_button.tag=2
        home_button.setTitle("Home", for: [])
        view.addSubview(home_button)
    }
    
    @objc func GoToHome(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let CampController = storyBoard.instantiateViewController(withIdentifier: "CampController") as! CampViewController
        self.present(CampController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
