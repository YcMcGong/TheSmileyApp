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
    @IBOutlet weak var test_text: UITextField!
    @IBOutlet weak var act_ind: UIActivityIndicatorView!
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
        let send_text = test_text.text!
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(send_text.data(using: .utf8)!, withName: "text")
                let imageData = UIImageJPEGRepresentation(self.upload_image, 1.0)!
                multipartFormData.append(imageData, withName: "image", fileName: "file.jpg", mimeType: "image/jpg")
        },
            to: "https://smileyappios.appspot.com/create/post",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }
    
}

