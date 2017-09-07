//
//  MouseInfoViewController.swift
//  MouseMoveSender
//
//  Created by cmlab on 2017/09/05.
//  Copyright © 2017年 cmlab. All rights reserved.
//

import Cocoa

class MouseInfoViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var ipAddressField: NSTextField!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var xyLabel: NSTextField!

    let mouseInfoModel = MouseInfoModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        ipAddressField.stringValue = mouseInfoModel.ipAddress
        portField.stringValue = String(describing: mouseInfoModel.port ?? 0)
        ipAddressField.delegate = self
        portField.delegate = self
    }

    override func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            if(textField.identifier == "ipAddress") {
                mouseInfoModel.ipAddress = textField.stringValue
                print("IP Address updated: \(mouseInfoModel.ipAddress)")
            } else if(textField.identifier == "port") {
                mouseInfoModel.port = UInt16(textField.stringValue)
                print("port updated: \(mouseInfoModel.port)")
            }
        }
    }

}
