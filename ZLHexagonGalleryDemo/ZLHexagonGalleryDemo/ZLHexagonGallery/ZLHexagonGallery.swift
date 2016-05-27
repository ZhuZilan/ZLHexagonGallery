//
//  ZLHexagonGallery.swift
//  ZLHexagonGalleryDemo
//
//  Created by 子澜 on 16/5/4.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

class ZLHexagonGallery: UIScrollView {
    
// MARK: - Protocol
    
    weak var zl_delegate: ZLHexagonGalleryDelegate?
    
// MARK: - Attribute
    
    // Configurable
    
    var interItemSpacing: CGFloat = CGFloat(0)
    
    var cellSideLength: CGFloat = CGFloat(44)
    var cellWidth: CGFloat {
        get {
            return cellSideLength * sqrt(3)
        }
        set {
            cellSideLength = newValue / sqrt(3)
        }
    }
    var cellHeight: CGFloat {
        get {
            return cellSideLength * 2
        }
        set {
            cellSideLength = newValue / 2
        }
    }
    
    // Private
    
    private var _registeredCellTypes: [String: AnyClass] = [:]
    
    private var _count: Int = 0
    
    private var _cellRects: [Int: CGRect] = [:]
    
    private var _visibleCellRects: [(Int, CGRect)] {
        get {
            return _cellRects.filter({ (i, rect) -> Bool in
                return _displayingContentRect.containsVisibleRect(rect)
            })
        }
    }
    
    private var _visibleCells: [Int: ZLHexagonCell] = [:]
    
    private var _displayingContentRect: CGRect {
        get {
            return CGRectMake(contentOffset.x, contentOffset.y, bounds.width, bounds.height)
        }
    }
    
    private var _highlightedIndex: Int = -1
    
    internal var _displayingIndexStart: Int = -1
    internal var _displayingIndexEnd: Int = -1
    
// MARK: - Init
    
    init() {
        super.init(frame: CGRectZero)
        self.delegate = self
        self.alwaysBounceVertical = true
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
// MARK: - Interface
    
    func registerClass(cls: AnyClass?, forCellWithReuseIdentifier reuseIdentifier: String) {
        guard let cls = cls else {
            return
        }
        
        self._registeredCellTypes[reuseIdentifier] = cls
    }
    
    func dequeueReusableCellWithIdentifier(identifier: String) -> ZLHexagonCell? {
        if let cellInThePool = Pool.popCellForReuseIdentifier(identifier) {
            return cellInThePool
        }
        
        if let registeredCellType = _registeredCellTypes[identifier] {
            if let type = registeredCellType as? ZLHexagonCell.Type {
                let cell = type.init()
                cell._identifier = identifier
                return cell
            }
        }
        
        return nil
    }
    
    func reloadData() {
        
        // clear all visible cells.
        self.removeCells()
        self._cellRects = [:]
        self._visibleCells = [:]
        self._displayingIndexStart = -1
        self._displayingIndexEnd = -1
        
        // get number of items one time.
        _count = self.zl_delegate?.galleryNumberOfItems(self) ?? 0
        // sidelength?
        
        // avoid invalid numbers.
        if _count == 0 {
            return
        }
        
        // current displaying rect.
        let dispRect = _displayingContentRect
        let validRect = CGRect(
            x: dispRect.origin.x + contentInset.left,
            y: 0,
            width: dispRect.width - contentInset.left - contentInset.right,
            height: dispRect.height)
        
        // calculate base attributes.
        var numberOfItemsPerLine: Int = 1
        var remainedSpace = validRect.width - cellWidth
        while (remainedSpace >= (cellWidth + interItemSpacing)) {
            remainedSpace -= (cellWidth + interItemSpacing)
            numberOfItemsPerLine++
        }
        let numbersPerGroup: Int = (numberOfItemsPerLine + numberOfItemsPerLine - 1)
        let numberOfGroups: Int = (_count + numbersPerGroup - 1) / numbersPerGroup
        let heightOfGroup: CGFloat = cellSideLength + cellHeight + 2 * interItemSpacing
        
        // reset content size.
        if numbersPerGroup <= 0 || numberOfGroups == 0 {
            self.contentSize = validRect.size
            return
        } else {
            let lastGroupHasTwoLine: Bool = ((_count-1) % numbersPerGroup) >= Int(numbersPerGroup/2)
            self.contentSize = CGRectUnion(validRect, CGRectMake(0, 0,
                validRect.width, CGFloat(numberOfGroups) * heightOfGroup + (lastGroupHasTwoLine ? cellHeight * 0.25 : -cellSideLength))).size
        }
        
        // calculate cell rects
        for i in 0..<_count {
            let groupIndex: Int = i / numbersPerGroup
            let itemIndexInGroup: Int = i % numbersPerGroup
            let isFirstLine: Bool = itemIndexInGroup < Int(numbersPerGroup/2)
            let itemIndexInLine: Int = isFirstLine ? itemIndexInGroup : itemIndexInGroup - Int(numbersPerGroup/2)
            let cellRect = CGRectMake(
                cellWidth * (CGFloat(itemIndexInLine) + (isFirstLine ? 0.5 : 0)) + CGFloat(itemIndexInLine) * interItemSpacing,
                cellHeight * (isFirstLine ? 0 : 0.75) + heightOfGroup * CGFloat(groupIndex) + (isFirstLine ? 0 : interItemSpacing),
                cellWidth,
                cellHeight)
            _cellRects[i] = cellRect
        }
        
        self.displayingRectDidChange()
        
    }
    
    func visibleCells() -> [ZLHexagonCell] {
        return _visibleCells.values.sort({ (firstCell, secondCell) -> Bool in
            return firstCell._index < secondCell._index
        })
    }
    
// MARK: - Touches Handle
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        guard let touchPoint = touches.first?.locationInView(self) else {
            return
        }
        
        // find all rects that contains touch point.
        var containingRects: [(Int, CGRect)] = []
        for value in _visibleCellRects {
            if value.1.contains(touchPoint) {
                containingRects.append(value)
            }
        }
        
        // more than one rect contains touch point, 
        // mark nearest center point to touch as specified.
        if containingRects.count >= 2 {
            var nearestIndexRect = containingRects.first!
            for currentIndexRect in containingRects {
                let distanceL = _distanceBetween(_centerForRect(currentIndexRect.1), touchPoint)
                let distanceR = _distanceBetween(_centerForRect(nearestIndexRect.1), touchPoint)
                if distanceL < distanceR {
                    nearestIndexRect = currentIndexRect
                }
            }
            let indexForHighlight: Int = nearestIndexRect.0
            let explicit: Bool = self.zl_delegate?.gallery(self, shouldHightlightItemAtIndex: indexForHighlight) ?? true
            self.highlightItemAtIndex(indexForHighlight, explicit: explicit)
        }
            
        // only one rect contains touch point.
        else if containingRects.count == 1 {
            let indexForHighlight: Int = containingRects.first!.0
            let explicit: Bool = self.zl_delegate?.gallery(self, shouldHightlightItemAtIndex: indexForHighlight) ?? true
            self.highlightItemAtIndex(indexForHighlight, explicit: explicit)
        }
        
        // else no visible cell rects contains touch point,
        // means touched a point out of valid cell rects.
        else { }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        guard _highlightedIndex >= 0 else {
            return
        }
        
        // unhighlight highlighted cell.
        let index = _highlightedIndex
        self.unhighlightItemAtIndex(_highlightedIndex)
        
        // ask delegate to select/deselect item at index.
        let isSelected: Bool = _visibleCells[index]?._selected ?? false
        if isSelected {
            if self.zl_delegate?.gallery(self, shouldDeselectItemAtIndex: index) ?? true {
                self.deselectItemAtIndex(index)
            }
        } else {
            if self.zl_delegate?.gallery(self, shouldSelectItemAtIndex: index) ?? true {
                self.selectItemAtIndex(index)
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        
        if _highlightedIndex >= 0 {
            self.unhighlightItemAtIndex(_highlightedIndex)
        }
    }
}

// MARK: - Private Functions
private extension ZLHexagonGallery {
    
    private func displayingRectDidChange(rect: CGRect? = nil) {
        guard let delegation = self.zl_delegate else {
            return
        }
        
        // current displaying rect.
        let dispRect = rect ?? _displayingContentRect
        
        // remove out-sight rect cells, add new cell if its rect get into visible rect.
        var isIndexStartEndChanged: Bool = false
        for (i, cellRect) in _cellRects {
            if dispRect.containsVisibleRect(cellRect) {
                if _visibleCells[i] == nil {
                    let cell = delegation.gallery(self, cellForRowAtIndex: i)
                    cell._index = i
                    cell.frame = cellRect
                    delegation.gallery(self, willDisplayCell: cell, forIndex: i)
                    self.addSubview(cell)
                    _visibleCells[i] = cell
                    isIndexStartEndChanged = true
                }
            } else {
                if let cell = _visibleCells[i] {
                    cell.removeFromSuperview()
                    cell.setHighlighted(false)
                    cell.setSelected(false)
                    _visibleCells[i] = nil
                    delegation.gallery(self, didEndDisplayingCell: cell, forIndex: i)
                    Pool.pushCell(cell, forReuseIdentifier: cell._identifier ?? "")
                    isIndexStartEndChanged = true
                }
            }
        }
        
        // do not re-calculate indexes unless visible cells has been modified.
        if isIndexStartEndChanged {
            _displayingIndexStart = _visibleCells.keys.sort().first ?? -1
            _displayingIndexEnd = _visibleCells.keys.sort().last ?? -1
        }
    }
    
    private func removeCells() {
        for view in self.subviews {
            if view is ZLHexagonCell {
                view.removeFromSuperview()
            }
        }
    }
    
    private func highlightItemAtIndex(index: Int, explicit: Bool) {
        if _highlightedIndex == index {
            // do nothing
        } else {
            _visibleCells[_highlightedIndex]?.setHighlighted(false)
            _highlightedIndex = index
            _visibleCells[_highlightedIndex]?.setHighlighted(true)
            if explicit {
                self.zl_delegate?.gallery(self, didHighlightItemAtIndex: index)
            }
        }
    }
    
    private func unhighlightItemAtIndex(index: Int) {
        if _highlightedIndex == index {
            _visibleCells[_highlightedIndex]?.setHighlighted(false)
            self.zl_delegate?.gallery(self, didUnhighlightItemAtIndex: _highlightedIndex)
            _highlightedIndex = -1
        }
    }
    
    private func selectItemAtIndex(index: Int) {
        _visibleCells[index]?.setSelected(true)
        self.zl_delegate?.gallery(self, didSelectItemAtIndex: index)
    }
    
    private func deselectItemAtIndex(index: Int) {
        _visibleCells[index]?.setSelected(false)
        self.zl_delegate?.gallery(self, didDeselectItemAtIndex: index)
    }
    
    private func _distanceBetween(p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dy = p1.y - p2.y
        let dx = p1.x - p2.x
        return sqrt(dy * dy + dx * dx)
    }
    
    private func _centerForRect(rect: CGRect) -> CGPoint {
        return CGPoint(
            x: (CGRectGetMaxX(rect) - CGRectGetMinX(rect)) * 0.5 + rect.origin.x,
            y: (CGRectGetMaxY(rect) - CGRectGetMinY(rect)) * 0.5 + rect.origin.y
        )
    }
}

// MARK: - Reuse pool
extension ZLHexagonGallery {
    
    private struct Pool {
        
        private static var lock: NSLock = NSLock()
        private static var cells: [String: [ZLHexagonCell]] = [:]
        
        static func pushCell(cell: ZLHexagonCell, forReuseIdentifier identifier: String) {
            lock.lock()
            defer {
                lock.unlock()
            }
            
            if cells[identifier] == nil {
                cells[identifier] = []
            }
            
            cells[identifier]?.append(cell)
        }
        
        static func popCellForReuseIdentifier(identifier: String) -> ZLHexagonCell? {
            lock.lock()
            defer {
                lock.unlock()
            }
            
            if cells[identifier]?.count ?? 0 > 0 {
                return cells[identifier]?.removeFirst()
            }
            
            return nil
        }
    }
}

// MARK: - Protocol - Scroll View
extension ZLHexagonGallery: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.displayingRectDidChange()
    }
}




