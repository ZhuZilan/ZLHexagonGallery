//
//  ZLHexagonProtocol.swift
//  ZLHexagonGalleryDemo
//
//  Created by 子澜 on 16/5/4.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

@objc protocol ZLHexagonGalleryDelegate: UIScrollViewDelegate {
    
// MARK: - Data Source
    
    func galleryNumberOfItems(_ gallery: ZLHexagonGallery) -> Int
    
    func gallery(_ gallery: ZLHexagonGallery, cellForRowAtIndex index: Int) -> ZLHexagonCell
    
// MARK: - Delegate
    
    func gallery(_ gallery: ZLHexagonGallery, shouldHightlightItemAtIndex index: Int) -> Bool
    
    func gallery(_ gallery: ZLHexagonGallery, didHighlightItemAtIndex index: Int)
    
    func gallery(_ gallery: ZLHexagonGallery, didUnhighlightItemAtIndex index: Int)
    
    func gallery(_ gallery: ZLHexagonGallery, shouldSelectItemAtIndex index: Int) -> Bool
    
    func gallery(_ gallery: ZLHexagonGallery, shouldDeselectItemAtIndex index: Int) -> Bool
    
    func gallery(_ gallery: ZLHexagonGallery, didSelectItemAtIndex index: Int)
    
    func gallery(_ gallery: ZLHexagonGallery, didDeselectItemAtIndex index: Int)
    
    func gallery(_ gallery: ZLHexagonGallery, willDisplayCell cell: ZLHexagonCell, forIndex index: Int)
    
    func gallery(_ gallery: ZLHexagonGallery, didEndDisplayingCell cell: ZLHexagonCell, forIndex index: Int)
    
}

extension ZLHexagonGalleryDelegate {
    
    func gallery(_ gallery: ZLHexagonGallery, shouldHightlightItemAtIndex index: Int) -> Bool {
        return true
    }
    
    func gallery(_ gallery: ZLHexagonGallery, didHighlightItemAtIndex index: Int) {
        
    }
    
    func gallery(_ gallery: ZLHexagonGallery, didUnhighlightItemAtIndex index: Int) {
        
    }
    
    func gallery(_ gallery: ZLHexagonGallery, shouldSelectItemAtIndex index: Int) -> Bool {
        return true
    }
    
    func gallery(_ gallery: ZLHexagonGallery, shouldDeselectItemAtIndex index: Int) -> Bool {
        return true
    }
    
    func gallery(_ gallery: ZLHexagonGallery, didSelectItemAtIndex index: Int) {
        
    }
    
    func gallery(_ gallery: ZLHexagonGallery, didDeselectItemAtIndex index: Int) {
        
    }
    
    func gallery(_ gallery: ZLHexagonGallery, willDisplayCell cell: ZLHexagonCell, forIndex index: Int) {
        
    }
    
    func gallery(_ gallery: ZLHexagonGallery, didEndDisplayingCell cell: ZLHexagonCell, forIndex index: Int) {
        
    }
}
