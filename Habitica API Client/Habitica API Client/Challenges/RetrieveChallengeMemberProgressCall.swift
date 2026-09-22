import Foundation
import Habitica_Models

public class RetrieveChallengeMemberProgressCall: ResponseObjectCall<ChallengeMemberProgressProtocol, APIChallengeMemberProgress> {
    public init(challengeID: String, memberID: String) {
        super.init(httpMethod: .GET, endpoint: "challenges/\(challengeID)/members/\(memberID)")
    }
}
