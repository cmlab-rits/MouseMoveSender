//
//  MouseInfoModel.swift
//  MouseMoveSender
//
//  Created by cmlab on 2017/09/06.
//  Copyright © 2017年 cmlab. All rights reserved.
//

import Cocoa
import IOKit

class MouseInfoModel: NSObject {
    var ipAddress: String = "192.168.2.128"
    var port: UInt16? = 11999
    var dx: Int? = nil
    var dy: Int? = nil
}
