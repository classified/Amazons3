//
//  ViewController.swift
//  AmazonS3Demo
//
//  Created by SOTSYS220 on 05/05/17.
//  Copyright © 2017 SOTSYS220. All rights reserved.
//

import UIKit
import AmazonS3

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url = write(text: "Test", to: "test")
        
        let credentials = AmazonCredentials(bucketName: "YOUR BUCKET NAME", accessKey: "YOUR ACCESS KEY", secretKey: "YOUR SECRET KEY", region: .uswest1)
        
        AmazonUploader.setup(credentials: credentials)
        
        AmazonUploader.shared.uploadFile(fileUrl: url!, keyName: "mobile/test/abc.txt", permission: .private) { (success, url, error) in
            
            if success {
                print("success")
            }else{
                print(error!)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func write(text: String, to fileNamed: String, folder: String = "SavedFiles") -> URL? {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return  nil}
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return nil}
        try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
        let file = writePath.appendingPathComponent(fileNamed + ".txt")
        try? text.write(to: file, atomically: false, encoding: String.Encoding.utf8)
        
        return file
    }

}

