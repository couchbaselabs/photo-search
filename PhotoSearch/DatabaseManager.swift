//
//  DatabaseManager.swift
//  PhotoSearch
//
//  Copyright © 2018 Couchbase. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class DatabaseManager {
    static let shared = DatabaseManager()
    
    let database: Database
    
    private init() {
        database = try! Database.init(name: "db")

        // Register the CoreML model
        let modelURL = Bundle.main.url(forResource: "Inceptionv3", withExtension:"mlmodelc")!
        PredictiveModel.register(modelURL, withName: "classify")
        
        try! database.createIndex(PredictiveIndex(modelName: "classify",
                                                 parameters: ["image": ["BLOB", ".photo"]], //{"image": ["BLOB", ".photo"]}
                                                 resultName: ".classLabel"),
                                 withName: "classifyPhotos")
    }
    
    func generateDocs(numbers: Int) {
        try! database.inBatch {
            for i in 1...numbers {
                autoreleasepool {
                    let doc = MutableDocument()
                    doc.setValue("product", forKey: "type")
                    doc.setValue("Product \(i)", forKey: "title")
                    doc.setValue("Description of product \(i)", forKey: "description")
                    doc.setValue(generateTags(), forKey: "tags")
                    doc.setValue(Date(), forKey: "createdAt")
                    let data = dataFromResource(name: "\(i % 25)", ofType: "jpg") as Data
                    let blob = Blob(contentType: "image/jpeg", data: data)
                    doc.setValue(blob, forKey: "photo")
                    try! database.saveDocument(doc)
                }
            }
        }
    }
    
    let kTags = ["cloth", "jean", "shoes", "books", "software", "grocery", "food", "drink", "toys"];
    
    func generateTags() -> [String] {
        var tags = Set<String>()
        let num = Int.random(in: 0..<kTags.count)
        for i in 0...num {
            tags.insert(kTags[i])
        }
        return Array(tags)
    }
    
    func dataFromResource(name: String, ofType: String) -> NSData {
        let path = Bundle.main.path(forResource: name, ofType: ofType)
        return try! NSData(contentsOfFile: path!, options: [])
    }
    
    func savePhoto(_ photo: UIImage, title: String?) {
        let doc = MutableDocument()
        
        // Photo:
        let data = photo.jpegData(compressionQuality: 0.8)!
        let blob = Blob(contentType: "image/jpg", data: data)
        doc.setBlob(blob, forKey: "photo");
        
        // Title:
        if title != nil {
            doc.setString(title, forKey: "title")
        }
        
        try! database.saveDocument(doc)
    }
}
