//
//  UploadViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/6/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Photos

var uploadStatusIndicator:String!

// set up upload object structures
struct UploadAttractionObject {
    var name:String!
    var intro:String!
    var lat:String!
    var lng:String!
    var address:String!
    var rating:String!
    var imageCoverData:Data!
    var imageMarkerData:Data!
}

var currentUpload = UploadAttractionObject()

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var IMView: UIImageView!
    @IBOutlet weak var introText: UITextView!
    @IBOutlet weak var errotIndicator: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var ratingText: UILabel!
    
    var lat:String!
    var lng:String!
    var upload_image:UIImage!
    var rating:String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func Choose(_ sender: Any) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        myPickerController.allowsEditing = true
        self.present(myPickerController, animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let URL = info[UIImagePickerControllerReferenceURL] as? URL
        {
            print("THIS _____________")
            print(URL)
            let opts = PHFetchOptions()
            opts.fetchLimit = 1
            let assets = PHAsset.fetchAssets(withALAssetURLs: [URL], options: opts)
            
            if assets.count != 0
            {
                let asset = assets[0]
                
                if (asset.location?.coordinate.latitude != nil)&&(asset.location?.coordinate.longitude != nil)
                {
                    self.lat = String(describing: asset.location!.coordinate.latitude)
                    self.lng = String(describing: asset.location!.coordinate.longitude)
                    upload_image = info[UIImagePickerControllerOriginalImage] as? UIImage
                    IMView.image = upload_image
                    self.errotIndicator.textColor = UIColor.green
                    self.errotIndicator.text = "Image is valid"
                }
                else{
                    self.errotIndicator.textColor = UIColor.red
                    self.errotIndicator.text = "Image does not contain GPS info"
                }
            }
            
            else{
                self.errotIndicator.text = "Need to allow access for photo library"
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Upload(_ sender: Any) {
        
        if checkIfValid(){
            
            currentUpload.intro = self.introText.text!
            currentUpload.rating = rating
            
            // Check image shape
            // Horizontal
            let imageCover:UIImage!
            let imageMarker:UIImage!
            
            if upload_image.size.width > upload_image.size.height{
                imageCover = upload_image.resizeWithWidth(width: 800)!
                imageMarker = upload_image.resizeWithWidth(width: 120)!
            }
            
            // Vertical
            else if upload_image.size.width < upload_image.size.height{
                imageCover = upload_image.resizeWithHeight(height: 800)!
                imageMarker = upload_image.resizeWithHeight(height: 120)!
            }
            
            // Square
            else{
                imageCover = upload_image.resizeWithSquare(length: 600)!
                imageMarker = upload_image.resizeWithSquare(length: 90)!
            }
            
            currentUpload.imageCoverData = UIImageJPEGRepresentation(imageCover, 1.0)!
            currentUpload.imageMarkerData = UIImageJPEGRepresentation(imageMarker, 1.0)!
            
            // Get a list of nearby places
            requestSelectPlacesList(lat:self.lat, lng:self.lng)
            
        }
    }
    
    func checkIfValid() -> Bool{
        let testIntro = self.introText.text!.trim()
        if (testIntro != "")&&(self.IMView.image != nil)
        {
            return true
        }
        else{
            self.errotIndicator.textColor = UIColor.red
            self.errotIndicator.text = "Upload Failed, all fields are required"
            return false
        }
    }
    
    @IBAction func ratingSlider(_ sender: UISlider) {
        let rate = Int(sender.value)
        rating = String(rate)
        ratingText.text = rating
    }
    
    // request for selectPlacesList
    func requestSelectPlacesList(lat:String, lng:String)
    {
        //Request and Load Places
        
        let parameters: Parameters = [
            "lat": lat,
            "lng" : lng
        ]
        
        Alamofire.request("https://thatsmileycompany.com/selectPlacesNearby", method: .get, parameters: parameters).validate().responseJSON
            {   response in
                switch response.result {
                case .success:
                    let result = response.result.value
                    let data = JSON(result!)
                    
                    //Load Data to selectPlacesList
                    selectPlacesList.removeAll()
                    for (index, place):(String, JSON) in data {
                        let i = Int(index)!
                        selectPlacesList.append([])
                        selectPlacesList[i].append(place["name"].stringValue)
                        selectPlacesList[i].append(place["lat"].stringValue)
                        selectPlacesList[i].append(place["lng"].stringValue)
                    }
                    //Open the Places confirm view
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let UploadConfirmView = storyBoard.instantiateViewController(withIdentifier: "UploadConfirmView") as! UploadConfirmViewController
                    self.present(UploadConfirmView, animated: true, completion: nil)
                    
                case .failure:
                    print("cannot found any place")
                }
        }
    }
    
}



