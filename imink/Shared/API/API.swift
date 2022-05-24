//

//  API.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation
import Combine
import os

enum ProgressStatus: String {
    case loading
    case success
    case fail
}

enum APIError: Error, LocalizedError {
    case unknown
    case apiError(reason: String)
    case authorizationError(response: HTTPURLResponse)
    case clientTokenInvalid
    case iksmSessionInvalid
    case requestParameterError
    case internalServerError
    
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
        case .internalServerError:
            return "internal server error"
        }
    }
}

class API {
    static let shared = API()
    
    private var logger: APILogger? = nil
    
    init(logger: APILogger? = nil) {
        self.logger = logger
    }
    
    private func req(_ api: APITargetType) -> AnyPublisher<(Data, HTTPURLResponse), APIError> {
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
        sessionConfiguration.httpCookieStorage = HTTPCookieStorage.appGroup
        let urlSession = URLSession(configuration: sessionConfiguration)
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                
                if 401...403 ~= httpResponse.statusCode {
                    throw APIError.authorizationError(response: httpResponse)
                }
                
                if httpResponse.statusCode == 400 {
                    throw APIError.requestParameterError
                }
                
                if httpResponse.statusCode == 500 {
                    throw APIError.internalServerError
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw APIError.unknown
                }
                
                if let logger = self?.logger {
                    logger.res(data: data, response: httpResponse)
                }
                
                return (data, httpResponse)
            }
            .mapError { [weak self] error in
                self?.logger?.err(error)
                
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.apiError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension API {
    func request(_ api: APITargetType) -> AnyPublisher<Data, Error> {
        request(api)
            .map { result in result.0 }
            .eraseToAnyPublisher()
    }
    
    func request(_ api: APITargetType) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        req(api)
            .mapError { error -> APIError in
                if case APIError.authorizationError(let response) = error {
                    if type(of: api) is Splatoon2API.Type {
                        os_log("API Error: [splatoon2] iksm_session error")
                        
                        // Remove invalid iksm_session
                        if let fields = response.allHeaderFields as? [String: String],
                           let url = response.url,
                           let iksmSessionCookie = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
                            .first(where: { $0.name == "iksm_session" }) {
                            IksmSessionManager.shared.clear(iksmSession: iksmSessionCookie.value)
                        }
                        
                        return .iksmSessionInvalid
                    }
                }

                return error
            }
            .mapError { $0 as Error }
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
        API.shared.request(self)
    }
    
    func request() -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        API.shared.request(self)
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
