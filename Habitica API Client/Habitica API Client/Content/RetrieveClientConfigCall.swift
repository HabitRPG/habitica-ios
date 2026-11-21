import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveClientConfigCall: ResponseObjectCall<[String: JSONValue], [String: JSONValue]> {
    public init(ignoreEtag: Bool = false) {
        super.init(httpMethod: .GET, endpoint: "client-config", needsAuthentication: false, ignoreEtag: ignoreEtag)
    }
}
