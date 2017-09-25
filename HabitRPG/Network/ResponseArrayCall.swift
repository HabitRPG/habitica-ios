//
//  ResponseArrayCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork
import Eson
import ReactiveSwift

public class ResponseArrayCall<T: NSObject>: AuthenticatedCall {
    
    func execute() -> SignalProducer<[T]?, NSError> {
        return jsonProducer()
            .flatMap(.concat, parse)
            .flatMapError { error -> SignalProducer<[T]?, NSError> in
                let isHandled = DefaultNetworkErrorHandler.handleError(error: error)
                if !isHandled {
                    
                }
                return SignalProducer(error: error)
        }
    }
    
    func parse(_ json: Any) -> SignalProducer<[T]?, NSError> {
        return SignalProducer(value: json)
            .map { json in
                if let jsonObject = json as? [String: AnyObject], let data = jsonObject["data"] {
                    if data is [Dictionary<String, AnyObject>] {
                        let responseArray = Eson().fromJsonDictionary(json as? [String : AnyObject], clazz: ResponseArray<T>.self)
                        return responseArray?.dataArray()
                    }
                }
                return nil
        }
    }

}
