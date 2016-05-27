//
//  DemoViewController.swift
//  ZLHexagonGalleryDemo
//
//  Created by 子澜 on 16/5/4.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
    
// MARK: - Control
    
    private weak var headerView: UIView!
    private weak var headerLabel: UILabel!
    private weak var actionButton: UIButton!
    private weak var reloadButton: UIButton!
    private weak var hexagonGallery: ZLHexagonGallery!
    
// MARK: - Data
    
    private var dataSource: [DataModel] = []
    private var logContent: String = ""
    
    private var logEnabled: Bool {
        get {
            return actionButton.selected
        }
    }
    
// MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.edgesForExtendedLayout = UIRectEdge.None
        self.createViews()
        self.createConstraints()
        self.createInteractions()
        self.clearLog()
    }
    
    /** Create and bind views. */
    private func createViews() {
        
        headerView = {
            let view = UIView()
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = RGB(66, 70, 73)
            
            headerLabel = {
                let label = UILabel()
                view.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = UIFont.systemFontOfSize(20)
                label.text = "六棱验证"
                label.textColor = RGB(230)
                label.textAlignment = NSTextAlignment.Center
                return label
            } ()
            
            actionButton = {
                let button = UIButton(type: UIButtonType.Custom)
                view.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle("LOG", forState: UIControlState.Normal)
                button.setTitleColor(RGB(188), forState: UIControlState.Normal)
                button.setTitleColor(RGB(127), forState: UIControlState.Highlighted)
                button.setTitleColor(RGB(230), forState: UIControlState.Selected)
                return button
            } ()
            
            reloadButton = {
                let button = UIButton(type: UIButtonType.Custom)
                view.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle("RLD", forState: UIControlState.Normal)
                button.setTitleColor(RGB(230), forState: UIControlState.Normal)
                button.setTitleColor(RGB(127), forState: UIControlState.Highlighted)
                return button
            } ()
            
            return view
        } ()
        
        hexagonGallery = {
            let spacing = CGFloat(8)
            let padding = CGFloat(20)
            let gallery = ZLHexagonGallery()
            self.view.addSubview(gallery)
            gallery.translatesAutoresizingMaskIntoConstraints = false
            gallery.interItemSpacing = spacing
            gallery.cellWidth = floor((screenWidth - 2 * padding - 2 * spacing) / 3)
            gallery.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            gallery.registerClass(CustomHexagonCell.self, forCellWithReuseIdentifier: "CustomHexagonCell")
            gallery.zl_delegate = self
            return gallery
        } ()
    }
    
    /** Make constraints using visual format language. */
    private func createConstraints() {
        let bspa: CGFloat = CGFloat(20)
        let sspa: CGFloat = CGFloat(8)
        let vflmetrics: [String: AnyObject] = [
            "staSize": CGFloat(20),
            "navSize": CGFloat(44),
            "bspa": bspa,
            "sspa": sspa
        ]
        let vflviews: [String: AnyObject] = [
            "headerView": headerView,
            "headerLabel": headerLabel,
            "actionButton": actionButton,
            "reloadButton": reloadButton,
            "hexagonGallery": hexagonGallery
        ]
        let vflformats: [String] = [
            "H:|-0-[headerView]-0-|",
            "H:|-0-[headerLabel]-0-|",
            "H:|-0@750-[reloadButton(==navSize)]-0-[actionButton(==navSize)]-0-|",
            "H:|-0-[hexagonGallery]-0-|",
            "V:|-staSize-[headerLabel]-0-|",
            "V:|-staSize-[reloadButton]-0-|",
            "V:|-staSize-[actionButton]-0-|",
            "V:|-0-[headerView(==64)]-0-[hexagonGallery]-0-|"
        ]
        
        var constraints: [NSLayoutConstraint] = []
        for vflformat in vflformats {
            constraints += NSLayoutConstraint.constraintsWithVisualFormat(vflformat, options: [], metrics: vflmetrics, views: vflviews)
        }
        
        self.view.addConstraints(constraints)
    }
    
    private func createInteractions() {
        self.reloadButton.addTarget(self, action: "reloadButtonDidClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.actionButton.addTarget(self, action: "actionButtonDidClick:", forControlEvents: UIControlEvents.TouchUpInside)
        //self.logScrollView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
// MARK: - Interaction
    
    private var __reloadingCountTag: Bool = false
    func reloadButtonDidClick(sender: UIButton) {
        self.clearLog()
        __reloadingCountTag = !__reloadingCountTag
        dataSource = []
        let reloadingCount: Int = __reloadingCountTag ? 30 : 32
        for i in 0..<reloadingCount {
            let model = DataModel(index: i)
            dataSource.append(model)
        }
        hexagonGallery.reloadData()
    }
    
    func actionButtonDidClick(sender: UIButton) {
        sender.selected = !sender.selected
        if !sender.selected {
            self.clearLog()
        }
    }

}

// MARK: - Protocol - Hexagon
extension DemoViewController: ZLHexagonGalleryDelegate {
    
    func galleryNumberOfItems(gallery: ZLHexagonGallery) -> Int {
        let count = dataSource.count
        self.appendLog("\(count)")
        return count
    }
    
    func gallery(gallery: ZLHexagonGallery, cellForRowAtIndex index: Int) -> ZLHexagonCell {
        self.appendLog("\(index)")
        let cell = gallery.dequeueReusableCellWithIdentifier("CustomHexagonCell") as! CustomHexagonCell
        cell.fillModel(dataSource[index])
        return cell
    }
    
    func gallery(gallery: ZLHexagonGallery, willDisplayCell cell: ZLHexagonCell, forIndex index: Int) {
        self.appendLog("\(index)")
    }
    
    func gallery(gallery: ZLHexagonGallery, didEndDisplayingCell cell: ZLHexagonCell, forIndex index: Int) {
        self.appendLog("\(index)")
    }
    
    func gallery(gallery: ZLHexagonGallery, shouldHightlightItemAtIndex index: Int) -> Bool {
        self.appendLog("\(index)")
        return true
    }
    
    func gallery(gallery: ZLHexagonGallery, shouldSelectItemAtIndex index: Int) -> Bool {
        self.appendLog("\(index)")
        return true
    }
    
    func gallery(gallery: ZLHexagonGallery, shouldDeselectItemAtIndex index: Int) -> Bool {
        self.appendLog("\(index)")
        return true
    }
    
    func gallery(gallery: ZLHexagonGallery, didHighlightItemAtIndex index: Int) {
        self.appendLog("\(index)")
    }
    
    func gallery(gallery: ZLHexagonGallery, didUnhighlightItemAtIndex index: Int) {
        self.appendLog("\(index)")
    }
    
    func gallery(gallery: ZLHexagonGallery, didSelectItemAtIndex index: Int) {
        self.appendLog("\(index)")
        
        dataSource[index].selected = true
    }
    
    func gallery(gallery: ZLHexagonGallery, didDeselectItemAtIndex index: Int) {
        self.appendLog("\(index)")
        
        dataSource[index].selected = false
    }
}

// MARK: - Log
extension DemoViewController {
    
    func clearLog() {
        //self.logContent = ""
        //self.logScrollLabel.text = logContent
    }
    
    func appendLog(content: String, functionName: String = __FUNCTION__) {
        guard logEnabled else {
            return
        }
        
        ZLLog(content, functionName: functionName)
    }
}

private class CustomHexagonCell: ZLHexagonCell {
    
    func fillModel(model: DataModel) {
        if self.imageView.image == nil {
            self.imageView?.image = UIImage(named: "icon_hexagon")
            self.imageView.layer.borderColor = RGB(0, 0, 0, alpha: 0.25).CGColor
        }
        
        self.setSelected(model.selected)
    }
}




