//
//  ResponseObject.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
import UIKit

public class ResponseObject<T: Any>: NSObject {
    var success: Bool = false
    var data: [String: AnyObject]?
    
}
