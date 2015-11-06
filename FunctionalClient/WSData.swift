
public enum WSKey
{
  case Single(String)
  case Path([String])
  case Multiple([WSKey])
}

public enum WSValue
{
  case Empty
  case Text(String)
  case Number(Int)
  case Boolean(Bool)
}

public struct WSCouple
{
  public let key: WSKey
  public let value: WSValue
  
  public init(key: WSKey, value: WSValue)
  {
    self.key = key
    self.value = value
  }
}

public struct WSData
{
  
}
