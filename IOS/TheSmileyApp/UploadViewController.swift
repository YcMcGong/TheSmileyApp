//
//  UploadViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 10/6/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var IMView: UIImageView!
    @IBOutlet weak var attractionNameText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var latText: UITextField!
    @IBOutlet weak var lngText: UITextField!
    @IBOutlet weak var introText: UITextView!
    @IBOutlet weak var errotIndicator: UILabel!
    
    
    var upload_image:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any])
    {
        upload_image = info[UIImagePickerControllerOriginalImage] as? UIImage
        IMView.image = upload_image
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Upload(_ sender: Any) {
        
        let name = self.attractionNameText.text!
        let address = self.addressText.text!
        let lat = self.latText.text!
        let lng = self.lngText.text!
        let intro = self.introText.text!
        
//        let imageCover = upload_image.resizeWithWidth(width: 500)!
//        let imageMarker = upload_image.resizeWithWidth(width: 90)!
//        let imageCoverData = UIImageJPEGRepresentation(imageCover, 0.9)!
//        let imageMarkerData = UIImageJPEGRepresentation(imageMarker, 0.9)!
        let image = UIImageJPEGRepresentation(upload_image, 0.9)!
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                //Attribute Upload
                multipartFormData.append(name.data(using: .utf8)!, withName: "name")
                multipartFormData.append(address.data(using: .utf8)!, withName: "address")
                multipartFormData.append(lat.data(using: .utf8)!, withName: "lat")
                multipartFormData.append(lng.data(using: .utf8)!, withName: "lng")
                multipartFormData.append(intro.data(using: .utf8)!, withName: "intro")
                
                //Image Upload
//                multipartFormData.append(imageCoverData, withName: "cover", fileName: "cover.jpg", mimeType: "image/jpg")
//                multipartFormData.append(imageMarkerData, withName: "marker", fileName: "marker.jpg", mimeType: "image/jpg")
                multipartFormData.append(image, withName: "cover", fileName: "cover.jpg", mimeType: "image/jpg")
        },
            to: "https://smileyappios.appspot.com/attraction",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    self.errotIndicator.text = "Upload failed, Please try again"
                }
        }
        )
    }
    
}

