import Foundation

public enum WSValue
{
  case Text(String)
  case Number(Int)
  case TrueFalse(Bool)
}

public protocol WSBound
{
  func wsValueForKey (key: String) -> WSValue?
}