//
//  RetrieveContentCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveContentCall: ResponseObjectCall<ContentProtocol, APIContent> {
    public init(language: String? = nil, forceLoading: Bool = false) {
        let url = language != nil ? "content?language=\(language ?? "")" : "content"
        super.init(httpMethod: .GET, endpoint: url, needsAuthentication: false, ignoreEtag: forceLoading)
    }
}
