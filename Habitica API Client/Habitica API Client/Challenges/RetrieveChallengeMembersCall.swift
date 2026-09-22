import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveChallengeMembersCall: ResponseArrayCall<MemberProtocol, APIMember> {
    public init(challengeID: String, includeAllPublicFields: Bool = true, lastID: String? = nil, search: String? = nil) {
        var endpoint = "challenges/\(challengeID)/members"
        var query: [String] = []
        if includeAllPublicFields {
            query.append("includeAllPublicFields=true")
        }
        if let lastID = lastID, !lastID.isEmpty {
            query.append("lastId=\(lastID)")
        }
        if let search = search, !search.isEmpty, let escaped = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            query.append("search=\(escaped)")
        }
        if !query.isEmpty {
            endpoint += "?" + query.joined(separator: "&")
        }
        super.init(httpMethod: .GET, endpoint: endpoint)
    }
}
