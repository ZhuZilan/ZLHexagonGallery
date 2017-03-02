//
//  Kit.swift
//  ZLNetworkDemo
//
//  Created by 子澜 on 16/4/26.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

let screenWidth: CGFloat = UIScreen.main.bounds.size.width
let screenHeight: CGFloat = UIScreen.main.bounds.size.height

// MARK: - Colour

func RGB(_ rgb: Int) -> UIColor {
    return RGB(rgb, rgb, rgb)
}

func RGB(_ red: Int, _ green: Int, _ blue: Int, alpha: CGFloat = 1.0) -> UIColor {
    return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
}

// MARK: - Miscellaneous

func ZLLogGetContent(_ content: AnyObject? = nil, functionName: String = #function) -> String {
    let contentString = (content == nil ? "nil" : "\(content!)")
    return "(｡･ω･｡)ﾉ [\(functionName)] \(contentString)"
}

func ZLLog(_ content: Any? = nil, functionName: String = #function, fileName: String = #file) {
    var fileName = fileName
    fileName = fileName.components(separatedBy: "/").last ?? ""
    let contentString = (content == nil ? "nil" : "\(content!)")
    print("(｡･ω･｡)ﾉ \(fileName) [\(functionName)] \(contentString)")
}

func PrintThread(_ tag: AnyObject, functionName: String = #function) {
    let timeStamp = Date().timeIntervalSince1970
    print("[\(timeStamp):\(functionName)] \(tag) " + (Thread.isMainThread ? "Mainthread" : "Subthread"))
}

func TimeStamp() -> TimeInterval {
    return Date().timeIntervalSince1970
}

// MARK: - Extension

extension Array {
    
    func objectAtIndex(_ index: Int) -> Element? {
        if 0 <= index && index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
}

extension CGRect {
    
    func containsVisibleRect(_ rect: CGRect) -> Bool {
        let intersection = self.intersection(rect)
        return (intersection.width > 0 && intersection.height > 0)
    }
}

// MARK: - Thread

func zl_executeInMain(_ execution: @escaping (() -> Void)) {
    if Thread.isMainThread {
        execution()
    } else {
        DispatchQueue.main.async(execute: execution)
    }
}

func zl_executeInThread(_ execution: @escaping (() -> Void)) {
    if Thread.isMainThread {
        let queueLabel = "ZL.Util.GlobalQueueLabel"
        DispatchQueue(label: queueLabel).async(execute: execution)
    } else {
        execution()
    }
}

func zl_delayExecuteInMain(_ delay: TimeInterval, execution: @escaping (() -> Void)) {
    if delay == 0 {
        zl_executeInMain(execution)
    } else {
        let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(1000 * delay))
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: execution)
    }
}

func zl_delayExecuteInThread(_ delay: TimeInterval, execution: @escaping (() -> Void)) {
    if delay == 0 {
        zl_executeInThread(execution)
    } else {
        let queueLabel = "ZL.Util.GlobalQueueLabel"
        let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(1000 * delay))
        DispatchQueue(label: queueLabel).asyncAfter(deadline: deadline, execute: execution);
    }
}
