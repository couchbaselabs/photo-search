//
//  Image.swift
//  PhotoSearch
//
//  Copyright © 2018 Couchbase. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift


extension UIImage {
    func square(size: CGFloat) -> UIImage? {
        return square()?.resize(newSize: CGSize(width: size, height: size))
    }
    
    func square() -> UIImage? {
        let oWidth = CGFloat(self.cgImage!.width)
        let oHeight = CGFloat(self.cgImage!.height)
        let sqSize = min(oWidth, oHeight)
        let x = (oWidth - sqSize) / 2.0
        let y = (oHeight - sqSize) / 2.0
        let rect = CGRect(x: x, y: y, width: sqSize, height: sqSize)
        let sqImage = self.cgImage!.cropping(to: rect)
        return UIImage(cgImage: sqImage!, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func resize(newSize: CGSize) -> UIImage? {
        let oWidth = self.size.width
        let oHeight = self.size.height
        let wRatio = newSize.width  / oWidth
        let hRatio = newSize.height / oHeight
        
        var nuSize: CGSize
        if(wRatio > hRatio) {
            nuSize = CGSize(width: oWidth * hRatio, height: oHeight * hRatio)
        } else {
            nuSize = CGSize(width: oWidth * wRatio, height: oHeight * wRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: nuSize.width, height: nuSize.height)
        
        UIGraphicsBeginImageContextWithOptions(nuSize, false, self.scale)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

class Photo {
    private static let cache = NSCache<AnyObject, AnyObject>()
    
    private static let queue = DispatchQueue(label: "photo-queue")
    
    static func square(photo: Blob?, size: CGFloat,
                       onComplete action: ((UIImage?) -> Void)?) -> UIImage? {
        guard let blob = photo else { return nil }
        
        if let key = blob.digest {
            if let cachedImage = cache.object(forKey: key as AnyObject) as? UIImage {
                return cachedImage
            }
        }
        
        queue.async {
            if let image = UIImage(data: blob.content!, scale: UIScreen.main.scale) {
                if let square = image.square(size: size) {
                    DispatchQueue.main.async {
                        if let key = blob.digest {
                            cache.setObject(square, forKey: key as AnyObject)
                        }
                        if let complete = action {
                            complete(square)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    class func square(photo: UIImage?, size: CGFloat, cachekey: String?,
                      onComplete action: ((UIImage?) -> Void)?) -> UIImage? {
        if (cache.countLimit != 50) {
            cache.countLimit = 50
        }
        
        guard let oImage = photo else {
            return nil
        }
        
        if let key = cachekey, !key.isEmpty {
            if let cachedImage = cache.object(forKey: key as AnyObject) as? UIImage {
                return cachedImage
            }
        }
        
        DispatchQueue.global().async {
            let square = oImage.square(size: size)
            DispatchQueue.main.async {
                if let key = cachekey, !key.isEmpty, let cachedImage = square {
                    cache.setObject(cachedImage, forKey: key as AnyObject)
                }
                if let complete = action {
                    complete(square)
                }
            }
        }
        return nil
    }
}
