//
//  APIRequestLoader.swift
//  MyFramework
//
//  Created by Ricardo Bailoni on 20/10/19.
//  Copyright © 2019 Ricardo Bailoni. All rights reserved.
//

import Foundation
import Alamofire

public protocol APIRequest {
    associatedtype RequestDataType
    associatedtype ResponseDataType
    func makeRequest(from data: RequestDataType) throws -> URLRequest
    func parseResponse(data: Data) throws -> ResponseDataType
}

public class APIRequestLoader<T: APIRequest> {
    let apiRequest: T
    let urlSession: URLSession
    
    public init(apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }
    
    public func getAlamofireResponse(_ url: String, completion: @escaping (String) -> Void) {
        Alamofire.request(url).responseString { (response) in
            if let json = response.result.value {
                completion(json)
            }
        }
    }
    
    public func loadAPIRequest(requestData: T.RequestDataType, completionHandler: @escaping(T.ResponseDataType?, Error?) -> Void) {
        do {
            let urlRequest = try apiRequest.makeRequest(from: requestData)
            urlSession.dataTask(with: urlRequest) { (data, response, error) in
                guard let data = data else { return completionHandler(nil, error)}
                do {
                    let parseResponse = try self.apiRequest.parseResponse(data: data)
                    completionHandler(parseResponse, nil)
                } catch {
                    completionHandler(nil, error)
                }
            }.resume()
        } catch {
            completionHandler(nil, error)
        }
    }
    
    public func hardCodeData() -> String {
        return "hardCodedString"
    }
}
