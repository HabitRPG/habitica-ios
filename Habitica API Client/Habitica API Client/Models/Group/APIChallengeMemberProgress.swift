import Foundation
import Habitica_Models

public class APIChallengeMemberProgress: ChallengeMemberProgressProtocol, Codable {
    public var memberID: String?
    public var username: String?
    public var displayName: String?
    public var tasks: [TaskProtocol] = []

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case auth
        case profile
        case tasks
    }
    private enum AuthKeys: String, CodingKey { case local }
    private enum LocalKeys: String, CodingKey { case username }
    private enum ProfileKeys: String, CodingKey { case name }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberID = try? container.decode(String.self, forKey: .id)
        if let auth = try? container.nestedContainer(keyedBy: AuthKeys.self, forKey: .auth),
           let local = try? auth.nestedContainer(keyedBy: LocalKeys.self, forKey: .local) {
            username = try? local.decode(String.self, forKey: .username)
        }
        if let profile = try? container.nestedContainer(keyedBy: ProfileKeys.self, forKey: .profile) {
            displayName = try? profile.decode(String.self, forKey: .name)
        }
        tasks = (try? container.decode([APITask].self, forKey: .tasks)) ?? []
    }

    public func encode(to encoder: Encoder) throws {

    }
}
