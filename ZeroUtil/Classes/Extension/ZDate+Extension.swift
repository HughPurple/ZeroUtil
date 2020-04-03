//
//  ZDate+Extension.swift
//  Pods
//
//  Created by lyp on 2020/4/3.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation

public extension Date {
    static let Z = ZDate.default
    var z: ZDate {
        if self == Self.Z.target {
            return Self.Z
        }
        return ZDate(target: self)
    }
}

open class ZDate: NSObject {
    public static let `default` = ZDate(target: Date())
    public let target: Date
    
    public init(target: Date) {
        self.target = target
    }
    
    open func getCurrentFormatDate(format: String = "%04d-%02d-%02d %02d:%02d:%02d.%06d %05d") -> String {
        var tv = timeval()
        var tz = timezone()
        gettimeofday(&tv, &tz)
        let tm = localtime(&tv.tv_sec).pointee
        return String(format: format, tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec, tv.tv_usec, tm.tm_gmtoff)
    }
    
    open func getFormatDate(format: String = "%04d-%02d-%02d %02d:%02d:%02d.%06d %05d") -> String {
        var s = Int(target.timeIntervalSince1970)
        let ms = Int((target.timeIntervalSince1970 - floor(target.timeIntervalSince1970)) * 1_000_000)
        let tm = localtime(&s).pointee
        return String(format: format, tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec, ms, tm.tm_gmtoff)
    }
}
