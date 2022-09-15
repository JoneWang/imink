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
    
    private let logger = APILogger()
    
    let api: API
    
    init() {
        api = API(logger: logger)
    }
    
    func getLog() -> String {
        logger.log
    }
    
    func logIn(codeVerifier: String, sessionTokenCode: String) -> AnyPublisher<(String, Records), Error> {
        let getSessionToken = NSOAPI.sessionToken(codeVerifier: codeVerifier, sessionTokenCode: sessionTokenCode)
        currentStatus.send((getSessionToken, .loading))
        return api.request(getSessionToken)
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
        return api.request(getToken)
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
                return api.request(getMe)
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
        return self.requestLogin(
            accessToken: loginToken.accessToken,
            naUser: naUser
        )
        .map { $0.result }
        .flatMap { loginResult in
            self.requestWebServiceToken(
                webApiServerToken: loginResult.webApiServerCredential.accessToken,
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
            return api.request(getCookie)
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
            return api.request(getRecords)
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
    
    private func requestLogin(
                      accessToken: String,
                      naUser: NAUser) -> AnyPublisher<LoginResult, Error> {
        self.requestF(
            accessToken: accessToken,
            hashMethod: .hash1
        )
        .flatMap { f -> AnyPublisher<LoginResult, Error> in
            let login = NSOAPI.login(
                requestId: f.requestId,
                naIdToken: accessToken,
                naBirthday: naUser.birthday,
                naCountry: naUser.country,
                language: naUser.language,
                timestamp: f.timestamp,
                f: f.f
            )
            currentStatus.send((login, .loading))
            return api.request(login)
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
                                accessToken: String,
                                naUser: NAUser) -> AnyPublisher<WebServiceToken, Error> {
        return self.requestF(
            accessToken: webApiServerToken,
            hashMethod: .hash2
        )
        .flatMap { f -> AnyPublisher<WebServiceToken, Error> in
            let getWebServiceToken = NSOAPI.getWebServiceToken(
                webApiServerToken: webApiServerToken,
                requestId: f.requestId,
                registrationToken: webApiServerToken,
                timestamp: f.timestamp,
                f: f.f
            )
            currentStatus.send((getWebServiceToken, .loading))
            return api.request(getWebServiceToken)
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
    
    private func requestF(
                  accessToken: String,
                  hashMethod: AppAPI.HashMethod) -> AnyPublisher<F, Error> {
        let getF = AppAPI.f(
            naIdToken: accessToken,
            hashMethod: hashMethod
        )
        currentStatus.send((getF, .loading))
        return api.request(getF)
            .decode(type: F.self)
            .receive(on: DispatchQueue.main)
            .mapError { error -> Error in
                currentStatus.send((getF, .fail))
                return error
            }
            .map {
                currentStatus.send((getF, .success))
                return $0
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
        let timestamp: Int64
        let requestId: String
    }
}
