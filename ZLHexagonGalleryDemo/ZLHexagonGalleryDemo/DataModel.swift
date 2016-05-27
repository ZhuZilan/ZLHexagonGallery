//
//  DataModel.swift
//  ZLHexagonGalleryDemo
//
//  Created by 子澜 on 16/5/5.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

class DataModel {
    
    var index: Int = 0
    var selected: Bool = false
    
    init(index: Int) {
        self.index = index
    }
}

extension DataModel {
    
    var content: String {
        get {
            return "\(index)"
        }
    }
}
