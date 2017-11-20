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
    @IBOutlet weak var introText: UITextView!
    @IBOutlet weak var errotIndicator: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
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
            
            let imageCover = upload_image.resizeWithWidth(width: 800)!
            let imageMarker = upload_image.resizeWithWidth(width: 120)!
            let imageCoverData = UIImageJPEGRepresentation(imageCover, 1.0)!
            let imageMarkerData = UIImageJPEGRepresentation(imageMarker, 1.0)!
            
            //Indicate uploading
            self.errotIndicator.textColor = UIColor.green
            self.errotIndicator.text = "Image is uploading"
            
            //Disable user actions
            self.uploadButton.isEnabled = false
            self.chooseButton.isEnabled = false
            self.backButton.isEnabled = false
            
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    
                    //Attribute Upload
                    multipartFormData.append(name.data(using: String.Encoding.isoLatin1)!, withName: "name")
                    multipartFormData.append(self.lat.data(using: String.Encoding.isoLatin1)!, withName: "lat")
                    multipartFormData.append(self.lng.data(using: String.Encoding.isoLatin1)!, withName: "lng")
                    multipartFormData.append(intro.data(using: String.Encoding.isoLatin1)!, withName: "intro")
                    
                    //Image Upload
                    multipartFormData.append(imageCoverData, withName: "cover", fileName: "cover.jpg", mimeType: "image/jpg")
                    multipartFormData.append(imageMarkerData, withName: "marker", fileName: "marker.jpg", mimeType: "image/jpg")
            },
                to: "https://thatsmileycompany.com/attraction",
                method: .post,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                            uploadStatusIndicator = "Upload Success"
                            // Jump to upload status view
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let UploadStatusView = storyBoard.instantiateViewController(withIdentifier: "UploadStatusView") as! UploadStatusViewController
                            self.present(UploadStatusView, animated: true, completion: nil)
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        uploadStatusIndicator = "Upload to server failed, Please try again"
                        // Jump to upload status view
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let UploadStatusView = storyBoard.instantiateViewController(withIdentifier: "UploadStatusView") as! UploadStatusViewController
                        self.present(UploadStatusView, animated: true, completion: nil)
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
            return true
        }
        else{
            self.errotIndicator.textColor = UIColor.red
            self.errotIndicator.text = "Upload Failed, all fields are required"
            return false
        }
    }
    
}

