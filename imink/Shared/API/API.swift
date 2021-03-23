//

//  API.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation
import Combine
import os

enum APIError: Error, LocalizedError {
    case unknown
    case apiError(reason: String)
    case authorizationError
    case clientTokenInvalid
    case iksmSessionInvalid
    case requestParameterError
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Error connecting to the server"
        case .apiError(let reason):
            return reason
        case .authorizationError:
            return "Authorization error"
        case .clientTokenInvalid:
            return "Client token is invalid"
        case .iksmSessionInvalid:
            return "The iksm_session is invalid"
        case .requestParameterError:
            return "Request paraemter error"
        }
    }
}

class API {
    static let shared = API()
    
    func request(_ api: APITargetType) -> AnyPublisher<(Data, HTTPURLResponse), APIError> {
        let url = api.baseURL.appendingPathComponent(api.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if let querys = api.querys {
            let queryItems = querys.map { name, value in
                URLQueryItem(name: name, value: value)
            }
            urlComponents.queryItems = queryItems
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = api.method.rawValue
        
        if let headers = api.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // TODO: Request parameter: query & body data
        
        if let data = api.data {
            request.addValue(data.contentType, forHTTPHeaderField: "Content-Type")
            switch data {
            case .jsonData(let data):
                request.httpBody = data.toJSONData()
            case .form(let form):
                let queryItems = form.map { name, value in
                    URLQueryItem(name: name, value: value)
                }
                urlComponents.queryItems = queryItems
                request.httpBody = urlComponents.query?.data(using: .utf8)
            }
        }
        
        let sessionConfiguration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: sessionConfiguration)
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                
                if 401...403 ~= httpResponse.statusCode {
                    throw APIError.authorizationError
                }
                
                if httpResponse.statusCode == 400 {
                    throw APIError.requestParameterError
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw APIError.unknown
                }
                
                return (data, httpResponse)
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.apiError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Encodable {
    func toJSONData() -> Data? { try? JSONEncoder().encode(self) }
}

extension MediaType {
    
    var contentType: String {
        switch self {
        case .jsonData:
            return "application/json; charset=utf-8"
        case .form:
            return "application/x-www-form-urlencoded"
        }
    }
    
}

/// Wrapping up request
extension APITargetType {
    func request() -> AnyPublisher<Data, Error> {
        self.request()
            .map { result in result.0 }
            .eraseToAnyPublisher()
    }
    
    func request() -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        API.shared.request(self)
            .mapError { error -> APIError in
                if case APIError.authorizationError = error {
                    if type(of: self) is Splatoon2API.Type {
                        os_log("API Error: [splatoon2] iksm_session error")
                        return .iksmSessionInvalid
                    }
                }

                return .unknown
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

/// JSONDecoder is used by default
extension AnyPublisher where Output == Data {
    public func decode<Item>(
        type: Item.Type
    ) -> Publishers.Decode<Self, Item, JSONDecoder>
    where Item : Decodable {
        let coder = JSONDecoder()
        coder.keyDecodingStrategy = .convertFromSnakeCase
        return self.decode(type: type, decoder: coder)
    }
}
