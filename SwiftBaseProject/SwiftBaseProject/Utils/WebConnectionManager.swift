//
//  WebConnectionManager.swift
//  SwiftBaseProject
//
//  Created by KeisukeMasaki on 2018/06/24.
//  Copyright © 2018年 KeisukeMasaki. All rights reserved.
//

import Foundation

enum JSONDecodeError: Error {
    case MissingRequiredKey(String)
    case UnexpectedType(key: String) //, expected: Any.Type) //, actual: Any.Type)
}

enum HTTPMethod: String {
    case OPTIONS
    case GET
    case HEAD
    case POST
    case PUT
    case DELETE
    case TRACE
    case CONNECT
}

struct JSONObject {
    
    let JSON: [String: AnyObject]
    
    func get<T>(key: String) throws -> T {
        guard let value = JSON[key] else {
            throw JSONDecodeError.MissingRequiredKey(key)
        }
        guard let typedValue = value as? T else {
            throw JSONDecodeError.UnexpectedType(key: key) //, expected: T) //, actual: type(of: value.self))
        }
        return typedValue
    }
    
    func get<T>(key: String) throws -> T? {
        guard let value = JSON[key] else {
            return nil
        }
        if value is NSNull {
            return nil
        }
        guard let typedValue = value as? T else {
            throw JSONDecodeError.UnexpectedType(key: key) //, expected: T, actual: value.dynamicType)
        }
        return typedValue
    }
    
}

protocol JSONDecodable {
    init(JSON: JSONObject) throws
}

protocol APIEndpoint {
    var URL: URL { get }
    var method: HTTPMethod { get }
    var query: [String: String]? { get }
    var headers: [String: String]? { get }
    associatedtype ResponseType: JSONDecodable
}

extension APIEndpoint {
    var method: HTTPMethod {
        return .GET
    }
    var query: [String: String]? {
        return nil
    }
    var headers: [String: String]? {
        return nil
    }
    
    var URLRequest: NSURLRequest {
        let components = NSURLComponents(url: URL, resolvingAgainstBaseURL: true)
        components?.queryItems = query?.map(URLQueryItem.init)
        
        let req = NSMutableURLRequest(url: components?.url ?? URL)
        req.httpMethod = method.rawValue
        for (key, value) in headers ?? [:] {
            req.addValue(value, forHTTPHeaderField: key)
        }
        
        return req
    }
}

enum APIError: Error {
    case EmptyBody
    case UnexpectedResponseType
}

enum APIResult<Response> {
    case Success(Response)
    case Failure(Error)
}
