import Foundation
import Habitica_Models

public class DeleteChallengeCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(challengeID: String) {
        super.init(httpMethod: .DELETE, endpoint: "challenges/\(challengeID)")
    }
}
