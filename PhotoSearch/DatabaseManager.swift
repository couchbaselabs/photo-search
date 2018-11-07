//
//  DatabaseManager.swift
//  PhotoSearch
//
//  Copyright © 2018 Couchbase. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class DatabaseManager {
    static let shared = DatabaseManager()
    
    let database: Database
    
    private init() {
        database = try! Database.init(name: "db")
    }
    
    func generateDocs(numbers: Int) {
        for i in 1...numbers {
            autoreleasepool {
                let doc = MutableDocument()
                doc.setValue("product", forKey: "type")
                doc.setValue("Product \(i)", forKey: "title")
                doc.setValue("Description of product \(i)", forKey: "description")
                doc.setValue(Date(), forKey: "createdAt")
                let data = dataFromResource(name: "\(i % 10)", ofType: "JPG") as Data
                let blob = Blob(contentType: "image/jpeg", data: data)
                doc.setValue(blob, forKey: "photo")
                try! database.saveDocument(doc)
            }
        }
    }
    
    func dataFromResource(name: String, ofType: String) -> NSData {
        let path = Bundle.main.path(forResource: name, ofType: ofType)
        return try! NSData(contentsOfFile: path!, options: [])
    }
}
