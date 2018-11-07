//
//  PhotoViewCell.swift
//  PhotoSearch
//
//  Copyright © 2018 Couchbase. All rights reserved.
//

import UIKit

class PhotoGridViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    var representedAssetIdentifier: String!
    
    var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
