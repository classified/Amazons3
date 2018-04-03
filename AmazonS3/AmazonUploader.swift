//
//  AmazonUploader.swift
//  AmazonS3
//
//  Created by SOTSYS220 on 05/05/17.
//  Copyright © 2017 SOTSYS220. All rights reserved.
//

import UIKit
import AWSS3
import MobileCoreServices

public struct AmazonCredentials {
    var bucketName : String?
    var accessKey  : String?
    var secretKey  : String?
    var region : AWSRegionType?
    
    public init(bucketName : String,accessKey : String, secretKey: String, region : AWSRegionType) {
        self.bucketName = bucketName
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.region = region
    }
}

public class AmazonUploader {
    
    // public vars
    public static let shared = AmazonUploader()
    
    // private vars
    fileprivate static var credentials : AmazonCredentials!
    fileprivate var fileURL = [String]()
    
    fileprivate var currentIndex = 0
    
    public static func setup(credentials : AmazonCredentials){
        AmazonUploader.credentials = credentials
        
        let credentialsProvider: AWSStaticCredentialsProvider = AWSStaticCredentialsProvider(accessKey: credentials.accessKey!, secretKey: credentials.secretKey!)
        let configuration: AWSServiceConfiguration = AWSServiceConfiguration(region: credentials.region!, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        AmazonUploader.shared.initializeUploader()
    }
    
    private init() {
        guard AmazonUploader.credentials != nil,AmazonUploader.credentials.accessKey != nil ,AmazonUploader.credentials.secretKey != nil,AmazonUploader.credentials.bucketName != nil else {
            fatalError("Error - you must call setup before accessing AmazonUploader")
        }
        
        //Regular initialisation using param
    }
    
    //MARK: Intialize local variables
    fileprivate func initializeUploader(){
        if validateData() {
            
            fileURL.removeAll()
            currentIndex = 0
            
        }
        
    }
    
    fileprivate func validateData() -> Bool {
        if AmazonUploader.credentials.bucketName?.count == 0 {
            fatalError("bucket name can not be blank")
        }
        
        if AmazonUploader.credentials.accessKey?.count == 0 {
            fatalError("access key can not be blank")
        }
        
        if AmazonUploader.credentials.secretKey?.count == 0 {
            fatalError("secret key can not be blank")
        }
        
        return true
    }
    
    
    //MARK: Upload with normal manager
    public func uploadFile(fileUrl url: URL,keyName name:String , permission ACL:AWSS3ObjectCannedACL , completed: @escaping (_ isSuccess: Bool,_ url: String?, _ error : Error?) -> Void) {
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = AmazonUploader.credentials.bucketName!
        uploadRequest?.acl = ACL
        uploadRequest?.key = "\(name)"
        uploadRequest?.contentType = mimeTypeFromFileExtension(path: url.lastPathComponent)
        
        uploadRequest?.body = url
        // we will track progress through an AWSNetworkingUploadProgressBlock
        uploadRequest?.uploadProgress = {(bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) in
            
        }
        
        let transferManager:AWSS3TransferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block:{
            task -> AnyObject in
            if(task.error != nil){
                completed(false,nil,task.error)
            }else{
                completed(true,"https://\(AmazonUploader.credentials.bucketName!).s3.amazonaws.com/\(name)",nil)
                
            }
            return "" as AnyObject
        })
    }
    
    //MARK: Upload with normal manager
    public func uploadMultipleFiles(fileUrl urls: [URL], keyName name:[String] , permission ACL:AWSS3ObjectCannedACL , completed: ((_ isSuccess: Bool, _ url: [String]? , _ error : Error?) -> Void)?) {
        
        if AmazonUploader.shared.currentIndex == urls.count {
            completed!(true,AmazonUploader.shared.fileURL,nil)
            
            AmazonUploader.shared.initializeUploader()
        }else{
            uploadMultipleSingleFile(fileUrl: urls[AmazonUploader.shared.currentIndex], keyName: name[AmazonUploader.shared.currentIndex], permission: ACL) { isSuccess in
                if isSuccess {
                    self.uploadMultipleFiles(fileUrl: urls, keyName: name, permission: ACL, completed: completed)
                }else{
                    completed!(true,AmazonUploader.shared.fileURL,nil)
                    
                    AmazonUploader.shared.initializeUploader()
                }
            }
        }
        
    }
    
    //MARK: Upload with normal manager
    fileprivate func uploadMultipleSingleFile(fileUrl url: URL,keyName name:String , permission ACL:AWSS3ObjectCannedACL , completed: @escaping (_ isSuccess: Bool) -> Void) {
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = AmazonUploader.credentials.bucketName!
        uploadRequest?.acl = ACL
        uploadRequest?.key = "\(name)"
        uploadRequest?.contentType = mimeTypeFromFileExtension(path: url.lastPathComponent)
        
        uploadRequest?.body = url
        // we will track progress through an AWSNetworkingUploadProgressBlock
        uploadRequest?.uploadProgress = {(bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) in
            
        }
        
        let transferManager:AWSS3TransferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block:{
            task -> AnyObject in
            if(task.error != nil){
                completed(false)
            }else{
                AmazonUploader.shared.currentIndex += 1
                AmazonUploader.shared.fileURL.append("https://\(AmazonUploader.credentials.bucketName!).s3.amazonaws.com/\(name)")
                completed(true)
                
            }
            return "" as AnyObject
        })
    }
    
    
    //MARK: Delete files from S3
    public func deleteUploadedFiles(keyName: String , completed: @escaping (_ isSuccess: Bool, _ error : Error?) -> Void){
        
        let s3 = AWSS3.default()
        
        let deleteObjectRequest = AWSS3DeleteObjectRequest()
        
        deleteObjectRequest?.bucket = AmazonUploader.credentials.bucketName!
        
        deleteObjectRequest?.key = keyName
        
        s3.deleteObject(deleteObjectRequest!) { (task, error) in
            if error != nil {
                completed(false,error)
                
            }else{
                completed(true,nil)
            }
            
        }
        
    }
    
    //MARK: Upload files with background sessions
    public func uploadFileSession(fileUrl url: URL,keyName name:String , completed: @escaping (_ isSuccess: Bool, _ url: URL? , _ error : Error?) -> Void) {
        
        let transferUtility = AWSS3TransferUtility.default()
        
        let expression = AWSS3TransferUtilityUploadExpression()
        
        expression.setValue("public-read", forRequestParameter: "x-amz-acl")
        
        
        transferUtility.uploadFile(url,
                                   bucket: AmazonUploader.credentials.bucketName!,
                                   key: name,
                                   contentType: mimeTypeFromFileExtension(path: url.lastPathComponent),
                                   expression: expression) { task, maybeError in
                                    if let error = maybeError {
                                        completed(false,nil,error)
                                    } else {
                                        completed(true,URL(string: "https://\(AmazonUploader.credentials.bucketName!).s3.amazonaws.com/\(name)"),nil)
                                    }
            }
            .continueWith { task in
                if let error = task.error {
                    completed(false,nil,task.error)
                }
                
                if let _ = task.result {
                    
                }
                
                return nil
        }
        
    }
    
    //MARK: Download file
    public func downloadFile(keyName name:String ,progressBlock: @escaping (_ task:AWSS3TransferUtilityTask,
        _ progress:Progress) -> Void, completed: @escaping (_ isSuccess: Bool, _ url: URL? , _ error : Error?) -> Void) {
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
            // Do something e.g. Update a progress bar.
            progressBlock(task,progress)
            
        })
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        completionHandler = { (task, URL, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Alert a user for transfer completion.
                // On failed downloads, `error` contains the error object.
                completed(error != nil ? false : true, URL,error)
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.downloadData(
            fromBucket: AmazonUploader.credentials.bucketName!,
            key: name,
            expression: expression,
            completionHandler: completionHandler
            ).continueWith {
                (task) -> AnyObject! in if let error = task.error {
                    
                }
                
                if let _ = task.result {
                    // Do something with downloadTask.
                }
                return nil
        }
    }
    
    
    public func checkPendingUploads(){
        let completion: AWSS3TransferUtilityUploadCompletionHandlerBlock = { task, maybeError in
            if let error = maybeError {
                task.cancel()
                // TODO we should re-trigger an upload task for this file
            } else {
                
            }
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.enumerateToAssignBlocks(forUploadTask: { (task, progressPointer, completionPointer) -> Void in
            completionPointer?.pointee = completion
        }, downloadTask: nil)
        
        
        transferUtility.getUploadTasks().continueWith { task in
            if let tasks = task.result as? [AWSS3TransferUtilityUploadTask] {
                if tasks.isEmpty {
                    
                } else {
                    
                    for task in tasks {
                        
                        task.resume()
                    }
                    
                }
            }
            return nil
        }
    }
    
    
    fileprivate func mimeTypeFromFileExtension(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
}
