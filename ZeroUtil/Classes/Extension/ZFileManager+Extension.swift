//
//  ZFileManager+Extension.swift
//  Pods
//
//  Created by lyp on 2020/4/3.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation

public extension FileManager {
    var z: ZFileManager {
        if self === ZFileManager.default.target {
            return ZFileManager.default
        }
        return ZFileManager(target: self)
    }
}

open class ZFileManager: NSObject {
    public static let `default` = ZFileManager(target: FileManager.default)
    public let target: FileManager
    
    public init(target: FileManager) {
        self.target = target
    }
    
    open func createMultiPathFile(for url: URL) {
        let preUrl = url.deletingLastPathComponent()
        if !target.fileExists(atPath: preUrl.path) {
            do {
                try target.createDirectory(atPath: preUrl.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("failed to create directory: \(#function) \(error)")
            }
        }
        
        var isDir = ObjCBool.init(false)
        if !target.fileExists(atPath: url.path, isDirectory: &isDir) {
            target.createFile(atPath: url.path, contents: nil, attributes: nil)
        } else if isDir.boolValue {
            do {
                try target.removeItem(atPath: url.path)
            } catch let error as NSError {
                NSLog("failed to remove item: \(#function) \(error)")
            }
            target.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
    }
    
    open func fetchRegularFileUrl(inDirUrl dirUrl: URL) -> [URL] {
        guard let enumerator = target.enumerator(at: dirUrl, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { return [] }
        var fileUrls = [URL]()
        for case let url as URL in enumerator {
            do {
                if (try url.resourceValues(forKeys: [.isRegularFileKey])).isRegularFile == true {
                    fileUrls.append(url)
                }
            } catch let error as NSError {
                NSLog("failed to get resource values: \(#function) \(error)")
            }
        }
        return fileUrls
    }
    
    open func sortedRegularFileUrl(inDirUrl dirUrl: URL, isDesc: Bool = true) -> [URL] {
        let orderType: ComparisonResult
        if isDesc {
            orderType = .orderedDescending
        } else {
            orderType = .orderedAscending
        }
        return fetchRegularFileUrl(inDirUrl: dirUrl).sorted(by: { (first, second) -> Bool in
            if let firstItems = attributesOfItem(first), let secondItems = attributesOfItem(second) {
                let date = Date()
                var firstDate = firstItems[.modificationDate] as? Date ?? date
                var secondDate = secondItems[.modificationDate] as? Date ?? date
                var result = firstDate.compare(secondDate)
                if result != .orderedSame {
                    return result == orderType
                }
                firstDate = firstItems[.creationDate] as? Date ?? date
                secondDate = secondItems[.creationDate] as? Date ?? date
                result = firstDate.compare(secondDate)
                if result != .orderedSame {
                    return result == orderType
                }
            }
            return false
        })
    }
    
    final public func attributesOfItem(_ url: URL) -> [FileAttributeKey: Any]? {
        do {
            return try target.attributesOfItem(atPath: url.path)
        } catch let error as NSError {
            NSLog("failed to list attributes of item: \(#function) \(error)")
        }
        return nil
    }
}
