import Foundation
import Result
import Elements

public let JSONParsingDomain = "FunctionalJSON.JSONParsingDomain"
public let objectKey = "FunctionalJSON.objectKey"
public let DictionaryExtractDomain = "FunctionalJSON.DictionaryExtractDomain"

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
        return Result.success(JSONObject)
    }
    else {
        let errorString = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
            >>> { dataString in inOutError?.userInfo?[NSLocalizedDescriptionKey] as? String
                >>> { errorDescription in errorDescription + " " + dataString }
                |> defaultTo(dataString) }
            |> defaultTo("")
        let userInfo = errorString.isEmpty ? inOutError?.userInfo : [NSLocalizedDescriptionKey:errorString]
        return Result.failure § NSError(domain: JSONParsingDomain, code: codeOfError(.ToJSONObject), userInfo: userInfo)
    }
}

public func toInt (object: AnyObject) -> Result<Int,NSError> {
    if let asInt = object as? Int {
        return Result.success § asInt
    }
    else {
        return Result.failure § parsingError(.ToInt, object)
    }
}

public func toFloat (object: AnyObject) -> Result<Float,NSError> {
    if let asFloat = object as? Float {
        return Result.success § asFloat
    }
    else {
        return Result.failure § parsingError(.ToFloat, object)
    }
}

public func toDouble (object: AnyObject) -> Result<Double,NSError> {
    if let asDouble = object as? Double {
        return Result.success § asDouble
    }
    else {
        return Result.failure § parsingError(.ToDouble, object)
    }
}

public func toBool (object: AnyObject) -> Result<Bool,NSError> {
    if let asBool = object as? Bool {
        return Result.success § asBool
    }
    else {
        return Result.failure § parsingError(.ToBool, object)
    }
}

public func toString (object: AnyObject) -> Result<String,NSError> {
    if let asString = object as? String {
        return Result.success § asString
    }
    else {
        return Result.failure § parsingError(.ToString, object)
    }
}

public func toDictionary (object: AnyObject) -> Result<[String:AnyObject],NSError> {
    if let asDictionary = object as? [String:AnyObject] {
        return Result.success § asDictionary
    }
    else {
        return Result.failure § parsingError(.ToDictionary, object)
    }
}

public func toArrayString (object: AnyObject) -> Result<[String],NSError> {
    if let asArrayString = object as? [String] {
        return Result.success § asArrayString
    }
    else {
        return Result.failure § parsingError(.ToArrayString, object)
    }
}

public func toArrayDictionary (object: AnyObject) -> Result<[[String:AnyObject]],NSError> {
    if let asArrayDictionary = object as? [[String:AnyObject]] {
        return Result.success § asArrayDictionary
    }
    else {
        return Result.failure § parsingError(.ToArrayDictionary, object)
    }
}

public func toDate (formatter: NSDateFormatter)(object: AnyObject) -> Result<NSDate,NSError> {
    if let dateString = object as? String, date = formatter.dateFromString(dateString) {
        return Result.success § date
    }
    else {
        return Result.failure § dateParsingError(formatter.dateFormat, object)
    }
}

///MARK: - extract from dictionary

public func get (key: String)(dictionary: [String:AnyObject]) -> Result<AnyObject,NSError> {
    return dictionary |> extract(key, cantFindValueForKeyError)
}

public func get (key: String)(object: AnyObject) -> Result<AnyObject,NSError> {
    return object |> extract(key, objectIsNotDictionaryError, cantFindValueForKeyError)
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

private func cantFindValueForKeyError (key: String, dictionary: [String:AnyObject]) -> NSError {
    return NSError(domain: DictionaryExtractDomain, code: 1, userInfo: [NSLocalizedDescriptionKey:"Can't find value for key '\(key)' in dictionary '\(dictionary)'"])
}

private func objectIsNotDictionaryError (key: String, object: AnyObject) -> NSError {
    return NSError(domain: DictionaryExtractDomain, code: 2, userInfo: [NSLocalizedDescriptionKey:"Object for key '\(key)' is not of type [String:AnyObject]: '\(object)"])
}


