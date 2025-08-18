//
//  File.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APILoginResponse: LoginResponseProtocol, Decodable {
    public var id: String?
    public var apiToken: String?
    public var newUser: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case apiToken
        case newUser
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? values.decode(String.self, forKey: .id)) ?? ""
        apiToken = (try? values.decode(String.self, forKey: .apiToken)) ?? ""
        newUser = (try? values.decode(Bool.self, forKey: .newUser)) ?? false
    }
    
    public init() {
        
    }
}
