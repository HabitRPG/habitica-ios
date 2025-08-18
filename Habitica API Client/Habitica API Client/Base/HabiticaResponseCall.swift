//
//  HabiticaResponseCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_Models

extension Notification.Name {
    public static let invalidCredentials = Notification.Name("InvalidCredentialsLogout")
}

public class HabiticaResponseCall<T: Any, C: Decodable>: AuthenticatedCall {
    
    public lazy var habiticaResponseSignal: Signal<HabiticaResponse<C>?, Never> = jsonSignal.map({ json in
        return json as? [String: Any]
    })
        .skipNil()
        .map { (jsonData) -> Data? in
            return try? JSONSerialization.data(withJSONObject: jsonData)
        }
        .skipNil()
        .map(type(of: self).parse)
        .merge(with: errorDataSignal.map { _ -> HabiticaResponse<C>? in
            return nil
        })
        .take(first: 1)
        .on(value: {response in
            AuthenticatedCall.notificationListener?(response?.notifications)
        })
    
    static func parse(_ data: Data) -> HabiticaResponse<C>? {
        let decoder = JSONDecoder()
        decoder.setHabiticaDateDecodingStrategy()
        do {
            return try decoder.decode(HabiticaResponse<C>.self, from: data)
        } catch {
            if let handler  = self.errorHandler,
               let netError = error as? NetworkError {
                type(of: handler).handle(error: netError, messages: [])
            }
        }
        return nil
    }
    
    override func setupErrorHandler() {
        let handler = customErrorHandler ?? AuthenticatedCall.errorHandler

        handler?.observe(
          signal: errorSignal.map { nsErr in
            ( NetworkError(
                message: nsErr.localizedDescription,
                url: "",
                code: nsErr.code
              ),
              []
            )
          }
        )
        
        handler?.observe(signal: serverErrorSignal.combineLatest(with: errorJsonSignal)
            .map({ (error, jsonAny) -> (NetworkError, [String]) in
                let json = jsonAny
                var errors = [String]()
                let errorCode = error.code
                
                // check for invalid_credentials error
                if error.code == 401 {
                    if let errorField = json["error"] as? String {
                        if errorField.lowercased() == "invalid_credentials" {
                            let excludedPaths = ["/user/auth/update-password", "group-plans"]
                            let shouldLogout = !excludedPaths.contains(where: { self.urlString.contains($0) })
                            
                            if shouldLogout {
                                // Add invalid_credentials to the errors array so NetworkErrorHandler can suppress it
                                errors.append("invalid_credentials")
                                NotificationCenter.default.post(name: .invalidCredentials, object: nil)
                            }
                        }
                    }
                }
                
                if let jsonErrors = json["errors"] as? [[String: Any]] {
                    for jsonError in jsonErrors {
                        if let errorMessage = jsonError["message"] as? String {
                            errors.append(errorMessage)
                        }
                    }
                }
                if let message = json["message"] as? String {
                    errors.append(message)
                }
                return (NetworkError(message: error.localizedDescription, url: (error.userInfo["url"] as? String) ?? "", code: errorCode), errors)
            }))
    }
}
