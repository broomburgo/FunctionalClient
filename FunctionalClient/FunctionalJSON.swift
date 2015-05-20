import Foundation
import FunctionalSwift

public let JSONParsingDomain = "FunctionalJSON.parsing"
public let objectKey = "FunctionalJSON.object"

public enum JSONParsingError: Int {
    case Undefined          = 0
    case ToJSONObject       = 1
    case ToInt              = 2
    case ToFloat            = 3
    case ToBool             = 4
    case ToString           = 5
    case ToDictionary       = 6
    case ToArrayString      = 7
    case ToArrayDictionary  = 8
}

public func toJSONParsingError (code: Int) -> JSONParsingError {
    switch code {
    case 1:
        return .ToJSONObject
    case 2:
        return .ToInt
    case 3:
        return .ToFloat
    case 4:
        return .ToBool
    case 5:
        return .ToString
    case 6:
        return .ToDictionary
    case 7:
        return .ToArrayString
    case 8:
        return .ToArrayDictionary
    default:
        return .Undefined
    }
}

public func toJSONObject (data: NSData) -> Result<AnyObject,NSError> {
    var inOutError: NSError? = nil
    if let JSONObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error:&inOutError) {
        return success(JSONObject)
    }
    else {
        return failure § NSError(domain: JSONParsingDomain, code: codeOfError(.ToJSONObject), userInfo: inOutError?.userInfo)
    }
}

public func toInt (object: AnyObject) -> Result<Int,NSError> {
    if let asInt = object as? Int {
        return success(asInt)
    }
    else {
        return failure § parsingError(.ToInt, object)
    }
}

public func toFloat (object: AnyObject) -> Result<Float,NSError> {
    if let asFloat = object as? Float {
        return success(asFloat)
    }
    else {
        return failure § parsingError(.ToFloat, object)
    }
}

public func toBool (object: AnyObject) -> Result<Bool,NSError> {
    if let asBool = object as? Bool {
        return success(asBool)
    }
    else {
        return failure § parsingError(.ToBool, object)
    }
}

public func toString (object: AnyObject) -> Result<String,NSError> {
    if let asString = object as? String {
        return success(asString)
    }
    else {
        return failure § parsingError(.ToString, object)
    }
}

public func toDictionary (object: AnyObject) -> Result<[String:AnyObject],NSError> {
    if let asDictionary = object as? [String:AnyObject] {
        return success(asDictionary)
    }
    else {
        return failure § parsingError(.ToDictionary, object)
    }
}

public func toArrayString (object: AnyObject) -> Result<[String],NSError> {
    if let asArrayString = object as? [String] {
        return success(asArrayString)
    }
    else {
        return failure § parsingError(.ToArrayString, object)
    }
}

public func toArrayDictionary (object: AnyObject) -> Result<[[String:AnyObject]],NSError> {
    if let asArrayDictionary = object as? [[String:AnyObject]] {
        return success(asArrayDictionary)
    }
    else {
        return failure § parsingError(.ToArrayDictionary, object)
    }
}

/// MARK: - utilities

private func codeOfError (error: JSONParsingError) -> Int {
    return error.rawValue
}

private func parsingError(error: JSONParsingError, object: AnyObject) -> NSError {
    return NSError(domain: JSONParsingDomain, code: codeOfError(error), userInfo: [NSLocalizedDescriptionKey : cantParse(object), objectKey : object])
}

private func cantParse (object: AnyObject) -> String {
    return "Can't parse object: \(object)"
}






