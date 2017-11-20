//
//  PlaceWebViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 11/19/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import WebKit

class PlaceWebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        let url = URL(string: "https://thatsmileycompany.com/LookUpPlace/" + currentUser.PlaceToSee)!
        let url = URL(string: "https://www.google.com")!
        webView.load(URLRequest(url:url))
        webView.allowsBackForwardNavigationGestures = true
        // Do any additional setup after loading the view.
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
