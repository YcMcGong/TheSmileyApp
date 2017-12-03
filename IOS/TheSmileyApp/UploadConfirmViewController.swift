//
//  UploadConfirmViewController.swift
//  TheSmileyApp
//
//  Created by Yicong Gong on 12/2/17.
//  Copyright © 2017 Yicong Gong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UploadConfirmViewController: UIViewController {
    
    var pickedPlace:String?
    
    @IBOutlet weak var placePicker: UIPickerView!
    @IBOutlet weak var confirmButtonUI: UIButton!
    @IBOutlet weak var uploadIndicator: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Default to select the first row
        currentUpload.name = selectPlacesList[0][0]
        currentUpload.lat = selectPlacesList[0][1]
        currentUpload.lng = selectPlacesList[0][2]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        
        // Disable the button to prevent repeated upload
        confirmButtonUI.isEnabled = false
        uploadIndicator.text = "Image is being upload"
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                //Attribute Upload
                multipartFormData.append(currentUpload.name.data(using: String.Encoding.isoLatin1)!, withName: "name")
                multipartFormData.append(currentUpload.lat.data(using: String.Encoding.isoLatin1)!, withName: "lat")
                multipartFormData.append(currentUpload.lng.data(using: String.Encoding.isoLatin1)!, withName: "lng")
                multipartFormData.append(currentUpload.intro.data(using: String.Encoding.isoLatin1)!, withName: "intro")
//                multipartFormData.append(currentUpload.address.data(using: String.Encoding.isoLatin1)!, withName: "address")
                multipartFormData.append(currentUpload.rating.data(using: String.Encoding.isoLatin1)!, withName: "rating")
                
                //Image Upload
                multipartFormData.append(currentUpload.imageCoverData, withName: "cover", fileName: "cover.jpg", mimeType: "image/jpg")
                multipartFormData.append(currentUpload.imageMarkerData, withName: "marker", fileName: "marker.jpg", mimeType: "image/jpg")
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

extension UploadConfirmViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectPlacesList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectPlacesList[row][0]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentUpload.name = selectPlacesList[row][0]
        currentUpload.lat = selectPlacesList[row][1]
        currentUpload.lng = selectPlacesList[row][2]
    }
}

