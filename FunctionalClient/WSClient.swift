import Foundation
import Future
import Swiftz
import Queue

private typealias ResponsePromise = Promise<NSError,WSResponse>
private let emptyDataError = NSError(domain: "WSClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "received empty data"])

public typealias UniqueIndex = Int
public typealias WSResult = Either<NSError,WSResponse>

public struct WSResponse
{
  public let data: NSData
  public let optionalURLResponse: NSURLResponse?
  
  public init (data: NSData, optionalURLResponse: NSURLResponse?)
  {
    self.data = data
    self.optionalURLResponse = optionalURLResponse
  }
  
  public func process <T> (processData: NSData -> Either<NSError,T>) -> Future<NSError,T>
  {
    let promise = Promise<NSError,T>()
    promise.complete § processData(data)
    return promise.future
  }
}

public class WSClient
{
  public static let sharedInstance = WSClient()
  private var promises = [Int:ResponsePromise]()
  private var incrementalIndex: UniqueIndex = 0
  
  public func requestData (request: NSURLRequest, makeError: (NSError, NSURLResponse?) -> NSError) -> Future<NSError,WSResponse>
  {
    let promise = ResponsePromise()
    let currentIndex = addPromise(promise)
    NSURLSession.sharedSession().dataTaskWithRequest(request) { data, URLResponse, error in
      Queue.main.async {
        self.removePromise(currentIndex)
          >>- verifyRequestError(URLResponse, error, makeError)
          >>- verifyEmptyDataError(data, URLResponse, error, makeError)
          >>- publishResponseIfPossible(data, URLResponse, error)
        
      }
      }
      .resume()
    return promise.future
  }
  
  private func addPromise (promise: ResponsePromise) -> UniqueIndex
  {
    let currentIndex = incrementalIndex
    promises[currentIndex] = promise
    incrementalIndex += 1
    return currentIndex
  }
  
  private func removePromise (index: UniqueIndex) -> ResponsePromise?
  {
    return promises.removeValueForKey(index)
  }
}

//MARK: - private utility

private func verifyRequestError (optionalURLResponse: NSURLResponse?, _ optionalError: NSError?, _ makeError: (NSError, NSURLResponse?) -> NSError) -> ResponsePromise -> ResponsePromise?
{
  return { promise in
    if let
      error = optionalError
    {
      promise.complete § Either.Left § makeError(error, optionalURLResponse)
      return nil
    }
    else
    {
      return promise
    }
  }
}

private func verifyEmptyDataError (optionalData: NSData?, _ optionalURLResponse: NSURLResponse?, _ optionalError: NSError?, _ makeError: (NSError, NSURLResponse?) -> NSError) -> ResponsePromise -> ResponsePromise?
{
  return { promise in
    if optionalData == nil && optionalError == nil
    {
      promise.complete § Either.Left § makeError(emptyDataError,optionalURLResponse)
      return nil
    }
    else
    {
      return promise
    }
  }
}

private func publishResponseIfPossible (optionalData: NSData?, _ optionalURLResponse: NSURLResponse?, _ optionalError: NSError?) -> ResponsePromise -> ResponsePromise?
{
  return { promise in
    if let
      data = optionalData
      where optionalError == nil
    {
      promise.complete § Either.Right § WSResponse(data: data, optionalURLResponse: optionalURLResponse)
      return nil
    }
    else
    {
      return promise
    }
  }
}



