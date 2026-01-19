import Foundation
import Firebase
import FirebaseDatabase

final class FirebaseCheckpoint: CheckpointValidator {
    
    private let path = "users/log/data"
    
    func check() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Database.database().reference().child(path)
                .observeSingleEvent(of: .value) { snapshot in
                    if let urlString = snapshot.value as? String,
                       !urlString.isEmpty,
                       URL(string: urlString) != nil {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                } withCancel: { error in
                    continuation.resume(throwing: error)
                }
        }
    }
}
