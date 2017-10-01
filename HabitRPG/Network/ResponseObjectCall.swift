//
//  ResponseObjectCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/30/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork
import Eson
import ReactiveSwift

class ResponseObjectCall<T: NSObject>: AuthenticatedCall {

    func execute() -> SignalProducer<T?, NSError> {
        return jsonProducer()
            .flatMap(.concat, parse)
            .flatMapError { error -> SignalProducer<T?, NSError> in
                let isHandled = DefaultNetworkErrorHandler.handleError(error: error)
                if !isHandled {
                    
                }
                return SignalProducer(error: error)
        }
    }
    
    func parse(_ json: Any) -> SignalProducer<T?, NSError> {
        return SignalProducer(value: json)
            .map { json in
                if let jsonObject = json as? [String: AnyObject], let data = jsonObject["data"] {
                    if data is Dictionary<String, AnyObject> {
                        let responseObject = Eson().fromJsonDictionary(json as? [String : AnyObject], clazz: ResponseObject<T>.self)
                        return responseObject?.dataObject()
                    }
                }
                return nil
        }
    }
}
