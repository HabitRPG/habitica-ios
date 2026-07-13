import Foundation
import Habitica_Models

public class ClearFlagsChallengeCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(challengeID: String) {
        super.init(httpMethod: .POST, endpoint: "challenges/\(challengeID)/clearflags")
    }
}
