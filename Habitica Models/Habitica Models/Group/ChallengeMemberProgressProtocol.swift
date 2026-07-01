import Foundation

public protocol ChallengeMemberProgressProtocol {
    var memberID: String? { get set }
    var username: String? { get set }
    var displayName: String? { get set }
    var tasks: [TaskProtocol] { get set }
}
