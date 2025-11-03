import Foundation
import Habitica_Models
import ReactiveSwift

public class RebirthCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init() {
        super.init(httpMethod: .POST, endpoint: "user/rebirth", postData: nil)
    }
}
