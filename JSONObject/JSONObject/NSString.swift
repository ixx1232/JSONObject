//
//  NSString.swift
//  JSONObject
//
//  Created by apple on 16/1/19.
//  Copyright © 2016年 www.ixx.com. All rights reserved.
//

import Foundation

extension NSURL
{
    func setNotBackToIcloud()
    {
        do {
            try self.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
        } catch _ {
        }
    }
}

//extension NSString {

//    func setNotBackToIcloud() {
//        
//        let version = UIDevice.currentDevice().systemVersion._bridgeToObjectiveC().floatValue
//        if(version >= 5.1) {
//            do {
//                try NSURL(fileURLWithPath: self as String).setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
//            } catch _ {
//            }
//        }
//    }
//    
//    
//    func md5() -> String
//    {
//        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
//        return OcUtils.MD5(data!.bytes, len: UInt32(data!.length))
//    }
//    
//}
//
//extension String {
//    func md5() -> String
//    {
//        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
//        return OcUtils.MD5(data!.bytes, len: UInt32(data!.length))
//    }
//}

extension String {
    func toUInt()->UInt {
        return UInt(Int(self) ?? 0)
    }
}

extension String {
    
    func substringToIndex(index:Int) -> String{
        return self.substringToIndex(self.startIndex.advancedBy(index))
    }
    
    func substringFromIndex(index:Int) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }
    
    func substringWithNSRange(range:NSRange) -> String {
        let start = self.startIndex.advancedBy(range.location)
        let end = self.startIndex.advancedBy(range.location + range.length)
        
        return self.substringWithRange(start..<end)
        
    }
    
    func substringWithRange(range:Range<Int>) ->String
    {
        let start   = self.startIndex.advancedBy(range.startIndex)
        let end     = self.endIndex.advancedBy(range.endIndex - range.startIndex)
        
        return self.substringWithRange(start..<end)
        
    }
    
    //    func removeNSRange(range:NSRange) {
    //        let start = advance(self.startIndex, range.location)
    //        let end = advance(self.startIndex, range.location + range.length)
    //
    //    }
    
    
    subscript(range:NSRange) -> String {
        return self.substringWithNSRange(range)
    }
    
    var length:Int {
        return self.characters.count
    }
    
    func trim()->String{
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    
    func stringByAppendingPathComponent(path: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(path)
    }
}
