//
//  ResponseArrayCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
import UIKit
import FunkyNetwork
import ReactiveSwift
import Result

public class ResponseArrayCall<T: Any, C: Codable>: AuthenticatedCall {
    public lazy var arraySignal: Signal<[T]?, NoError> = jsonSignal.map(type(of: self).parse)
    
    static func parse(_ json: Any) -> [T]? {
        guard let jsonValue = json as? Dictionary<String, Any> else {
            return nil
        }
        
        guard let jsonData = jsonValue["data"] else {
            return nil
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: jsonData) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.setHabiticaDateDecodingStrategy()
        do {
            return try decoder.decode([C].self, from: data) as? [T]
        } catch {
            print(error)
        }

        return nil
    }
    
}
