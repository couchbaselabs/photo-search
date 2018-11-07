//
//  PhotoViewCell.swift
//  PhotoSearch
//
//  Copyright © 2018 Couchbase. All rights reserved.
//

import UIKit

class PhotoViewCell: UITableViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var photo: UIImage? {
        didSet {
            photoView.image = photo
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var desc: String? {
        didSet {
            descLabel.text = desc
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.image = nil
        titleLabel.text = nil
        descLabel.text = nil
    }
}
