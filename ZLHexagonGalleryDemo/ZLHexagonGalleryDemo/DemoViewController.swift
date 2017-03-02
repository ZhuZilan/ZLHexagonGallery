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
    
    fileprivate weak var headerView: UIView!
    fileprivate weak var headerLabel: UILabel!
    fileprivate weak var actionButton: UIButton!
    fileprivate weak var reloadButton: UIButton!
    fileprivate weak var hexagonGallery: ZLHexagonGallery!
    
// MARK: - Data
    
    fileprivate var dataSource: [DataModel] = []
    fileprivate var logContent: String = ""
    
    fileprivate var logEnabled: Bool {
        get {
            return actionButton.isSelected
        }
    }
    
// MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.edgesForExtendedLayout = UIRectEdge()
        self.createViews()
        self.createConstraints()
        self.createInteractions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadButtonDidClick(self.reloadButton)
    }
    
    /** Create and bind views. */
    fileprivate func createViews() {
        
        headerView = {
            let view = UIView()
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = RGB(66, 70, 73)
            
            headerLabel = {
                let label = UILabel()
                view.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = UIFont.systemFont(ofSize: 20)
                label.text = "六棱验证"
                label.textColor = RGB(230)
                label.textAlignment = NSTextAlignment.center
                return label
            } ()
            
            actionButton = {
                let button = UIButton(type: UIButtonType.custom)
                view.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle("LOG", for: UIControlState())
                button.setTitleColor(RGB(188), for: UIControlState())
                button.setTitleColor(RGB(127), for: UIControlState.highlighted)
                button.setTitleColor(RGB(230), for: UIControlState.selected)
                return button
            } ()
            
            reloadButton = {
                let button = UIButton(type: UIButtonType.custom)
                view.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle("RLD", for: UIControlState())
                button.setTitleColor(RGB(230), for: UIControlState())
                button.setTitleColor(RGB(127), for: UIControlState.highlighted)
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
    fileprivate func createConstraints() {
        let bspa: CGFloat = CGFloat(20)
        let sspa: CGFloat = CGFloat(8)
        let vflmetrics: [String: AnyObject] = [
            "staSize": CGFloat(20) as AnyObject,
            "navSize": CGFloat(44) as AnyObject,
            "bspa": bspa as AnyObject,
            "sspa": sspa as AnyObject
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
            constraints += NSLayoutConstraint.constraints(withVisualFormat: vflformat, options: [], metrics: vflmetrics, views: vflviews)
        }
        
        self.view.addConstraints(constraints)
    }
    
    fileprivate func createInteractions() {
        self.reloadButton.addTarget(self, action: #selector(DemoViewController.reloadButtonDidClick(_:)), for: UIControlEvents.touchUpInside)
        self.actionButton.addTarget(self, action: #selector(DemoViewController.actionButtonDidClick(_:)), for: UIControlEvents.touchUpInside)
        //self.logScrollView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
// MARK: - Interaction
    
    fileprivate var reloadingCountTag: Bool = false
    func reloadButtonDidClick(_ sender: UIButton) {
        self.clearLog()
        reloadingCountTag = !reloadingCountTag
        dataSource = []
        let reloadingCount: Int = reloadingCountTag ? 30 : 32
        for i in 0..<reloadingCount {
            let model = DataModel(index: i)
            dataSource.append(model)
        }
        hexagonGallery.reloadData()
    }
    
    func actionButtonDidClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            self.clearLog()
        }
    }

}

// MARK: - Protocol - Hexagon
extension DemoViewController: ZLHexagonGalleryDelegate {
    
    func galleryNumberOfItems(_ gallery: ZLHexagonGallery) -> Int {
        let count = dataSource.count
        self.appendLog("\(count)")
        return count
    }
    
    func gallery(_ gallery: ZLHexagonGallery, cellForRowAtIndex index: Int) -> ZLHexagonCell {
        self.appendLog("\(index)")
        let cell = gallery.dequeueReusableCellWithIdentifier("CustomHexagonCell") as! CustomHexagonCell
        cell.fillModel(dataSource[index])
        return cell
    }
    
    func gallery(_ gallery: ZLHexagonGallery, willDisplayCell cell: ZLHexagonCell, forIndex index: Int) {
        self.appendLog("\(index)")
    }
    
    func gallery(_ gallery: ZLHexagonGallery, didEndDisplayingCell cell: ZLHexagonCell, forIndex index: Int) {
        self.appendLog("\(index)")
    }
    
    func gallery(_ gallery: ZLHexagonGallery, shouldHightlightItemAtIndex index: Int) -> Bool {
        self.appendLog("\(index)")
        return true
    }
    
    func gallery(_ gallery: ZLHexagonGallery, shouldSelectItemAtIndex index: Int) -> Bool {
        self.appendLog("\(index)")
        return true
    }
    
    func gallery(_ gallery: ZLHexagonGallery, shouldDeselectItemAtIndex index: Int) -> Bool {
        self.appendLog("\(index)")
        return true
    }
    
    func gallery(_ gallery: ZLHexagonGallery, didHighlightItemAtIndex index: Int) {
        self.appendLog("\(index)")
    }
    
    func gallery(_ gallery: ZLHexagonGallery, didUnhighlightItemAtIndex index: Int) {
        self.appendLog("\(index)")
    }
    
    func gallery(_ gallery: ZLHexagonGallery, didSelectItemAtIndex index: Int) {
        self.appendLog("\(index)")
        
        dataSource[index].selected = true
    }
    
    func gallery(_ gallery: ZLHexagonGallery, didDeselectItemAtIndex index: Int) {
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
    
    func appendLog(_ content: String, functionName: String = #function) {
        guard logEnabled else {
            return
        }
        
        ZLLog(content, functionName: functionName)
    }
}

private class CustomHexagonCell: ZLHexagonCell {
    
    func fillModel(_ model: DataModel) {
        if self.imageView.image == nil {
            self.imageView?.image = UIImage(named: "icon_hexagon")
            self.imageView.layer.borderColor = RGB(0, 0, 0, alpha: 0.25).cgColor
        }
        
        self.setSelected(model.selected)
    }
}




