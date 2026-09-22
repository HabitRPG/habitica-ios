import Foundation
import Habitica_Models

public class CloneChallengeCall: ResponseObjectCall<ChallengeProtocol, APIChallengeClone> {
    public init(challengeID: String, challenge: ChallengeProtocol) {
        let encoder = JSONEncoder()
        encoder.setHabiticaDateEncodingStrategy()
        let json = try? encoder.encode(APIChallenge(challenge))
        super.init(httpMethod: .POST, endpoint: "challenges/\(challengeID)/clone", postData: json)
    }
}
