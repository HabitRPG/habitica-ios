import Foundation
import Habitica_Models

public class UnlinkOneTaskCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(taskID: String, keepOption: String) {
        super.init(httpMethod: .POST, endpoint: "tasks/unlink-one/\(taskID)?keep=\(keepOption)")
    }
}
