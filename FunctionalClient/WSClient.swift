import Foundation
import FunctionalSwift
import FunctionalForm

private typealias ResponsePromise = Promise<WSResponse,NSError>
private var _wsClientSharedInstance = WSClient()
private let emptyDataError = NSError(domain: "WSClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "received empty data"])

public typealias UniqueIndex = Int
public typealias WSResult = Result<WSResponse,NSError>

public struct WSResponse {
    
    public let data: NSData
    public let optionalURLResponse: NSURLResponse?
    
    public init (data: NSData, optionalURLResponse: NSURLResponse?) {
        self.data = data
        self.optionalURLResponse = optionalURLResponse
    }
}

public class WSClient {
    
    public class var sharedInstance: WSClient {
        return _wsClientSharedInstance
    }
    
    private var promises = [Int:ResponsePromise]()
    private var incrementalIndex: UniqueIndex = 0
}

extension WSClient {
    
    public func requestData (request: NSURLRequest, makeError: (NSError, NSURLResponse?) -> NSError) -> Future<WSResponse,NSError> {
        
        let promise = ResponsePromise()
        
        let currentIndex = self.addPromise(promise)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { data, URLResponse, error in
            Queue.main.async {
                self.removePromise(currentIndex)
                    >>> verifyRequestError(URLResponse, error, makeError)
                    >>> verifyEmptyDataError(data, URLResponse, error, makeError)
                    >>> publishResponseIfPossible(data, URLResponse, error)
                
            }
        } .resume()
        
        return promise.future
    }
}

extension WSClient {
    
    private func addPromise (promise: ResponsePromise) -> UniqueIndex {
        
        let currentIndex = self.incrementalIndex
        self.promises[currentIndex] = promise
        self.incrementalIndex += 1
        
        return currentIndex
    }
    
    private func removePromise (index: UniqueIndex) -> ResponsePromise? {
        return self.promises.removeValueForKey(index)
    }
}

/// MARK: - utility

private func verifyRequestError (optionalURLResponse: NSURLResponse?, optionalError: NSError?, makeError: (NSError, NSURLResponse?) -> NSError)(promise: ResponsePromise) -> ResponsePromise? {
    if let error = optionalError {
        promise.complete § failure § makeError(error, optionalURLResponse)
        return nil
    }
    else {
        return promise
    }
}

private func verifyEmptyDataError (optionalData: NSData?, optionalURLResponse: NSURLResponse?, optionalError: NSError?, makeError: (NSError, NSURLResponse?) -> NSError)(promise: ResponsePromise) -> ResponsePromise? {
    if optionalData == nil && optionalError == nil {
        promise.complete § failure § makeError(emptyDataError,optionalURLResponse)
        return nil
    }
    else {
        return promise
    }
}

private func publishResponseIfPossible (optionalData: NSData?, optionalURLResponse: NSURLResponse?, optionalError: NSError?)(promise: ResponsePromise) -> ResponsePromise? {
    if let data = optionalData where optionalError == nil {
        promise.complete § success § WSResponse(data: data, optionalURLResponse: optionalURLResponse)
        return nil
    }
    else {
        return promise
    }
}

/// MARK: - generic process procedure

public func processResponse <T> (response: WSResponse, #processData: NSData -> Result<T,NSError>) -> Future<T,NSError> {
    let promise = Promise<T,NSError>()
    promise.complete § processData(response.data)
    return promise.future
}


