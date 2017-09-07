        //
//  AppDelegate.swift
//  MouseMoveSender
//
//  Created by cmlab on 2017/08/30.
//  Copyright © 2017年 cmlab. All rights reserved.
//

import Cocoa
import IOKit
import IOKit.usb
import IOKit.hid

let targetDevices = [
    kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
    kIOHIDDeviceUsageKey: kHIDUsage_GD_Mouse
    ] as CFDictionary

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var gIOHIDManagerRef: IOHIDManager?
    var viewController: ViewController?
    var sockmgr: SocketManager? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print(String(format: "applicationDidFinishLaunching: self = \(self)"))
        sockmgr = SocketManager()
        viewController = NSApplication.shared().mainWindow?.contentViewController as? ViewController
        Initialize_HID()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func Initialize_HID() {
        NSLog("Initialize_HID")
        let context: UnsafeMutableRawPointer? = bridge(obj: self)
        gIOHIDManagerRef = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerSetDeviceMatching(gIOHIDManagerRef!,targetDevices);
        IOHIDManagerRegisterDeviceMatchingCallback(gIOHIDManagerRef!, Handle_DeviceMatchingCallback, context)
        IOHIDManagerRegisterDeviceRemovalCallback(gIOHIDManagerRef!, Handle_DeviceRemovalCallback, context)
        
        IOHIDManagerScheduleWithRunLoop(gIOHIDManagerRef!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(gIOHIDManagerRef!, IOOptionBits(kIOHIDOptionsTypeNone))
        
        CFRunLoopRun()
    }
    
    let Handle_DeviceMatchingCallback: IOHIDDeviceCallback = {(context: UnsafeMutableRawPointer?, result: IOReturn, sender: UnsafeMutableRawPointer?, device: IOHIDDevice) in
        let appDelegate: AppDelegate = Unmanaged<AppDelegate>.fromOpaque(context!).takeUnretainedValue()
        print(String(format: "Handle_DeviceMatchingCallback: context = \(appDelegate)"))
        
        let vendor = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as! CFNumber as Int
        let product = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as! CFNumber as Int
        let locationID = IOHIDDeviceGetProperty(device, kIOHIDLocationIDKey as CFString) as! CFNumber as Int
        print(String(format: "Connected: vendor %04x device %04x locationID %08x", vendor, product, locationID))
        
        let mouseInfoVC = appDelegate.viewController?.addMouseInfoViewController(forDevice: locationID)

        let Handle_IOHIDValueCallback: IOHIDValueCallback = {(context, result, sender, value) in
            let appDelegate: AppDelegate? = NSApplication.shared().delegate as? AppDelegate
            let mouseInfoVC: MouseInfoViewController = Unmanaged<MouseInfoViewController>.fromOpaque(context!).takeUnretainedValue()
            let element = IOHIDValueGetElement(value)
            let usage = Int(IOHIDElementGetUsage(element))
            let v = IOHIDValueGetScaledValue(value, IOHIDValueScaleType(kIOHIDValueScaleTypePhysical))
            let xyLabel = mouseInfoVC.xyLabel

            switch(usage) {
            case kHIDUsage_GD_X:
                print("dx: \(v)")
                mouseInfoVC.mouseInfoModel.dx = Int(v)
                break
            case kHIDUsage_GD_Y:
                print("dy: \(v)")
                mouseInfoVC.mouseInfoModel.dy = Int(v)
                break
            default:
                break
            }
            if let x = mouseInfoVC.mouseInfoModel.dx, let y = mouseInfoVC.mouseInfoModel.dy {
                xyLabel?.stringValue = "dx: \(x), dy = \(y)"
                let data = "\(x)|\(y)[/p]"
                appDelegate?.sockmgr?.sendPacket(data: data, ipAddr: mouseInfoVC.mouseInfoModel.ipAddress, port: mouseInfoVC.mouseInfoModel.port)
                mouseInfoVC.mouseInfoModel.dx = nil
                mouseInfoVC.mouseInfoModel.dy = nil
            }
       }
        IOHIDDeviceOpen(device, IOOptionBits(kIOHIDOptionsTypeSeizeDevice))
        IOHIDDeviceRegisterInputValueCallback(device, Handle_IOHIDValueCallback, bridge(obj: mouseInfoVC!))
        
    }
    
    let Handle_DeviceRemovalCallback: IOHIDDeviceCallback = {(context, result, sender, device) in
        print("Disconnected")
        let appDelegate: AppDelegate = Unmanaged<AppDelegate>.fromOpaque(context!).takeUnretainedValue()
        let locationID = IOHIDDeviceGetProperty(device, kIOHIDLocationIDKey as CFString) as! CFNumber as Int
        appDelegate.viewController?.removeMouseInfoViewController(forDevice: locationID)
    }

}

func bridge<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}


