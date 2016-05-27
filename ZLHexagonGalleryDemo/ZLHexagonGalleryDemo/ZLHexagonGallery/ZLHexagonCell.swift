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
    private weak var contentLayer: CAShapeLayer!
    
    private var _latestContentLayerPathCacheKey: String = ""
    private static var _cachedContentLayerPaths: [String: UIBezierPath] = [:]
    
// MARK: - Init
    
    required init() {
        super.init(frame: CGRectZero)
        self._initialization(CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._initialization(frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._initialization(CGRectZero)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let contentLayerPathCacheKey = "\(rect.width),\(rect.height)"
        if _latestContentLayerPathCacheKey == contentLayerPathCacheKey {
            return
        }
        
        _latestContentLayerPathCacheKey = contentLayerPathCacheKey
        contentLayer.frame = CGRectMake(0, 0, rect.width, rect.height)
        if let contentLayerPath = ZLHexagonCell._cachedContentLayerPaths[contentLayerPathCacheKey] {
            contentLayer.path = contentLayerPath.CGPath
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
            contentLayerPath.moveToPoint(points[0])
            contentLayerPath.addLineToPoint(points[1])
            contentLayerPath.addLineToPoint(points[2])
            contentLayerPath.addLineToPoint(points[3])
            contentLayerPath.addLineToPoint(points[4])
            contentLayerPath.addLineToPoint(points[5])
            contentLayerPath.addLineToPoint(points[0])
            contentLayerPath.closePath()
            contentLayer.path = contentLayerPath.CGPath
            ZLHexagonCell._cachedContentLayerPaths[contentLayerPathCacheKey] = contentLayerPath
        }
    }
    
    static var initCount: Int = 0
    private func _initialization(frame: CGRect) {
        self.opaque = false
        
        contentLayer = {
            let layer = CAShapeLayer()
            layer.frame = CGRectMake(0, 0, frame.width, frame.height)
            //layer.fillColor = RGB(128, 57, 200, alpha: 0.3).CGColor
            layer.masksToBounds = true
            self.layer.addSublayer(layer)
            return layer
        } ()
        
        self.imageView = {
            let _imageView = UIImageView()
            _imageView.contentMode = UIViewContentMode.ScaleToFill
            self.addSubview(_imageView)
            return _imageView
        } ()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = self.bounds
    }
    
    func setHighlighted(highlighted: Bool) {
        self.contentLayer.fillColor = highlighted
            ? RGB(0, 0, 0, alpha: 0.5).CGColor
            : (_selected ? RGB(0, 0, 0, alpha: 0.2).CGColor : nil)
    }
    
    func setSelected(selected: Bool) {
        _selected = selected
        self.contentLayer.fillColor = selected ? RGB(0, 0, 0, alpha: 0.2).CGColor : nil
    }

}
