//
//  HabiticaResponseCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import FunkyNetwork
import ReactiveSwift
import Result

class HabiticaResponseCall<T: Any, C: Codable>: AuthenticatedCall {
    public lazy var habiticaResponseSignal: Signal<HabiticaResponse<C>?, NoError> = jsonSignal.map({ json in
        return json as? Dictionary<String, Any>
    })
        .skipNil()
        .map { (jsonData) -> Data? in
            return try? JSONSerialization.data(withJSONObject: jsonData)
        }
        .skipNil()
        .map(type(of: self).parse)
    
    static func parse(_ data: Data) -> HabiticaResponse<C>? {
        let decoder = JSONDecoder()
        decoder.setHabiticaDateDecodingStrategy()
        do {
            return try decoder.decode(HabiticaResponse<C>.self, from: data)
        } catch {
            print(error)
        }
        
        return nil
    }
    
    override func setupErrorHandler() {
        AuthenticatedCall.errorHandler?.observe(signal: serverErrorSignal.withLatest(from: habiticaResponseSignal)
            .map({ (error, response) -> (NSError, String?) in
                return (error, response?.message)
            }))
    }
}
