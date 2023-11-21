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
            if let errorHandler = self.errorHandler, let networkError = error as? NetworkError {
                type(of: errorHandler).handle(error: networkError, messages: [])
            }
        }
        return nil
    }
    
    override func setupErrorHandler() {
        let errorHandler = customErrorHandler ?? AuthenticatedCall.errorHandler
        errorHandler?.observe(signal: errorSignal)
        errorHandler?.observe(signal: errorJsonSignal.map({ json -> [NetworkError] in
            var errors = [NetworkError]()
            var isNotFound = false
            if let error = json["error"] as? String, error == "NotFound" {
                isNotFound = true
            }
            if let jsonErrors = json["errors"] as? [[String: Any]] {
                for jsonError in jsonErrors {
                    if let errorMessage = jsonError["message"] as? String {
                        errors.append(NetworkError(message: errorMessage, url: self.urlString, code: isNotFound ? 404 : -1000))
                    }
                }
            }
            if errors.isEmpty, let message = json["message"] as? String {
                errors.append(NetworkError(message: message, url: self.urlString, code: isNotFound ? 404 : -1000))
            }
            return errors
        }))
        errorHandler?.observe(signal: serverErrorSignal.combineLatest(with: jsonSignal)
            .map({ (error, jsonAny) -> (NetworkError, [String]) in
                let json = jsonAny as? [String: Any]
                var errors = [String]()
                if let jsonErrors = json?["errors"] as? [[String: Any]] {
                    for jsonError in jsonErrors {
                        if let errorMessage = jsonError["message"] as? String {
                            errors.append(errorMessage)
                        }
                    }
                }
                if let message = json?["message"] as? String {
                    errors.append(message)
                }
                return (NetworkError(message: error.localizedDescription, url: (error.userInfo["url"] as? String) ?? "", code: error.code), errors)
            }))
    }
}
