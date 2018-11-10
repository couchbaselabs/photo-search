//
//  TagCollectionView.swift
//  PhotoSearch
//
//  Created by Pasin Suriyentrakorn on 11/10/18.
//  Copyright © 2018 Pasin Suriyentrakorn. All rights reserved.
//

import UIKit

class TagView: UILabel {
    private static let defaultFont = UIFont.systemFont(ofSize: 13)
    
    private static let padding: CGFloat = 5.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 2
        self.textAlignment = .center
        self.font = TagView.defaultFont
        self.textColor = UIColor.init(white: 0.0, alpha: 0.9)
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.05)
    }
    
    override var intrinsicContentSize: CGSize {
        guard let text = self.text else {
            return CGSize.zero
        }
        
        var size = text.size(withAttributes: [NSAttributedString.Key.font: self.font])
        size.width = size.width + (TagView.padding * 2)
        size.height = size.height + (TagView.padding * 2)
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var s = intrinsicContentSize
        s.width = min(s.width, size.width)
        s.height = min(s.height, size.height)
        return s
    }
}

class TagCollectionView: UIView {
    private let spaceX: CGFloat = 2.0
    
    private let spaceY: CGFloat = 2.0
    
    private let minHeight: CGFloat = 36
    
    private var tagViews: [TagView] = []
    
    private var cachedSize: CGSize?
    
    var tags: [String]? {
        didSet {
            let count = tags?.count ?? 0
            let removeCount = max(tagViews.count - count, 0)
            tagViews.removeLast(removeCount)
            
            if let texts = tags {
                for (i, text) in texts.enumerated() {
                    var tagView: TagView
                    if i < tagViews.count {
                        tagView = tagViews[i]
                    } else {
                        tagView = TagView()
                        tagViews.append(tagView)
                    }
                    tagView.text = text
                }
            }
            
            cachedSize = nil
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cachedSize = layoutSubViews(simulate: false)
        invalidateIntrinsicContentSize()
    }
    
    func layoutSubViews(simulate: Bool) -> CGSize {
        if !simulate {
            for view in subviews {
                view.removeFromSuperview()
            }
        }
        
        let rowHeight = (tagViews.first?.intrinsicContentSize.height ?? 0.0) + spaceY
        var rowCount = 0
        var rowX: CGFloat = 0.0
        var rowY: CGFloat = 0.0
        for tagView in tagViews {
            let tagViewSize = tagView.sizeThatFits(self.bounds.size)
            if rowCount == 0 || rowX + tagViewSize.width > self.bounds.width {
                rowX = 0;
                rowY = CGFloat(rowCount) * rowHeight
                rowCount = rowCount + 1
            }
            
            if !simulate {
                tagView.frame = CGRect(x: rowX,
                                       y: rowY,
                                       width: tagViewSize.width,
                                       height: tagViewSize.height)
                addSubview(tagView)
            }
            rowX = rowX + tagViewSize.width + spaceX
        }
        
        let w = self.bounds.width
        let h = max((CGFloat(rowCount) * rowHeight) - spaceY, minHeight)
        return CGSize(width: w, height: h)
    }
    
    override var intrinsicContentSize: CGSize {
        if cachedSize == nil {
            cachedSize = layoutSubViews(simulate: true)
        }
        return cachedSize!
    }
}
