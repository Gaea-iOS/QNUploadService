//
//  ImageUploaderType+QN.swift
//  Pods
//
//  Created by 王小涛 on 2017/6/19.
//
//

import Foundation
import Qiniu
import HappyDNS
import Photos
import WXImageCompress

public protocol ImageCompressor {
    func compress(image: UIImage) -> UIImage
}

public struct WXImageCompressor: ImageCompressor {
    public func compress(image: UIImage) -> UIImage {
        return image.wxCompress()
    }
}

public class QNUploadService {
    
    struct QN {
        static let uploadManager: QNUploadManager = {
            let config = QNConfiguration.build { builder in
                let resolvers = [QNResolver.system()!]
                let dns = QNDnsManager(resolvers, networkInfo: QNNetworkInfo.normal())
                builder?.setZone(QNAutoZone(https: true, dns: dns))
                let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
                builder?.recorder = try? QNFileRecorder(folder: path)
            }
            return QNUploadManager(configuration: config)!
        }()
    }
    
    public init() {}
    
    public func upload(_ data: Data,
                       forKey key: String? = nil,
                       token: String,
                       progress progressBlock: ((Float) -> Void)? = nil,
                       success: ((_ key: String) -> Void)? = nil,
                       failure: ((NSError) -> Void)? = nil) {
        
        let option = options(progress: progressBlock)
        let complete = completed(success: success, failure: failure)
        QN.uploadManager.put(data, key: key, token: token, complete: complete, option: option)
    }

    public func upload(_ image: UIImage, forKey key: String? = nil, token: String, compressor: ImageCompressor = WXImageCompressor(), progress: ((Float) -> Void)? = nil, success: ((String) -> Void)? = nil, failure: ((NSError) -> Void)? = nil) {
        
        let compressedImage = compressor.compress(image: image)
        
        var compressedData: Data? {
            if let data = UIImageJPEGRepresentation(compressedImage, 1) {
                return data
            } else {
                return UIImagePNGRepresentation(compressedImage)
            }
        }
        
        guard let data = compressedData else {return}
        
        upload(data, forKey: key, token: token, progress: progress, success: success, failure: failure)
    }
    
    public func upload(_ asset: PHAsset, forKey key: String? = nil, token: String, progress progressBlock: ((Float) -> Void)? = nil, success: ((String) -> Void)? = nil, failure: ((NSError) -> Void)? = nil) {
     
        let option = options(progress: progressBlock)
        let complete = completed(success: success, failure: failure)
        QN.uploadManager.put(asset, key: key, token: token, complete: complete, option: option)
    }
}

private extension QNUploadService {
    
    func options(progress progressBlock: ((Float) -> Void)?) -> QNUploadOption {
        let progressHandler: QNUpProgressHandler = { (key: String?, progress: Float) in
            progressBlock?(progress)
        }
        return QNUploadOption(progressHandler: progressHandler)
    }
    
    func completed(success: ((String) -> Void)? = nil,
                   failure: ((NSError) -> Void)? = nil)
        -> (QNResponseInfo?, String?, [AnyHashable : Any]?) -> Swift.Void {
            return  { (info, key, resp) in
                guard let info = info, info.isOK else {
                    let error = NSError(domain: #function, code: -1, userInfo: resp)
                    failure?(error)
                    return
                }
                if let key = key {
                    success?(key)
                } else {
                    let key = resp?["hash"] as? String
                    success?(key!)
                }
            }
    }
}

extension QNUploadService {
    var uuidKey: String {
        return UUID().uuidString.lowercased().replacingOccurrences(of: "-", with:"")
    }
}
