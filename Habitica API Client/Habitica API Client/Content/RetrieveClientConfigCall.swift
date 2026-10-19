import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveClientConfigCall: ResponseObjectCall<[String: JSONValue], [String: JSONValue]> {
    public init() {
        super.init(httpMethod: .GET, endpoint: "client-config", needsAuthentication: false)
    }
}
