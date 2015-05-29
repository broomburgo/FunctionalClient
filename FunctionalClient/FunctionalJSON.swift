import Foundation
import FunctionalSwift

public let JSONParsingDomain = "FunctionalJSON.JSONParsingDomain"
public let objectKey = "FunctionalJSON.objectKey"

public enum JSONParsingError: Int {
    case Undefined = 0
    case ToJSONObject
    case ToInt
    case ToFloat
    case ToDouble
    case ToBool
    case ToString
    case ToDictionary
    case ToArrayString
    case ToArrayDictionary
    case ToDate
}

public func toJSONObject (data: NSData) -> Result<AnyObject,NSError> {
    var inOutError: NSError? = nil
    if let JSONObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error:&inOutError) {
        return success(JSONObject)
    }
    else {
        
        let errorString: String = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
            >>> { dataString in inOutError?.userInfo?[NSLocalizedDescriptionKey] as? String
                >>> { errorDescription in errorDescription + " " + dataString }
                ?? dataString }
            ?? ""
        
        let userInfo = errorString.isEmpty ? inOutError?.userInfo : [NSLocalizedDescriptionKey:errorString]
        
        return failure § NSError(domain: JSONParsingDomain, code: codeOfError(.ToJSONObject), userInfo: userInfo)
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

public func toDouble (object: AnyObject) -> Result<Double,NSError> {
    if let asDouble = object as? Double {
        return success(asDouble)
    }
    else {
        return failure § parsingError(.ToDouble, object)
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

public func toDate (formatter: NSDateFormatter)(object: AnyObject) -> Result<NSDate,NSError> {
    if let dateString = object as? String, date = formatter.dateFromString(dateString) {
        return success(date)
    }
    else {
        return failure § dateParsingError(formatter.dateFormat, object)
    }
}

///MARK: - private utilities

private func codeOfError (error: JSONParsingError) -> Int {
    return error.rawValue
}

private func parsingError(error: JSONParsingError, object: AnyObject) -> NSError {
    return NSError(domain: JSONParsingDomain, code: codeOfError(error), userInfo: [NSLocalizedDescriptionKey : "Error '\(error)': can't parse object '\(object)'", objectKey : object])
}

private func dateParsingError(format: String, object: AnyObject) -> NSError {
    return NSError(domain: JSONParsingDomain, code: codeOfError(.ToDate), userInfo: [NSLocalizedDescriptionKey : "Error '\(JSONParsingError.ToDate)': can't parse object '\(object)' with format '\(format)'", objectKey : object])
}






