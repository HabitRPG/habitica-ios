//
//  JsonDataHandler.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import Foundation

public class JsonDataHandler {
    public static func serialize(_ data: Data) -> Any? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            return json
        } catch {
            return nil
        }
    }
    
    public static func deserialize(_ json: Any?) -> Data? {
        if let jsonObject = json {
            do {
                let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                return data
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
