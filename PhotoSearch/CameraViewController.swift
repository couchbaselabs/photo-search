//
//  CameraViewController.swift
//  PhotoSearch
//
//  Copyright © 2018 Couchbase. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    @IBOutlet weak var noCameraImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    
    var session: AVCaptureSession?
    var output : AVCapturePhotoOutput?
    var preview: AVCaptureVideoPreviewLayer?
    
    var addPhotoMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSession()
    }
    
    func startSession() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            NSLog("Warning: No video capture devices found")
            noCameraImageView.isHidden = false
            cameraButton.isEnabled = false
            return
        }
        
        do {
            session = AVCaptureSession()
            let input = try AVCaptureDeviceInput(device: device)
            session!.addInput(input)
            output = AVCapturePhotoOutput()
            session!.addOutput(output!)
            
            preview = AVCaptureVideoPreviewLayer(session: session!)
            preview!.videoGravity = .resizeAspectFill
            preview!.frame = self.view.bounds
            self.view.layer.insertSublayer(preview!, at: 0)
            
            session!.startRunning()
        } catch {
            NSLog("Warning: Cannot start a capture session")
        }
    }
    
    @IBAction func takePhotoAction(_ sender: Any) {
        guard let session = self.session, session.isRunning, let output = self.output else {
            NSLog("Warning: No capture session")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        addPhotoMode = !addPhotoMode;
        let button = sender as! UIButton
        button.isSelected = addPhotoMode
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoLibrary" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! PhotosViewController
            controller.addPhotoMode = addPhotoMode
        } else if segue.identifier == "AddPhoto" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! AddPhotoViewController
            controller.image = (sender as! UIImage)
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)!
            if (addPhotoMode) {
                performSegue(withIdentifier: "AddPhoto", sender: image)
            } else {
                let controller = SearchViewController.controller()
                controller.photo = image
                controller.present(on: self)
            }
        }
    }
}
