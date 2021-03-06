//
//  ZLog.swift
//  Pods
//
//  Created by lyp on 2020/3/6.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation
import os

public func zlog<T>(_ message: T, level: ZLogLevel = .info, async: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
    ZLogger.shared.log(message, level: level, async: async, file: file, function: function, line: line)
}

public enum ZLogLevel: Int, CaseIterable {
    public static let MaxLength = Self.allCases.map({ "\($0)".count }).max() ?? 10
    case none, error, warning, info, debug
    
    public var description: String {
        return "\(self)".padding(toLength: Self.MaxLength, withPad: " ", startingAt: 0)
    }
    
    @available(iOS 10.0, *)
    public var osLogType: OSLogType {
        switch self {
        case .none: return .fault
        case .error: return .error
        case .warning: return .default
        case .info: return .info
        case .debug: return .debug
        }
    }
}

public protocol ZLogHandler: NSObjectProtocol {
    func handle<T>(_ message: T, date: String, level: ZLogLevel, file: String, function: String, line: Int)
}

public final class ZLogger: NSObject {
    public static let shared = ZLogger()
    
    private var logQueue = DispatchQueue(label: "queue.log.util.zero", qos: .utility)
    private var logLevelQueue = DispatchQueue(label: "queue.level.log.util.zero", qos: .userInitiated)
    private var _currentLevel = ZLogLevel.info
     
    public var currentLevel: ZLogLevel {
        set { logLevelQueue.sync { _currentLevel = newValue }}
        get { return logLevelQueue.sync { _currentLevel }}
    }
    public var handler = [ZLogHandler]()
    public var disableNSLog = false
    public var disableOSLog = false
    
    private override init() {
        super.init()
    }
    
    public func log<T>(_ message: T, level: ZLogLevel = .info, async: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let date = Date.getCurrentFormatDate()
        var isUseNSLog = !disableNSLog
        if #available(iOS 10.0, *), !disableOSLog {
            os_log("%@", type: level.osLogType, createFormatLog(message, date: date, level: level, file: file, function: function, line: line))
            isUseNSLog = false
        }
        
        if level.rawValue > _currentLevel.rawValue {
            return
        }
        
        let logImpl = {
            self.log(message, date: date, level: level, isUseNSLog: isUseNSLog, file: file, function: function, line: line)
        }
        if async {
            logQueue.async {
                logImpl()
            }
        } else {
            logImpl()
        }
    }
    
    public func createFormatLog<T>(_ message: T, date: String, level: ZLogLevel, file: String = #file, function: String = #function, line: Int = #line) -> String {
        var log = ""
        log.append(String(format: "%@ %@ %@ ", date, level.description, "\(message)"))
        log.append(String(format: "%@ %@ %d", (file as NSString).lastPathComponent, function, line))
        return log
    }
    
    private func log<T>(_ message: T, date: String, level: ZLogLevel, isUseNSLog: Bool, file: String, function: String, line: Int) {
        if isUseNSLog {
            NSLog("%@", createFormatLog(message, date: date, level: level, file: file, function: function, line: line))
        }
        handler.forEach({ $0.handle(message, date: date, level: level, file: file, function: function, line: line) })
    }
}

public extension Date {
    
    static func getCurrentFormatDate(format: String = "%04d-%02d-%02d %02d:%02d:%02d.%06d %05d") -> String {
        var tv = timeval()
        var tz = timezone()
        gettimeofday(&tv, &tz)
        let tm = localtime(&tv.tv_sec).pointee
        return String(format: format, tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec, tv.tv_usec, tm.tm_gmtoff)
    }
}

public extension String {
    
    func isSimpleFileName(isMultiPath: Bool = false) -> Bool {
        for item in [first?.lowercased(), last?.lowercased()] {
            if let item = item, !((item >= "a" && item <= "z") || (item >= "0" && item <= "9")) {
                return false
            }
        }
        return allSatisfy { (char) -> Bool in
            if char.lowercased() >= "a", char.lowercased() <= "z" {
                return true
            }
            if char >= "0", char <= "9" {
                return true
            }
            if char == "-" || char == "_" || (isMultiPath && char == "/") {
                return true
            }
            return false
        }
    }
}
