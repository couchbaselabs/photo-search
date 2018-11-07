//
//  CameraViewController.swift
//  PhotoSearch
//
//  Copyright © 2018 Couchbase. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var session: AVCaptureSession?
    var output : AVCapturePhotoOutput?
    var preview: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(simulator)
            // Hide everything:
            let cover = UIView.init(frame: self.view.bounds)
            cover.backgroundColor = UIColor.white
            self.view.addSubview(cover)
        #else
            startSession()
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if targetEnvironment(simulator)
            self.performSegue(withIdentifier: "PhotoLibrary", sender: nil)
        #endif
    }
    
    func startSession() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            NSLog("Warning: No video capture devices found")
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
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)!
            let controller = SearchViewController.controller()
            controller.photo = image
            controller.present(on: self) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.session?.startRunning()
                }
            }
            self.session?.stopRunning()
        }
    }
}
