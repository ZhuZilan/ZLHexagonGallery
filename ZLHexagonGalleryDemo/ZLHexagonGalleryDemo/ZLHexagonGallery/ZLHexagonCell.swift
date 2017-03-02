//
//  ZLHexagonCell.swift
//  ZLHexagonGalleryDemo
//
//  Created by 子澜 on 16/5/4.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

class ZLHexagonCell: UIView {
    
    var _index: Int = 0
    
    var _identifier: String?
    
    var _selected: Bool = false
    
    weak var imageView: UIImageView!
    fileprivate weak var contentLayer: CAShapeLayer!
    
    fileprivate var _latestContentLayerPathCacheKey: String = ""
    fileprivate static var _cachedContentLayerPaths: [String: UIBezierPath] = [:]
    
// MARK: - Init
    
    required init() {
        super.init(frame: CGRect.zero)
        self._initialization(CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._initialization(frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._initialization(CGRect.zero)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let contentLayerPathCacheKey = "\(rect.width),\(rect.height)"
        if _latestContentLayerPathCacheKey == contentLayerPathCacheKey {
            return
        }
        
        _latestContentLayerPathCacheKey = contentLayerPathCacheKey
        contentLayer.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        if let contentLayerPath = ZLHexagonCell._cachedContentLayerPaths[contentLayerPathCacheKey] {
            contentLayer.path = contentLayerPath.cgPath
        } else {
            let points: [CGPoint] = [
                CGPoint(x: 0, y: rect.height * 0.25),
                CGPoint(x: rect.width * 0.5, y: 0),
                CGPoint(x: rect.width, y: rect.height * 0.25),
                CGPoint(x: rect.width, y: rect.height * 0.75),
                CGPoint(x: rect.width * 0.5, y: rect.height),
                CGPoint(x: 0, y: rect.height * 0.75)
            ]
            let contentLayerPath = UIBezierPath()
            contentLayerPath.move(to: points[0])
            contentLayerPath.addLine(to: points[1])
            contentLayerPath.addLine(to: points[2])
            contentLayerPath.addLine(to: points[3])
            contentLayerPath.addLine(to: points[4])
            contentLayerPath.addLine(to: points[5])
            contentLayerPath.addLine(to: points[0])
            contentLayerPath.close()
            contentLayer.path = contentLayerPath.cgPath
            ZLHexagonCell._cachedContentLayerPaths[contentLayerPathCacheKey] = contentLayerPath
        }
    }
    
    static var initCount: Int = 0
    fileprivate func _initialization(_ frame: CGRect) {
        self.isOpaque = false
        
        contentLayer = {
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            //layer.fillColor = RGB(128, 57, 200, alpha: 0.3).CGColor
            layer.masksToBounds = true
            self.layer.addSublayer(layer)
            return layer
        } ()
        
        self.imageView = {
            let _imageView = UIImageView()
            _imageView.contentMode = UIViewContentMode.scaleToFill
            self.addSubview(_imageView)
            return _imageView
        } ()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = self.bounds
    }
    
    func setHighlighted(_ highlighted: Bool) {
        self.contentLayer.fillColor = highlighted
            ? RGB(0, 0, 0, alpha: 0.5).cgColor
            : (_selected ? RGB(0, 0, 0, alpha: 0.2).cgColor : nil)
    }
    
    func setSelected(_ selected: Bool) {
        _selected = selected
        self.contentLayer.fillColor = selected ? RGB(0, 0, 0, alpha: 0.2).cgColor : nil
    }

}
