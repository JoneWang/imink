//
//  APIHelpers.swift
//  imink
//
//  Created by Jone Wang on 2021/3/21.
//

import Foundation
import Combine

enum NSOError: Error {
    case sessionTokenInvalid
}

struct NSOHelper {
    
    static func logIn(codeVerifier: String, sessionTokenCode: String) -> AnyPublisher<(String, Records), Error> {
        NSOAPI.sessionToken(codeVerifier: codeVerifier, sessionTokenCode: sessionTokenCode)
            .request()
            .decode(type: SessionTokenInfo.self)
            .receive(on: DispatchQueue.main)
            .map { $0.sessionToken }
            .flatMap { sessionToken -> AnyPublisher<(String, Records), Error> in
                self.getIKsmSession(sessionToken: sessionToken)
            }
            .eraseToAnyPublisher()
    }
    
    static func getIKsmSession(sessionToken: String) -> AnyPublisher<(String, Records), Error> {
        NSOAPI.token(sessionToken: sessionToken)
            .request()
            .decode(type: LoginToken.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .mapError({ error -> Error in
                if error is DecodingError {
                    return NSOError.sessionTokenInvalid
                } else {
                    return error
                }
            })
            .flatMap { loginToken -> AnyPublisher<(LoginToken, NAUser), Error> in
                NSOAPI.me(accessToken: loginToken.accessToken)
                    .request()
                    .decode(type: NAUser.self)
                    .receive(on: DispatchQueue.main)
                    .map { (loginToken, $0) }
                    .eraseToAnyPublisher()
            }
            .flatMap { (loginToken, naUser) -> AnyPublisher<(String, Records), Error> in
                self.getIksmSession(loginToken: loginToken, naUser: naUser)
                    .map { (sessionToken, $0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    static func getIksmSession(loginToken: LoginToken, naUser: NAUser) -> AnyPublisher<Records, Error> {
        let requestId = UUID().uuidString.lowercased()
        let timestamp = "\(Int(Date().timeIntervalSince1970))"
        return self.requestLogin(
            requestId: requestId,
            accessToken: loginToken.accessToken,
            timestamp: timestamp,
            naUser: naUser
        )
        .map { $0.result }
        .flatMap { loginResult in
            self.requestWebServiceToken(
                webApiServerToken: loginResult.webApiServerCredential.accessToken,
                requestId: requestId,
                accessToken: loginToken.accessToken,
                naUser: naUser
            )
        }
        .map { ($0, naUser) }
        .flatMap { (webServiceToken, naUser) -> AnyPublisher<Void, Error> in
            // Get cookie
            Splatoon2API.root(
                language: naUser.language,
                gameWebToken: webServiceToken.result.accessToken
            )
            .request()
            .receive(on: DispatchQueue.main)
            .map { (_: Data) in () }
            .eraseToAnyPublisher()
        }
        .flatMap { _ -> AnyPublisher<Records, Error> in
            Splatoon2API.records
                .request()
                .receive(on: DispatchQueue.main)
                .compactMap { (data: Data) -> Records? in
                    // Cache
                    AppUserDefaults.shared.splatoon2RecordsData = data
                    return data.decode(Records.self)
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private static func requestLogin(requestId: String,
                      accessToken: String,
                      timestamp: String,
                      naUser: NAUser) -> AnyPublisher<LoginResult, Error> {
        self.requestF(
            requestId: requestId,
            accessToken: accessToken,
            naUser: naUser,
            timestamp: timestamp,
            iid: .nso
        )
        .map { $0.result }
        .flatMap { result -> AnyPublisher<LoginResult, Error> in
            NSOAPI.login(
                requestId: result.p3,
                naIdToken: result.p1,
                naBirthday: naUser.birthday,
                naCountry: naUser.country,
                language: naUser.language,
                timestamp: result.p2,
                f: result.f
            )
            .request()
            .decode(type: LoginResult.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private static func requestWebServiceToken(webApiServerToken: String,
                                requestId: String,
                                accessToken: String,
                                naUser: NAUser) -> AnyPublisher<WebServiceToken, Error> {
        let requestId = UUID().uuidString.lowercased()
        let timestamp = "\(Int(Date().timeIntervalSince1970))"
        return self.requestF(
            requestId: requestId,
            accessToken: webApiServerToken,
            naUser: naUser,
            timestamp: timestamp,
            iid: .app
        )
        .map { $0.result }
        .flatMap { result -> AnyPublisher<WebServiceToken, Error> in
            NSOAPI.getWebServiceToken(
                webApiServerToken: webApiServerToken,
                requestId: result.p3,
                registrationToken: result.p1,
                timestamp: result.p2,
                f: result.f
            )
            .request()
            .decode(type: WebServiceToken.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private static func requestF(requestId: String,
                  accessToken: String,
                  naUser: NAUser,
                  timestamp: String,
                  iid: NSOAPI.Iid) -> AnyPublisher<F, Error> {
        NSOAPI.s2s(naIdToken: accessToken, timestamp: timestamp)
            .request()
            .decode(type: S2SHash.self)
            .receive(on: DispatchQueue.main)
            .flatMap { hash -> AnyPublisher<F, Error> in
                NSOAPI.f(
                    naIdToken: accessToken,
                    requestId: requestId,
                    timestamp: timestamp,
                    s2sHash: hash.hash,
                    iid: iid
                )
                .request()
                .decode(type: F.self)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

extension NSOHelper {
    
    struct SessionTokenInfo: Decodable {
        let sessionToken: String
        let code: String
    }
    
    struct LoginResult: Decodable {
        let result: `Result`
        
        struct `Result`: Decodable {
            let webApiServerCredential: WebApiServerCredential
            
            struct WebApiServerCredential: Decodable {
                let accessToken: String
            }
        }
    }
    
    struct WebServiceToken: Decodable {
        let result: `Result`
        
        struct `Result`: Decodable {
            let accessToken: String
        }
    }
    
    struct S2SHash: Decodable {
        let hash: String
    }
    
    struct F: Decodable {
        let result: `Result`
        
        struct `Result`: Decodable {
            let f: String
            let p1: String
            let p2: String
            let p3: String
        }
    }
}
