//
//  ViewController.swift
//  SimpleCameraApp
//
//  Created by Ed Martinez on 9/18/19.
//  Copyright © 2019 Ed Martinez. All rights reserved.
//

import UIKit

// Allow the ViewController to access the camera through the image picker
// controller and view the image that the camera currently sees.

class ViewController: UIViewController, UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Since we need to use the camera, we need to make sure that one is
        // available. Some devices won'thave one. The simulator definitely
        // does not have one
        
        // This can be tested in the simulator. It should say that there is no camera.
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            let alertController = UIAlertController.init(title: nil, message: "There is no camera", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    
    }
    
    // If user takes a picture we want to show it in the Imageview
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let capturedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            picker.dismiss(animated: true, completion: nil)
            imageView.contentMode = .scaleToFill
            imageView.image = capturedImage
        }
    }
    
    // If user cancels, we hide the Camera view
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func takePicture(_ sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerController.SourceType.camera
            // By default the UIImagePickerController will pick the back camera. I set it to that
            // but if you want to use the front camera change that here (change from 'rear' to 'front')
            
            picker.cameraDevice = UIImagePickerController.CameraDevice.rear
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func savePicture(_ sender: Any) {
    }
    
}

