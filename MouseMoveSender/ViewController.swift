//
//  ViewController.swift
//  MouseMoveSender
//
//  Created by cmlab on 2017/08/30.
//  Copyright © 2017年 cmlab. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var stackView: NSStackView!
    var mouseVCs = Dictionary<Int,MouseInfoViewController>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NSLog("viewDidLoad")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func addMouseInfoViewController(forDevice device: Int) -> MouseInfoViewController {
        if let mouseInfoViewController = mouseVCs[device] {
            stackView.addArrangedSubview(mouseInfoViewController.view)
            return mouseInfoViewController
        }
        let newVC = MouseInfoViewController.init(nibName: nil, bundle: nil)!
        stackView.addArrangedSubview(newVC.view)
        mouseVCs[device] = newVC
        return newVC
    }
    
    func removeMouseInfoViewController(forDevice device: Int) {
        if let mouseInfoViewController = mouseVCs[device] {
            stackView.removeArrangedSubview(mouseInfoViewController.view)
        }
    }
}

