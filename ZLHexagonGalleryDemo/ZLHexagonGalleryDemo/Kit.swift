//
//  Kit.swift
//  ZLNetworkDemo
//
//  Created by 子澜 on 16/4/26.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

let screenWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
let screenHeight: CGFloat = UIScreen.mainScreen().bounds.size.height

// MARK: - Colour

func RGB(rgb: Int) -> UIColor {
    return RGB(rgb, rgb, rgb)
}

func RGB(red: Int, _ green: Int, _ blue: Int, alpha: CGFloat = 1.0) -> UIColor {
    return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
}

// MARK: - Miscellaneous

func ZLLogGetContent(content: AnyObject? = nil, functionName: String = __FUNCTION__) -> String {
    let contentString = (content == nil ? "nil" : "\(content!)")
    return "(｡･ω･｡)ﾉ [\(functionName)] \(contentString)"
}

func ZLLog(content: AnyObject? = nil, functionName: String = __FUNCTION__, var fileName: String = __FILE__) {
    fileName = fileName.componentsSeparatedByString("/").last ?? ""
    let contentString = (content == nil ? "nil" : "\(content!)")
    print("(｡･ω･｡)ﾉ \(fileName) [\(functionName)] \(contentString)")
}

func PrintThread(tag: AnyObject, functionName: String = __FUNCTION__) {
    let timeStamp = NSDate().timeIntervalSince1970
    print("[\(timeStamp):\(functionName)] \(tag) " + (NSThread.isMainThread() ? "Mainthread" : "Subthread"))
}

func TimeStamp() -> NSTimeInterval {
    return NSDate().timeIntervalSince1970
}

// MARK: - Extension

extension Array {
    
    func objectAtIndex(index: Int) -> Element? {
        if 0 <= index && index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
}

extension CGRect {
    
    func containsVisibleRect(rect: CGRect) -> Bool {
        let intersection = CGRectIntersection(self, rect)
        return (intersection.width > 0 && intersection.height > 0)
    }
}

// MARK: - Thread

func zl_executeInMain(execution: (() -> Void)) {
    if NSThread.isMainThread() {
        execution()
    } else {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, 0),
            dispatch_get_main_queue(),
            execution)
    }
}

func zl_executeInThread(execution: (() -> Void)) {
    if NSThread.isMainThread() {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, 0),
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            execution)
    } else {
        execution()
    }
}

func zl_delayExecuteInMain(delay: NSTimeInterval, execution: (() -> Void)) {
    if delay == 0 {
        zl_executeInMain(execution)
    } else {
        let dispatchTime: dispatch_time_t = dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(
            dispatchTime,
            dispatch_get_main_queue(),
            execution)
    }
}

func zl_delayExecuteInThread(delay: NSTimeInterval, execution: (() -> Void)) {
    if delay == 0 {
        zl_executeInThread(execution)
    } else {
        let dispatchTime: dispatch_time_t = dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(
            dispatchTime,
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            execution)
    }
}
