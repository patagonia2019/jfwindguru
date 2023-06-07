//
//  WGError.swift
//  Forescoop
//
//  Created by javierfuchs on 7/11/17.
//
//

import Foundation
/*
 *  WGError
 *
 *  Discussion:
 *    Model object representing an error in a request in Forescoop api.
 *
 * {
 *   "return":"error",
 *   "error_id":2,
 *   "error_message":"Wrong password"
 * }
 */

public class WGError: Mappable {
    var returnString: String?
    var error_id: Int?
    var error_message: String?
    var nserror: NSError?

    public init(code: Int, desc: String, reason: String? = nil, suggestion: String? = nil,
                underError error: NSError? = nil, wgdata : Data? = nil)
    {
        var dict = [String: AnyObject]()
        if let reason = reason {
            dict[NSLocalizedFailureReasonErrorKey] = reason as AnyObject?
        }
        if let suggestion = suggestion {
            dict[NSLocalizedRecoverySuggestionErrorKey] = suggestion as AnyObject?
        }
        if let error = error {
            dict[NSUnderlyingErrorKey] = error
        }
        
        var descValue = desc
        if let wgdata = wgdata,
            let jsonString = String(data: wgdata, encoding: .utf8)
        {
            descValue += " Response IS " + jsonString
        }
        else {
            descValue += " Response EMPTY"
        }
        dict[NSLocalizedDescriptionKey] = descValue as AnyObject?
        
        var id = "Forescoop"
        if let bundleId = Bundle.main.bundleIdentifier {
            id = bundleId
        }
        nserror = NSError(domain: id, code:code, userInfo: dict)
    }
    
    required public init?(map: [String: Any]?){
        mapping(map: map)
    }
    
    public static func isMappable(map: [String:Any]) -> Bool {
        var ret : Bool = true
        for key in ["return", "error_id", "error_message"] {
            ret = ret && map.keys.contains(key)
        }
        return ret
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        returnString = map["return"] as? String
        error_id = map["error_id"] as? Int
        error_message = map["error_message"] as? String
    }
    
    
    public var description : String {
        [
            "\(type(of:self))",
            returnString,
            error_id?.description,
            error_message,
            nserror?.description
        ]
            .compactMap {$0}
            .joined(separator: ", ")
    }
}

extension WGError : Error {
    
    public func title() -> String {
        if let e = nserror {
            return e.localizedDescription
        }
        if let error_message = error_message {
            return error_message
        }
        return "No Title"
    }
    
    public func reason() -> String {
        if let e = nserror,
            let reason = e.localizedFailureReason {
            return reason
        }
        return "No Reason"
    }
    
    public func asDictionary() -> [String : AnyObject]? {
        if let error = nserror {
            return ["code": error.code as AnyObject,
                    NSLocalizedDescriptionKey: error.localizedDescription as AnyObject,
                    NSLocalizedFailureReasonErrorKey: (error.localizedFailureReason ?? "") as AnyObject,
                    NSLocalizedRecoverySuggestionErrorKey: (error.localizedRecoverySuggestion ?? "") as AnyObject,
                    NSUnderlyingErrorKey: "\(error.userInfo)" as AnyObject]
        }
        return nil
    }
        
    public var debugDescription : String {
        var aux : String = "\(type(of:self)): "
        aux += "["
        if let _error = nserror {
            aux += "\(_error.code);"
            aux += "\(_error.localizedDescription);"
            if let _failureReason = _error.localizedFailureReason {
                aux += "\(_failureReason);"
            } else { aux += "();" }
            if let _recoverySuggestion = _error.localizedRecoverySuggestion {
                aux += "\(_recoverySuggestion);"
            } else { aux += "();" }
            aux += "\(_error.userInfo.description);"
        }
        aux += "]"
        return aux
    }
    
    
    public func fatal() {
        fatalError("fatal:\(self.debugDescription)")
    }
    
}

public enum CustomError: Error {
    case cannotFindSpotId

    // Throw when an issue with the parsing
    case invalidParsing

    // Throw in all other cases
    case unexpected(code: Int?, message: String?)
}

extension CustomError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cannotFindSpotId:
            return "The spot id is not right."
        case .invalidParsing:
            return "The pasing is not valid."
        case .unexpected(let code, let message):
            if let code = code, let message = message {
                return "[\(code): \(message)]."
            } else {
                return "An unexpected error occurred"
            }
        }
    }
}
