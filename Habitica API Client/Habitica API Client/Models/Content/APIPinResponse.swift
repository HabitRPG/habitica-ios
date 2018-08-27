//
//  APIPinResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 17.07.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIPinResponse: PinResponseProtocol, Decodable {
    public var pinnedItems: [PinResponseItemProtocol]
    public var unpinnedItems: [PinResponseItemProtocol]
    
    enum CodingKeys: String, CodingKey {
        case pinnedItems
        case unpinnedItems
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pinnedItems = (try? values.decode([APIPinResponseItem].self, forKey: .pinnedItems)) ?? []
        unpinnedItems = (try? values.decode([APIPinResponseItem].self, forKey: .unpinnedItems)) ?? []
    }
}
