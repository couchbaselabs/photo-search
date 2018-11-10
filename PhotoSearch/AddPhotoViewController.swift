//
//  AddPhotoViewController.swift
//  PhotoSearch
//
//  Copyright © 2018 Couchbase. All rights reserved.
//

import UIKit

class AddPhotoViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = Photo.square(photo: image,
                                       size: imageView.bounds.size.width,
                                       cachekey: nil) { (image) in
            self.imageView.image = image
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        DatabaseManager.shared.savePhoto(image!, title: titleTextField.text)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddPhotoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
