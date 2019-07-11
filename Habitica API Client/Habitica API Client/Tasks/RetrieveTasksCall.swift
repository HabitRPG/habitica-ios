//
//  RetrieveTasksAPICall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveTasksCall: ResponseArrayCall<TaskProtocol, APITask> {
    public init(dueOnDay: Date? = nil, type: String? = nil, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        var url = "tasks/user"
        if let date = dueOnDay {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            var dateString = formatter.string(from: date)
            let regex = try? NSRegularExpression(pattern: "T([0-9]):", options: .caseInsensitive)
            dateString = regex?.stringByReplacingMatches(in: dateString, options: [], range: NSRange(location: 0, length: dateString.count), withTemplate: "T0$1:") ?? ""
            url = "\(url)?type=dailys&dueDate=\(dateString)"
            url = url.replacingOccurrences(of: "+", with: "%2B")
        }
        if let type = type {
            url = "\(url)?type=\(type)"
        }
        super.init(httpMethod: .GET, endpoint: url, stubHolder: stubHolder)
    }
}
