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
    case userGameDataNotExist
}

struct NSOAuthorization {
    var currentStatus = PassthroughSubject<(APITargetType, ProgressStatus), Never>()
    
    func logIn(codeVerifier: String, sessionTokenCode: String) -> AnyPublisher<(String, Records), Error> {
        let getSessionToken = NSOAPI.sessionToken(codeVerifier: codeVerifier, sessionTokenCode: sessionTokenCode)
        currentStatus.send((getSessionToken, .loading))
        return getSessionToken.request()
            .decode(type: SessionTokenInfo.self)
            .receive(on: DispatchQueue.main)
            .mapError { error -> Error in
                currentStatus.send((getSessionToken, .fail))
                return error
            }
            .map { $0.sessionToken }
            .flatMap { sessionToken -> AnyPublisher<(String, Records), Error> in
                currentStatus.send((getSessionToken, .success))
                return self.getIKsmSession(sessionToken: sessionToken)
            }
            .eraseToAnyPublisher()
    }
    
    func getIKsmSession(sessionToken: String) -> AnyPublisher<(String, Records), Error> {
        let getToken = NSOAPI.token(sessionToken: sessionToken)
        currentStatus.send((getToken, .loading))
        return getToken.request()
            .decode(type: LoginToken.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .mapError({ error -> Error in
                currentStatus.send((getToken, .fail))
                if case APIError.requestParameterError = error {
                    return NSOError.sessionTokenInvalid
                } else {
                    return error
                }
            })
            .flatMap { loginToken -> AnyPublisher<(LoginToken, NAUser), Error> in
                currentStatus.send((getToken, .success))
                let getMe = NSOAPI.me(accessToken: loginToken.accessToken)
                currentStatus.send((getMe, .loading))
                return getMe.request()
                    .decode(type: NAUser.self)
                    .receive(on: DispatchQueue.main)
                    .mapError { error -> Error in
                        currentStatus.send((getMe, .fail))
                        return error
                    }
                    .map { naUser -> (LoginToken, NAUser) in
                        currentStatus.send((getMe, .success))
                        return (loginToken, naUser)
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { (loginToken, naUser) -> AnyPublisher<(String, Records), Error> in
                self.getIksmSession(loginToken: loginToken, naUser: naUser)
                    .map { (sessionToken, $0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getIksmSession(loginToken: LoginToken, naUser: NAUser) -> AnyPublisher<Records, Error> {
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
            let getCookie = Splatoon2API.root(
                language: naUser.language,
                gameWebToken: webServiceToken.result.accessToken
            )
            currentStatus.send((getCookie, .loading))
            return getCookie.request()
                .receive(on: DispatchQueue.main)
                .mapError { error -> Error in
                    currentStatus.send((getCookie, .fail))
                    return error
                }
                .map { (_: Data) in
                    currentStatus.send((getCookie, .success))
                    return ()
                }
                .eraseToAnyPublisher()
        }
        .flatMap { _ -> AnyPublisher<Records, Error> in
            let getRecords = Splatoon2API.records
            currentStatus.send((getRecords, .loading))
            return getRecords.request()
                .receive(on: DispatchQueue.main)
                .mapError({ error -> Error in
                    currentStatus.send((getRecords, .fail))
                    if case APIError.internalServerError = error {
                        return NSOError.userGameDataNotExist
                    } else {
                        return error
                    }
                })
                .compactMap { (data: Data) -> Records? in
                    currentStatus.send((getRecords, .success))
                    // Cache
                    AppUserDefaults.shared.splatoon2RecordsData = data
                    return data.decode(Records.self)
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private func requestLogin(requestId: String,
                      accessToken: String,
                      timestamp: String,
                      naUser: NAUser) -> AnyPublisher<LoginResult, Error> {
        self.requestF(
            requestId: requestId,
            accessToken: accessToken,
            timestamp: timestamp,
            hashMethod: .hash1
        )
        .flatMap { f -> AnyPublisher<LoginResult, Error> in
            let login = NSOAPI.login(
                requestId: requestId,
                naIdToken: accessToken,
                naBirthday: naUser.birthday,
                naCountry: naUser.country,
                language: naUser.language,
                timestamp: timestamp,
                f: f
            )
            currentStatus.send((login, .loading))
            return login.request()
                .decode(type: LoginResult.self)
                .receive(on: DispatchQueue.main)
                .mapError { error -> Error in
                    currentStatus.send((login, .fail))
                    return error
                }
                .map {
                    currentStatus.send((login, .success))
                    return $0
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private func requestWebServiceToken(webApiServerToken: String,
                                requestId: String,
                                accessToken: String,
                                naUser: NAUser) -> AnyPublisher<WebServiceToken, Error> {
        let requestId = UUID().uuidString.lowercased()
        let timestamp = "\(Int(Date().timeIntervalSince1970))"
        return self.requestF(
            requestId: requestId,
            accessToken: webApiServerToken,
            timestamp: timestamp,
            hashMethod: .hash2
        )
        .flatMap { f -> AnyPublisher<WebServiceToken, Error> in
            let getWebServiceToken = NSOAPI.getWebServiceToken(
                webApiServerToken: webApiServerToken,
                requestId: requestId,
                registrationToken: webApiServerToken,
                timestamp: timestamp,
                f: f
            )
            currentStatus.send((getWebServiceToken, .loading))
            return getWebServiceToken.request()
                .decode(type: WebServiceToken.self)
                .receive(on: DispatchQueue.main)
                .mapError { error -> Error in
                    currentStatus.send((getWebServiceToken, .fail))
                    return error
                }
                .map { token -> WebServiceToken in
                    currentStatus.send((getWebServiceToken, .success))
                    return token
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private func requestF(requestId: String,
                  accessToken: String,
                  timestamp: String,
                  hashMethod: AppAPI.HashMethod) -> AnyPublisher<String, Error> {
        let getF = AppAPI.f(
            naIdToken: accessToken,
            requestId: requestId,
            timestamp: timestamp,
            hashMethod: hashMethod
        )
        currentStatus.send((getF, .loading))
        return getF.request()
            .decode(type: F.self)
            .receive(on: DispatchQueue.main)
            .mapError { error -> Error in
                currentStatus.send((getF, .fail))
                return error
            }
            .map {
                currentStatus.send((getF, .success))
                return $0.f
            }
            .eraseToAnyPublisher()
    }
}

extension NSOAuthorization {
    
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
        let f: String
    }
}
