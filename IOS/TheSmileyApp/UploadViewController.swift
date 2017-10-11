//
//  UploadViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/6/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire
import Photos

var uploadStatusIndicator:String!
class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var IMView: UIImageView!
    @IBOutlet weak var attractionNameText: UITextField!
//    @IBOutlet weak var addressText: UITextField!
//    @IBOutlet weak var latText: UITextField!
//    @IBOutlet weak var lngText: UITextField!
    @IBOutlet weak var introText: UITextView!
    @IBOutlet weak var errotIndicator: UILabel!
    
    var lat:String!
    var lng:String!
    var upload_image:UIImage!
    
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
        self.present(myPickerController, animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let URL = info[UIImagePickerControllerReferenceURL] as? URL
        {
            print(URL)
            let opts = PHFetchOptions()
            opts.fetchLimit = 1
            let assets = PHAsset.fetchAssets(withALAssetURLs: [URL], options: opts)
//            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [URL], options: opts)
//            print(" i am here")
//            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [URL], options: opts)
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Upload(_ sender: Any) {
        if checkIfValid(){
            let name = self.attractionNameText.text!
            let intro = self.introText.text!
            
            let imageCover = upload_image.resizeWithWidth(width: 500)!
            let imageMarker = upload_image.resizeWithWidth(width: 90)!
            let imageCoverData = UIImageJPEGRepresentation(imageCover, 0.9)!
            let imageMarkerData = UIImageJPEGRepresentation(imageMarker, 0.9)!
            
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    
                    //Attribute Upload
                    multipartFormData.append(name.data(using: .utf8)!, withName: "name")
                    //                multipartFormData.append(address.data(using: .utf8)!, withName: "address")
                    multipartFormData.append(self.lat.data(using: .utf8)!, withName: "lat")
                    multipartFormData.append(self.lng.data(using: .utf8)!, withName: "lng")
                    multipartFormData.append(intro.data(using: .utf8)!, withName: "intro")
                    
                    //Image Upload
                    multipartFormData.append(imageCoverData, withName: "cover", fileName: "cover.jpg", mimeType: "image/jpg")
                    multipartFormData.append(imageMarkerData, withName: "marker", fileName: "marker.jpg", mimeType: "image/jpg")
            },
                to: "https://smileyappios.appspot.com/attraction",
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                            uploadStatusIndicator = "Upload Success"
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        uploadStatusIndicator = "Upload to server failed, Please try again"
                    }
            }
            )
        }
    }
    
    func checkIfValid() -> Bool{
        let testName = self.attractionNameText.text!.trim()
        let testIntro = self.introText.text!.trim()
        if (testName != "")&&(testIntro != "")&&(self.IMView.image != nil)
        {
            print("sucess")
            return true
        }
        else{
            print("fail")
            uploadStatusIndicator = "Upload Failed, all fields are required"
            return false
        }
    }
    
}

