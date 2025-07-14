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
                url:     "",
                code:    nsErr.code
              ),
              []
            )
          }
        )

        // HTTP 4xx/5xx + JSON body together
        handler?.observe(
          signal: serverErrorSignal
            .combineLatest(with: errorJsonSignal)
            .map { (nsErr, json) -> (NetworkError, [String]) in
              // build the NetworkError with the real status code
              let netErr = NetworkError(
                message: nsErr.localizedDescription,
                url:     (nsErr.userInfo["url"] as? String) ?? "",
                code:    nsErr.code
              )

              // extract any server‐sent messages
              var msgs: [String] = []
              if let top = json["message"] as? String {
                msgs.append(top)
              }
              if let errors = json["errors"] as? [[String: Any]] {
                for err in errors {
                  if let message = err["message"] as? String {
                    msgs.append(message)
                  }
                }
              }

              return (netErr, msgs)
            }
        )
    }
}
