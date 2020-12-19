//

//  API.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation
import Combine
import os

// FIXME: token invalid
/// Wrapping up request
//extension APITargetType {
//    func request() -> AnyPublisher<Data, APIError> {
//        API.shared.request(self)
//            .mapError { error -> APIError in
//                if case APIError.authorizationError = error {
//                    if type(of: self) is AppAPI.Type {
//                        os_log("API Error: client_token error")
//                        AppUserDefaults.shared.clientToken = nil
//                        AppUserDefaults.shared.user = nil
//                        return .clientTokenInvalid
//                    }
//                }
//
//                return error
//            }
//            .eraseToAnyPublisher()
//    }
//}
