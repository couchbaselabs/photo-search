//
//  SearchViewController.swift
//  PhotoSearch
//
//  Copyright © 2018 Couchbase. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var handleView: UIView!
    
    typealias CloseCompletion = () -> Void
    var closeCompletion: CloseCompletion?
    
    var photo: UIImage?
    var results : [Result]?
    var query: Query!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(SearchViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        
        if let photo = self.photo {
            // Do something with the photo:
            NSLog("photo: \(photo)")
        }
        
        // For testing, query all docs
        query = QueryBuilder
            .select(SelectResult.expression(Meta.id),
                    SelectResult.property("title"),
                    SelectResult.property("tags"),
                    SelectResult.property("photo"))
            .from(DataSource.database(DatabaseManager.shared.database))

        if let rs = try? query.execute() {
            results = rs.allResults()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        view.layer.cornerRadius = 12
        handleView.layer.cornerRadius = 3
    }
    
    // MARK: - UITableViewController
    
    var data: [Result]? {
        return results
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoViewCell") as! PhotoViewCell
        let result = self.data![indexPath.row]
        cell.title = result.string(at: 1)
        cell.tags = result.array(at: 2)?.toArray() as? [String]
        if let photo = result.blob(at: 3) {
            let thumbnail = Photo.square(photo: photo, size: 72.0, onComplete: { (thumbnail) -> Void in
                self.updateImage(photo: thumbnail, digest: photo.digest!, indexPath: indexPath)
            })
            cell.photo = thumbnail
        } else {
            cell.photo = nil
        }
        return cell
    }
    
    func updateImage(photo: UIImage?, digest: String, indexPath: IndexPath) {
        guard let data = self.data else { return }
        
        let row = data[indexPath.row]
        if let blob = row.blob(at: 3), let d = blob.digest, d == digest {
            if let cell = tableView.cellForRow(at: indexPath) as? PhotoViewCell {
                cell.photo = photo
            }
        }
    }
    
    // MARK: Gesture
    
    var beginPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let yOffset = SearchViewControllerPresentation.yOffset
        let curPoint = recognizer.location(in: self.view?.window)
        
        if recognizer.state == UIGestureRecognizer.State.began {
            beginPoint = curPoint
        } else if recognizer.state == UIGestureRecognizer.State.changed {
            if curPoint.y - beginPoint.y > 0 {
                self.view.frame = CGRect(x: 0,
                                         y: yOffset + (curPoint.y - beginPoint.y),
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height)
            }
        } else if recognizer.state == UIGestureRecognizer.State.ended ||
                  recognizer.state == UIGestureRecognizer.State.cancelled {
            if curPoint.y - beginPoint.y > 200 {
                self.dismiss(animated: true, completion: nil)
                if let cc = closeCompletion {
                   cc()
                }
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0,
                                             y: yOffset,
                                             width: self.view.frame.size.width,
                                             height: self.view.frame.size.height)
                })
            }
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension SearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        let yOffset = SearchViewControllerPresentation.yOffset
        if (view.frame.minY == yOffset && tableView.contentOffset.y == 0 && direction > 0) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        return false
    }
}

// MARK: Presentation

extension SearchViewController {
    static func controller() -> SearchViewController {
        return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
    }
    
    func present(on parent: UIViewController, closeCompletion: CloseCompletion? = nil) {
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
        self.closeCompletion = closeCompletion
        parent.present(self, animated: true, completion: nil)
    }
}

extension SearchViewController : UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return SearchViewControllerPresentation(presentedViewController: presented, presenting: presenting)
    }
}

class SearchViewControllerPresentation : UIPresentationController {
    static let yOffset: CGFloat = 44
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let v = containerView else { return CGRect.zero }
            let yOffset = SearchViewControllerPresentation.yOffset
            return CGRect(x: 0, y: yOffset, width: v.bounds.width, height: v.bounds.height - yOffset)
        }
    }
}
