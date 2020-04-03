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
        
        for fileUrl in FileManager.default.z.fetchRegularFileUrl(inDirUrl: getDirUrl()) {
            if let date = FileManager.default.z.attributesOfItem(fileUrl)?[.modificationDate] as? Date, Date().timeIntervalSince(date) > timeInterval {
                do {
                    try FileManager.default.removeItem(at: fileUrl)
                } catch let error as NSError {
                    NSLog("failed to remove item: \(#function) \(error)")
                }
            }
        }
    }
    
    public func updateFileName(_ fileName: String = "", suffix: String = "") {
        if fileName.isEmpty || !fileName.z.isSimpleFileName(isMultiPath: true) {
            self.fileName = Date.Z.getCurrentFormatDate(format: "%04d-%02d-%02d")
        } else {
            self.fileName = fileName
        }
        
        if suffix.isEmpty || !suffix.z.isSimpleFileName() {
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
        FileManager.default.z.createMultiPathFile(for: currentLogUrl)
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
