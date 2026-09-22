import Foundation
import Habitica_Models

public class APIChallengeClone: APIChallenge {
    private enum CloneKeys: String, CodingKey {
        case clonedChallenge
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CloneKeys.self)
        let nested = try container.superDecoder(forKey: .clonedChallenge)
        try super.init(from: nested)
    }
}
