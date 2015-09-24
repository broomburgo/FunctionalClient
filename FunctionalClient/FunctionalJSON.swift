import Foundation
import Swiftz

public let JSONParsingDomain = "FunctionalJSON.JSONParsingDomain"
public let objectKey = "FunctionalJSON.objectKey"
public let DictionaryExtractDomain = "FunctionalJSON.DictionaryExtractDomain"

public enum JSONParsingError: Int
{
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

public func toJSONObject (data: NSData) -> Either<NSError,AnyObject>
{
  do
  {
    return Either.Right(try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments))
  }
  catch let error as NSError
  {
    let errorString = (NSString(data: data, encoding: NSUTF8StringEncoding) as? String
      >>- { dataString in (error.userInfo[NSLocalizedDescriptionKey] as? String
        >>- { errorDescription in errorDescription + " " + dataString })
        .getOrElse(dataString) })
      .getOrElse("")
    let userInfo = errorString.isEmpty ? error.userInfo : [NSLocalizedDescriptionKey:errorString]
    return Either.Left § NSError(domain: JSONParsingDomain, code: codeOfError(.ToJSONObject), userInfo: userInfo)
  }
}

public func toInt (object: AnyObject) -> Either<NSError,Int>
{
  if let
    asInt = object as? Int
  {
    return Either.Right § asInt
  }
  else
  {
    return Either.Left § parsingError(.ToInt, object)
  }
}

public func toFloat (object: AnyObject) -> Either<NSError,Float>
{
  if let
    asFloat = object as? Float
  {
    return Either.Right § asFloat
  }
  else
  {
    return Either.Left § parsingError(.ToFloat, object)
  }
}

public func toDouble (object: AnyObject) -> Either<NSError,Double>
{
  if let
    asDouble = object as? Double
  {
    return Either.Right § asDouble
  }
  else
  {
    return Either.Left § parsingError(.ToDouble, object)
  }
}

public func toBool (object: AnyObject) -> Either<NSError,Bool>
{
  if let
    asBool = object as? Bool
  {
    return Either.Right § asBool
  }
  else
  {
    return Either.Left § parsingError(.ToBool, object)
  }
}

public func toString (object: AnyObject) -> Either<NSError,String>
{
  if let
    asString = object as? String
  {
    return Either.Right § asString
  }
  else
  {
    return Either.Left § parsingError(.ToString, object)
  }
}

public func toDictionary (object: AnyObject) -> Either<NSError,[String:AnyObject]>
{
  if let
    asDictionary = object as? [String:AnyObject]
  {
    return Either.Right § asDictionary
  }
  else
  {
    return Either.Left § parsingError(.ToDictionary, object)
  }
}

public func toArrayString (object: AnyObject) -> Either<NSError,[String]>
{
  if let
    asArrayString = object as? [String]
  {
    return Either.Right § asArrayString
  }
  else
  {
    return Either.Left § parsingError(.ToArrayString, object)
  }
}

public func toArrayDictionary (object: AnyObject) -> Either<NSError,[[String:AnyObject]]>
{
  if let
    asArrayDictionary = object as? [[String:AnyObject]]
  {
    return Either.Right § asArrayDictionary
  }
  else
  {
    return Either.Left § parsingError(.ToArrayDictionary, object)
  }
}

public func toDate (formatter: NSDateFormatter)(object: AnyObject) -> Either<NSError,NSDate>
{
  if let
    dateString = object as? String,
    date = formatter.dateFromString(dateString)
  {
    return Either.Right § date
  }
  else
  {
    return Either.Left § dateParsingError(formatter.dateFormat, object)
  }
}

//MARK: - extract from dictionary

public func extract <E> (key: String, _ valueNotFoundError: (String, [String:AnyObject]) -> E)(dict: [String:AnyObject]) -> Either<E,AnyObject>
{
  if let
    value = dict[key]
  {
    return .Right(value)
  }
  else
  {
    return .Left(valueNotFoundError(key, dict))
  }
}

public func extract <E> (key: String, _ wrongTypeError: (String, AnyObject) -> E, _ valueNotFoundError: (String, [String:AnyObject]) -> E)(maybeDict: AnyObject) -> Either<E,AnyObject>
{
  if let
    dict = maybeDict as? [String:AnyObject]
  {
    if let
      value = dict[key]
    {
      return .Right(value)
    }
    else
    {
      return .Left(valueNotFoundError(key, dict))
    }
  }
  else {
    return .Left(wrongTypeError(key, maybeDict))
  }
}

public func get (key: String)(dictionary: [String:AnyObject]) -> Either<NSError,AnyObject>
{
  return dictionary |> extract(key, cantFindValueForKeyError)
}

public func get (key: String)(object: AnyObject) -> Either<NSError,AnyObject>
{
  return object |> extract(key, objectIsNotDictionaryError, cantFindValueForKeyError)
}

//MARK: - private utilities

private func codeOfError (error: JSONParsingError) -> Int
{
  return error.rawValue
}

private func parsingError(error: JSONParsingError, _ object: AnyObject) -> NSError
{
  return NSError(domain: JSONParsingDomain, code: codeOfError(error), userInfo: [NSLocalizedDescriptionKey : "Error '\(error)': can't parse object '\(object)'", objectKey : object])
}

private func dateParsingError(format: String, _ object: AnyObject) -> NSError
{
  return NSError(domain: JSONParsingDomain, code: codeOfError(.ToDate), userInfo: [NSLocalizedDescriptionKey : "Error '\(JSONParsingError.ToDate)': can't parse object '\(object)' with format '\(format)'", objectKey : object])
}

private func cantFindValueForKeyError (key: String, _ dictionary: [String:AnyObject]) -> NSError
{
  return NSError(domain: DictionaryExtractDomain, code: 1, userInfo: [NSLocalizedDescriptionKey:"Can't find value for key '\(key)' in dictionary '\(dictionary)'"])
}

private func objectIsNotDictionaryError (key: String, _ object: AnyObject) -> NSError
{
  return NSError(domain: DictionaryExtractDomain, code: 2, userInfo: [NSLocalizedDescriptionKey:"Object for key '\(key)' is not of type [String:AnyObject]: '\(object)"])
}


