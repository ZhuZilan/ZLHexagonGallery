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
    
    fileprivate var _registeredCellTypes: [String: AnyClass] = [:]
    
    fileprivate var _count: Int = 0
    
    fileprivate var _cellRects: [Int: CGRect] = [:]
    
    fileprivate var _visibleCellRects: [(Int, CGRect)] {
        get {
            return _cellRects.filter({ (i, rect) -> Bool in
                return _displayingContentRect.containsVisibleRect(rect)
            })
        }
    }
    
    fileprivate var _visibleCells: [Int: ZLHexagonCell] = [:]
    
    fileprivate var _displayingContentRect: CGRect {
        get {
            return CGRect(x: contentOffset.x, y: contentOffset.y, width: bounds.width, height: bounds.height)
        }
    }
    
    fileprivate var _highlightedIndex: Int = -1
    
    internal var _displayingIndexStart: Int = -1
    internal var _displayingIndexEnd: Int = -1
    
// MARK: - Init
    
    init() {
        super.init(frame: CGRect.zero)
        self.delegate = self
        self.alwaysBounceVertical = true
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
// MARK: - Interface
    
    func registerClass(_ cls: AnyClass?, forCellWithReuseIdentifier reuseIdentifier: String) {
        guard let cls = cls else {
            return
        }
        
        self._registeredCellTypes[reuseIdentifier] = cls
    }
    
    func dequeueReusableCellWithIdentifier(_ identifier: String) -> ZLHexagonCell? {
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
            numberOfItemsPerLine += 1
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
            self.contentSize = validRect.union(CGRect(x: 0, y: 0,
                width: validRect.width, height: CGFloat(numberOfGroups) * heightOfGroup + (lastGroupHasTwoLine ? cellHeight * 0.25 : -cellSideLength))).size
        }
        
        // calculate cell rects
        for i in 0..<_count {
            let groupIndex: Int = i / numbersPerGroup
            let itemIndexInGroup: Int = i % numbersPerGroup
            let isFirstLine: Bool = itemIndexInGroup < Int(numbersPerGroup/2)
            let itemIndexInLine: Int = isFirstLine ? itemIndexInGroup : itemIndexInGroup - Int(numbersPerGroup/2)
            let cellRect = CGRect(
                x: cellWidth * (CGFloat(itemIndexInLine) + (isFirstLine ? 0.5 : 0)) + CGFloat(itemIndexInLine) * interItemSpacing,
                y: cellHeight * (isFirstLine ? 0 : 0.75) + heightOfGroup * CGFloat(groupIndex) + (isFirstLine ? 0 : interItemSpacing),
                width: cellWidth,
                height: cellHeight)
            _cellRects[i] = cellRect
        }
        
        self.displayingRectDidChange()
        
    }
    
    func visibleCells() -> [ZLHexagonCell] {
        return _visibleCells.values.sorted(by: { (firstCell, secondCell) -> Bool in
            return firstCell._index < secondCell._index
        })
    }
    
// MARK: - Touches Handle
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touchPoint = touches.first?.location(in: self) else {
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
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
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if _highlightedIndex >= 0 {
            self.unhighlightItemAtIndex(_highlightedIndex)
        }
    }
}

// MARK: - Private Functions
private extension ZLHexagonGallery {
    
    func displayingRectDidChange(_ rect: CGRect? = nil) {
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
            _displayingIndexStart = _visibleCells.keys.sorted().first ?? -1
            _displayingIndexEnd = _visibleCells.keys.sorted().last ?? -1
        }
    }
    
    func removeCells() {
        for view in self.subviews {
            if view is ZLHexagonCell {
                view.removeFromSuperview()
            }
        }
    }
    
    func highlightItemAtIndex(_ index: Int, explicit: Bool) {
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
    
    func unhighlightItemAtIndex(_ index: Int) {
        if _highlightedIndex == index {
            _visibleCells[_highlightedIndex]?.setHighlighted(false)
            self.zl_delegate?.gallery(self, didUnhighlightItemAtIndex: _highlightedIndex)
            _highlightedIndex = -1
        }
    }
    
    func selectItemAtIndex(_ index: Int) {
        _visibleCells[index]?.setSelected(true)
        self.zl_delegate?.gallery(self, didSelectItemAtIndex: index)
    }
    
    func deselectItemAtIndex(_ index: Int) {
        _visibleCells[index]?.setSelected(false)
        self.zl_delegate?.gallery(self, didDeselectItemAtIndex: index)
    }
    
    func _distanceBetween(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dy = p1.y - p2.y
        let dx = p1.x - p2.x
        return sqrt(dy * dy + dx * dx)
    }
    
    func _centerForRect(_ rect: CGRect) -> CGPoint {
        return CGPoint(
            x: (rect.maxX - rect.minX) * 0.5 + rect.origin.x,
            y: (rect.maxY - rect.minY) * 0.5 + rect.origin.y
        )
    }
}

// MARK: - Reuse pool
extension ZLHexagonGallery {
    
    fileprivate struct Pool {
        
        fileprivate static var lock: NSLock = NSLock()
        fileprivate static var cells: [String: [ZLHexagonCell]] = [:]
        
        static func pushCell(_ cell: ZLHexagonCell, forReuseIdentifier identifier: String) {
            lock.lock()
            defer {
                lock.unlock()
            }
            
            if cells[identifier] == nil {
                cells[identifier] = []
            }
            
            cells[identifier]?.append(cell)
        }
        
        static func popCellForReuseIdentifier(_ identifier: String) -> ZLHexagonCell? {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.displayingRectDidChange()
    }
}




