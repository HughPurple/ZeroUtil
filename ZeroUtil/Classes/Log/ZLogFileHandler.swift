//
//  ZLogFileHandler.swift
//  Pods
//
//  Created by lyp on 2020/3/18.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation

public final class ZLogFileHandler: NSObject {
    public static let defaultSuffix = "zlog"
    public static let pathPrefix = "local_storage/z_log/"
    
    public private(set) var fileName = ""
    public private(set) var suffix = ""
    public private(set) var currentLogUrl = URL(fileURLWithPath: "./".appending(ZLogFileHandler.pathPrefix))
    
    public override init() {
        super.init()
        
        updateFileName()
    }
    
    public func clearLogFile(afterExpiredTimeInterval timeInterval: TimeInterval) {
        guard timeInterval > 0 else { return }
        
        let fileUrls = FileManager.default.fetchRegularFileUrl(inDirUrl: getDirUrl())
        guard fileUrls.count > 0 else { return }
        
        for fileUrl in fileUrls {
            if let date = FileManager.default.attributesOfItem(fileUrl)?[.modificationDate] as? Date, Date().timeIntervalSince(date) > timeInterval {
                do {
                    try FileManager.default.removeItem(at: fileUrl)
                } catch let error as NSError {
                    NSLog("failed to remove item: \(#function) \(error)")
                }
            }
        }
    }
    
    public func updateFileName(_ fileName: String = "", suffix: String = "") {
        if fileName.isEmpty || !fileName.isSimpleFileName(isMultiPath: true) {
            self.fileName = Date.getCurrentFormatDate(format: "%04d-%02d-%02d")
        } else {
            self.fileName = fileName
        }
        
        if suffix.isEmpty || !suffix.isSimpleFileName() {
            self.suffix = Self.defaultSuffix
        } else {
            self.suffix = suffix
        }
        
        self.currentLogUrl = getDirUrl().appendingPathComponent(self.fileName.appending(".").appending(self.suffix), isDirectory: false)
    }
    
    public func getDirUrl() -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent(Self.pathPrefix, isDirectory: true)
        }
        return URL(fileURLWithPath: "./".appending(Self.pathPrefix))
    }
}

extension ZLogFileHandler: ZLogHandler {
    
    public func handle<T>(_ message: T, date: String, level: ZLogLevel, file: String, function: String, line: Int) {
        FileManager.default.createMultiPathFile(for: currentLogUrl)
        do {
            let fileHandle = try FileHandle(forWritingTo: currentLogUrl)
            var log = ZLogger.shared.createFormatLog(message, date: date, level: level, file: file, function: function, line: line)
            fileHandle.seekToEndOfFile()
            if fileHandle.offsetInFile > 0 {
                log = "\n".appending(log)
            }
            if let data = log.data(using: .utf8) {
                fileHandle.write(data)
            }
        } catch let error as NSError {
            NSLog("failed to append: \(#function) \(error)")
        }
    }
}

public extension FileManager {
    
    func createMultiPathFile(for url: URL) {
        let preUrl = url.deletingLastPathComponent()
        if !fileExists(atPath: preUrl.path) {
            do {
                try createDirectory(atPath: preUrl.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("failed to create directory: \(#function) \(error)")
            }
        }
        
        var isDir = ObjCBool.init(false)
        if !fileExists(atPath: url.path, isDirectory: &isDir) {
            createFile(atPath: url.path, contents: nil, attributes: nil)
        } else if isDir.boolValue {
            do {
                try removeItem(atPath: url.path)
            } catch let error as NSError {
                NSLog("failed to remove item: \(#function) \(error)")
            }
            createFile(atPath: url.path, contents: nil, attributes: nil)
        }
    }
    
    func fetchRegularFileUrl(inDirUrl dirUrl: URL) -> [URL] {
        guard let enumerator = enumerator(at: dirUrl, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { return [] }
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
    
    func attributesOfItem(_ url: URL) -> [FileAttributeKey: Any]? {
        do {
            return try attributesOfItem(atPath: url.path)
        } catch let error as NSError {
            NSLog("failed to list attributes of item: \(#function) \(error)")
        }
        return nil
    }
    
    func sortedRegularFileUrl(inDirUrl dirUrl: URL, isDesc: Bool = true) -> [URL] {
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
}
