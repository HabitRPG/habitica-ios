import Foundation
import Habitica_Models

public class SelectChallengeWinnerCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(challengeID: String, winnerID: String) {
        super.init(httpMethod: .POST, endpoint: "challenges/\(challengeID)/selectWinner/\(winnerID)")
    }
}
