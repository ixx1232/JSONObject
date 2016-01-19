//
//  JSONObject.swift
//  JSONObject
//
//  Created by apple on 16/1/19.
//  Copyright © 2016年 www.ixx.com. All rights reserved.
//

import Foundation


struct JSONObjectGenerator : GeneratorType{
    var _value : JSONObject?
    var _dictGenerate : NSDictionary.Generator?
    var _arrayGenerate : NSArray.Generator?
    
    init(value:JSONObject?) {
        _value = value
        if _value?.type == JSONType.JArray {
            _arrayGenerate = (_value?.value as? NSArray)?.generate()
        }
        else {
            _dictGenerate = (_value?.value as? NSDictionary)?.generate()
        }
    }
    
    mutating func next()->JSONObject? {
        if nil != _dictGenerate {
            if let (k,_):(key:AnyObject, value:AnyObject) = _dictGenerate!.next() {
                return _J(k)
            }
        }
        else if nil != _arrayGenerate {
            if let v : AnyObject = _arrayGenerate!.next() {
                return _J(v)
            }
        }
        return nil
    }
}

enum JSONType {
    case JNumber
    case JString
    case JNull
    case JArray
    case JDictionary
}

struct JSONObject : CustomStringConvertible, Equatable, SequenceType {
    
    var type : JSONType = .JNull
    
    static func JSONObjectFrom(filepath filepath:NSString?)->JSONObject? {
        var data : NSData? = nil
        if nil != filepath {
            data = try? NSData(contentsOfFile: filepath! as String, options: NSDataReadingOptions.DataReadingUncached)
        }
        return data != nil ? JSONObjectFrom(data: data) : nil
    }
    
    static func JSONObjectFrom(string string:NSString?)->JSONObject? {
        return JSONObjectFrom(data: string?.dataUsingEncoding(NSUTF8StringEncoding))
    }
    
    static func JSONObjectFrom(data data:NSData?)->JSONObject? {
        var jo : JSONObject?
        let jsonObj: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
        if nil != jsonObj {
            jo = JSONObject(jsonObj)
        }
        return jo
    }
    
    init(_ value:AnyObject?=nil) {
        parseType(value)
    }
    
    var description: String {
        if nil != _opaqueJsonObject {
            return _opaqueJsonObject!.description
        } else {
            return ("(null)")
        }
    }
    
    mutating func set(value:JSONObject) {
        _opaqueJsonObject = value._opaqueJsonObject
        type = value.type
    }
    mutating func set(value:NSNumber) {
        _opaqueJsonObject = value
        parseType(value)
    }
    
    func generate() -> JSONObjectGenerator {
        return JSONObjectGenerator(value: self)
    }
    
    //    mutating func set(value:AnyObject?) { parseType(value)                      }
    //    mutating func set(value: Int8)      { set(NSNumber(char: value))            }
    //    mutating func set(value: UInt8)     { set(NSNumber(unsignedChar: value))    }
    //    mutating func set(value: Int16)     { set(NSNumber(short: value))           }
    //    mutating func set(value: UInt16)    { set(NSNumber(unsignedShort: value))   }
    //    mutating func set(value: Int32)     { set(NSNumber(int: value))             }
    //    mutating func set(value: UInt32)    { set(NSNumber(unsignedInt: value))     }
    //    mutating func set(value: Int)       { set(NSNumber(long: value))            }
    //    mutating func set(value: UInt)      { set(NSNumber(unsignedLong: value))    }
    //    mutating func set(value: Int64)     { set(NSNumber(longLong: value))        }
    //    mutating func set(value: UInt64)    { set(NSNumber(unsignedLongLong: value))}
    //    mutating func set(value: Float)     { set(NSNumber(float: value))           }
    //    mutating func set(value: Double)    { set(NSNumber(double: value))          }
    //    mutating func set(value: Bool)      { set(NSNumber(bool: value))            }
    
    //MARK: private
    private func equals(jsonObj:JSONObject)->Bool {
        if self.type != jsonObj.type {
            return false
        }
        
        switch (_opaqueJsonObject, jsonObj._opaqueJsonObject) {
            
        case let (number1, number2) as (NSNumber, NSNumber):
            return number1.isEqualToNumber(number2)
            
        case let (string1, string2) as (NSString, NSString):
            return string1.isEqualToString(string2 as String)
            
        case let (array1, array2) as (NSArray, NSArray):
            return array1.isEqualToArray(array2 as [AnyObject])
            
        case let (dict1, dict2) as (NSDictionary, NSDictionary):
            return dict1.isEqualToDictionary(dict2 as [NSObject : AnyObject])
            
        case (_, _) as (NSNull, NSNull):
            return true
            
        default:
            return false
        }
    }
    
    private mutating func parseType(object:AnyObject?) {
        _opaqueJsonObject = object
        switch object {
        case is NSDictionary:
            type = .JDictionary
        case is NSArray:
            type = .JArray
        case is NSNumber:
            type = .JNumber
        case is NSString:
            type = .JString
        default:
            _opaqueJsonObject = nil
            type = .JNull
        }
    }
    
    private var _opaqueJsonObject : AnyObject?
}

func _J(value:AnyObject?=nil)->JSONObject {
    return JSONObject(value)
}

//MARK: NSString
extension JSONObject {
    var string: String? {
        var retString : String?
        switch _opaqueJsonObject {
        case let str as NSString:
            retString = str as String
            
        case is NSDictionary, is NSArray:
            let data: NSData? = self.data
            if nil != data {
                retString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
            }
            
        case let num as NSNumber:
            retString = num.stringValue
            
        default:
            retString = nil
        }
        
        return retString
    }
    
    var nullToEmptyString:String {
        
        if let str = _opaqueJsonObject as? String {
            return str
        }
        
        return ""
    }
    
    
}
//MARK: NSArray
extension JSONObject {
    var count : Int {
        return (_opaqueJsonObject as? NSArray)?.count ?? 0
    }
    
    subscript(key:Int)->JSONObject {
        get {
            switch _opaqueJsonObject {
                
            case let arr as NSArray:
                return JSONObject(arr[key])
                
            default:
                return JSONObject()
            }
        }
        set{
            _opaqueJsonObject = _opaqueJsonObject ?? NSMutableArray()
            if let arr = _opaqueJsonObject as? NSMutableArray {
                self.type = JSONType.JArray
                if let obj: AnyObject = newValue._opaqueJsonObject {
                    
                    if key < 0                  { arr.insertObject(obj, atIndex: 0) }
                    else if key >= arr.count    { arr.addObject(obj) }
                    else                        { arr[key] = obj }
                    
                } else {
                    arr.removeObjectAtIndex(key)
                }
            } else if _opaqueJsonObject is NSArray {
                _opaqueJsonObject = _opaqueJsonObject!.mutableCopy()
                let arr = _opaqueJsonObject as! NSMutableArray
                self.type = JSONType.JArray
                if let obj: AnyObject = newValue._opaqueJsonObject {
                    
                    if key < 0                  { arr.insertObject(obj, atIndex: 0) }
                    else if key >= arr.count    { arr.addObject(obj) }
                    else                        { arr[key] = obj }
                    
                } else {
                    arr.removeObjectAtIndex(key)
                }
            }
        }
    }
    
    func insertObject(object:JSONObject, atIndex:Int)
    {
        if let arr = _opaqueJsonObject as? NSMutableArray
        {
            if let obj: AnyObject = object._opaqueJsonObject
            {
                if atIndex < 0                { arr.insertObject(obj, atIndex: 0) }
                else if atIndex >= arr.count  { arr.addObject(obj) }
                else                          { arr.insertObject(obj, atIndex: atIndex) }
            }
        }
    }
    
    
    //只对 NSMutableArray 有效
    func enumerateObjectsUsingBlock(block: (AnyObject!, Int, UnsafeMutablePointer<ObjCBool>) -> Void) {
        
        if self.type == JSONType.JArray {
            if let arr = _opaqueJsonObject as? NSMutableArray {
                for (var index:Int = 0; index < arr.count; ++index){
                    var isStop:ObjCBool = ObjCBool(false)
                    let item: AnyObject = arr.objectAtIndex(index)
                    block(item, index, &isStop)
                    if isStop.boolValue {
                        break
                    }
                }
            }
        }
    }
}
//MARK: NSDictionary
extension JSONObject {
    subscript(key:NSString)->JSONObject {
        get {
            switch _opaqueJsonObject {
                
            case let dict as NSDictionary:
                return JSONObject(dict[key])
                
            default:
                return JSONObject()
            }
        }
        set {
            _opaqueJsonObject = _opaqueJsonObject ?? NSMutableDictionary()
            if let dict = _opaqueJsonObject as? NSMutableDictionary {
                self.type = JSONType.JDictionary
                
                //                if nil != newValue._opaqueJsonObject {
                //                    dict[key] = newValue._opaqueJsonObject!
                //                } else {
                //                    dict.removeObjectForKey(key)
                //                }
                if let opaqueJsonObject: AnyObject = newValue._opaqueJsonObject {
                    dict[key] = opaqueJsonObject
                }
                else {
                    dict.removeObjectForKey(key)
                }
            } else if _opaqueJsonObject is NSDictionary {
                
                _opaqueJsonObject = _opaqueJsonObject!.mutableCopy()
                let dict = _opaqueJsonObject as! NSMutableDictionary
                self.type = JSONType.JDictionary
                
                //                if nil == newValue._opaqueJsonObject {
                //                    dict.removeObjectForKey(key)
                //                } else {
                //                    dict[key] = newValue._opaqueJsonObject!
                //                }
                
                if let opaqueJsonObject: AnyObject = newValue._opaqueJsonObject {
                    dict[key] = opaqueJsonObject
                }
                else {
                    dict.removeObjectForKey(key)
                }
                
            }
        }
    }
    
    subscript(key:JSONObject)->JSONObject? {
        get {
            return self[key.string!]
        }
        set {
            self[key.string!] = newValue!
        }
    }
    
    subscript(var key:NSRange) -> JSONObject? {
        get {
            switch _opaqueJsonObject {
                
            case let arr as NSArray:
                
                if key.location < 0 || key.location >= arr.count  {
                    return nil
                }
                
                if key.location + key.length > arr.count {
                    key.length = arr.count - key.location
                }
                
                return JSONObject(arr.subarrayWithRange(key))
                
            default:
                return nil
            }
        }
    }
}

//MARK: RawValue
extension JSONObject {
    var value: AnyObject?{
        return _opaqueJsonObject
    }
}

//MARK: NSNumber
extension JSONObject {
    var number: NSNumber {
        switch _opaqueJsonObject
        {
        case let json as NSString:
            return json.doubleValue
        default:
            return (_opaqueJsonObject as? NSNumber) ?? 0
        }
        
    }
    
    var integerValue:Int {
        switch _opaqueJsonObject
        {
        case let json as NSString:
            return json.integerValue
        default:
            return (_opaqueJsonObject as? NSNumber)?.integerValue ?? 0
        }
    }
    
    var boolValue:Bool {
        switch _opaqueJsonObject
        {
        case let json as NSString:
            return json.boolValue
        default:
            return (_opaqueJsonObject as? NSNumber)?.boolValue ?? false
        }
    }
    
    var doubleValue:Double {
        switch _opaqueJsonObject
        {
        case let json as NSString:
            return json.doubleValue
        default:
            return (_opaqueJsonObject as? NSNumber)?.doubleValue ?? 0
        }
    }
    
    var longLongValue:Int64 {
        switch _opaqueJsonObject
        {
        case let json as NSString:
            return json.longLongValue
        default:
            return (_opaqueJsonObject as? NSNumber)?.longLongValue ?? 0
        }
    }
    
    var intValue: Int32 {
        switch _opaqueJsonObject
        {
        case let json as NSString:
            return json.intValue
        default:
            return (_opaqueJsonObject as? NSNumber)?.intValue ?? 0
        }
    }
    
//    var cgfloatValue: CGFloat {
//        switch _opaqueJsonObject
//        {
//        case let json as NSString:
//            return CGFloat(json.floatValue)
//        default:
//            return (_opaqueJsonObject as? NSNumber)?.cgfloatValue ?? 0
//        }
//    }
    
}

//MARK: encode to NSData
extension JSONObject {
    var data: NSData? {
        if nil != _opaqueJsonObject {
            return try? NSJSONSerialization.dataWithJSONObject(_opaqueJsonObject!, options: NSJSONWritingOptions(rawValue: 0))
        }
        return nil
    }
}

extension NSData {
    var jsonObject:JSONObject? {
        return JSONObject.JSONObjectFrom(data: self)
    }
}

extension NSString {
    var jsonObject:JSONObject? {
        return JSONObject.JSONObjectFrom(string: self)
    }
    var jsonObjectAsPath:JSONObject? {
        return JSONObject.JSONObjectFrom(filepath: self)
    }
}

extension NSDictionary {
    var jsonObject : JSONObject? {
        return _J(self)
    }
    
    var jsonData : NSData? {
        return self.jsonObject?.data
    }
}

//MARK: operator
func == (lhs: JSONObject, rhs: JSONObject) -> Bool {
    return lhs.equals(rhs)
}

func += (inout lhs : JSONObject, rhs: NSDictionary) {
    for (k,v) in rhs {
        lhs[k as! String] = _J(v)
    }
}

func += (inout lhs : JSONObject, rhs: NSArray) {
    for v in rhs {
        lhs[Int.max] = _J(v)
    }
}
func += (inout lhs : JSONObject, rhs: JSONObject) {
    switch(lhs.type,rhs.type)
    {
    case (JSONType.JArray, JSONType.JArray):
        let rhsArr = rhs.value as! NSArray;
        lhs += rhsArr;
    default:
        break;
    }
    
}


//MARK: WriteToFile
//
extension JSONObject {
    func writeToFile(filePath:String) {
        if filePath.length > 0 {
            if let data = self.data {
                data.writeToFile(filePath, atomically: true)
            }
            else {
                removeLibraryFile(filePath)
            }
        }
    }
}


func removeLibraryFile(pathString:String) {
    let fileMgr = NSFileManager.defaultManager()
    if fileMgr.fileExistsAtPath(pathString) {
        do {
            try fileMgr.removeItemAtPath(pathString)
        } catch _ {
        }
    }
}
//MARK: useage

/*
func writeDictTest()
{
var a = JSONObject()
a["a"] = _J("a1")
a += ["b":"b1","c":["1","2",3,4]]
println(a)
a.data?.writeToFile("/tmp/dict.json", atomically: true)
}

func writeArrTest()
{
var a = JSONObject()
a[0] = _J(1)
a[1] = _J(1.0)
a[2] = _J("a")
a[3] = _J(0.232)
a[3].set(0.222)
a[4] = _J(0b10)
a[5] = _J(["uu":"ii"].mutableCopy())
if a[5].value is NSDictionary
{
println("is NSDictionary")
}
if a[5].value is NSMutableDictionary
{
println("is NSMutableDictionary")
}
println(a)
a[5]["uu"] = _J("ikk")
println(a[5]["uu"])
println(a)
a.data?.writeToFile("/tmp/arr.json", atomically: true)
}
func readJsonTest()
{
var json = JSONObject.JSONObjectFrom(filepath: "/tmp/read.json")!
println(json)
json["add1"] = _J("add1v")
println(json.string!)
println(json.data)
println(json["blogs"])
json["blogs"]["add2"] = _J("add2v")
println(json["blogs"])
println(json["blogs"]["blog"][0]["nokey1"]["nokey2"])
var value = json["blogs"]["blog"][0]
println(value)
var aaa : NSDictionary?
value["nokey1"] = _J(["nokey2":"asdfasdf"])
println(value)
}
*/

