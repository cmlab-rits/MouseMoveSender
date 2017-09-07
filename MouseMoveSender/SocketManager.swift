//
//  SocketManager.swift
//  MouseMoveSender
//
//  Created by cmlab on 2017/09/07.
//  Copyright © 2017年 cmlab. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

class SocketManager: NSObject, GCDAsyncUdpSocketDelegate {
    fileprivate var _socket: GCDAsyncUdpSocket?
    fileprivate var socket: GCDAsyncUdpSocket? {
        get {
            if _socket == nil {
                _socket = getNewSocket()
            }
            return _socket
        }
        set {
            if _socket != nil {
                _socket?.close()
            }
            _socket = newValue
        }
    }
    
    fileprivate func getNewSocket() -> GCDAsyncUdpSocket? {
        let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try sock.enableBroadcast(true)
        } catch _ as NSError {
            NSLog(">>>Issue with setting up a socket")
            return nil
        }
        return sock
    }
    
    func sendPacket(data: String, ipAddr: String, port: UInt16?) {
        if port != nil {
            socket?.send(data.data(using: String.Encoding.ascii)!, toHost: ipAddr, port: port!, withTimeout: 2, tag: 0)
            NSLog("Data sent to \(ipAddr):\(port!): \(data)")
        }
    }
}
