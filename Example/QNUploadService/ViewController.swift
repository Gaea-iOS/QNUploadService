//
//  ViewController.swift
//  QNUploadService
//
//  Created by wangxiaotao on 06/19/2017.
//  Copyright (c) 2017 wangxiaotao. All rights reserved.
//

import UIKit
import QNUploadService

class ViewController: UIViewController {
    
    let defaultToken = "TMmDt0I79p1bJYVQueTDFQJr8rl9sJAS1slnTUNq:YtVbLvwYnPC7QWNHYl2QTZ7ksEc=:eyJkZWFkbGluZSI6MzY0NDI5MTM5Miwic2NvcGUiOiJhbWF0ZXVyIn0="
    
    let service = QNUploadService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        service.upload(UIImage(named: "test")!, forKey: "dajkdf/djald/test4", token: defaultToken, progress: { progress in
            print("progress = \(progress)")
        }, success: { (key) in
            print("success key = \(key)")
        }) { (error) in
            print("failure error = \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


