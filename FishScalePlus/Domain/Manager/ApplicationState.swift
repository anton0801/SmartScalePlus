import Foundation
import Combine
import Firebase
import FirebaseDatabase

enum ApplicationState: Equatable {
    case initial
    case preparing
    case checking
    case validated
    case active(url: String)
    case idle
    case noConnection
}

struct StateTransition {
    let from: ApplicationState
    let to: ApplicationState
    let trigger: TransitionTrigger
    let timestamp: Date
    
    init(from: ApplicationState, to: ApplicationState, trigger: TransitionTrigger) {
        self.from = from
        self.to = to
        self.trigger = trigger
        self.timestamp = Date()
    }
}

enum TransitionTrigger {
    case appLaunched
    case dataArrived
    case checkPassed
    case checkFailed
    case urlResolved(String)
    case networkDown
    case networkUp
    case timedOut
}

final class StateEngine: ObservableObject {
    
    @Published private(set) var currentState: ApplicationState = .initial
    @Published private(set) var history: [StateTransition] = []
    
    private let validator: CheckpointValidator
    private var isLocked = false
    
    init(validator: CheckpointValidator = FirebaseCheckpoint()) {
        self.validator = validator
    }
    
    func trigger(_ trigger: TransitionTrigger) {
        guard !isLocked else { return }
        
        if let nextState = evaluate(trigger: trigger, from: currentState) {
            recordTransition(to: nextState, trigger: trigger)
            currentState = nextState
            
            if nextState.isTerminal {
                isLocked = true
            }
        }
    }
    
    private func evaluate(trigger: TransitionTrigger, from state: ApplicationState) -> ApplicationState? {
        switch (state, trigger) {
        case (.initial, .appLaunched):
            return .preparing
            
        case (.preparing, .dataArrived):
            return .checking
            
        case (.checking, .checkPassed):
            return .validated
            
        case (.checking, .checkFailed):
            return .idle
            
        case (.validated, .urlResolved(let url)):
            return .active(url: url)
            
        case (_, .networkDown) where !state.isTerminal:
            return .noConnection
            
        case (.noConnection, .networkUp):
            return .idle
            
        case (_, .timedOut) where !state.isTerminal:
            return .idle
            
        default:
            return nil
        }
    }
    
    private func recordTransition(to newState: ApplicationState, trigger: TransitionTrigger) {
        let transition = StateTransition(
            from: currentState,
            to: newState,
            trigger: trigger
        )
        history.append(transition)
    }
    
    func performValidation() async throws {
        let passed = try await validator.check()
        
        if passed {
            trigger(.checkPassed)
        } else {
            trigger(.checkFailed)
            throw ValidationError.denie(message: "Denie")
        }
    }
}

enum ValidationError: Error {
    case denie(message: String)
}

// MARK: - State Extensions
extension ApplicationState {
    var isTerminal: Bool {
        switch self {
        case .active, .idle:
            return true
        default:
            return false
        }
    }
}

// MARK: - Checkpoint Validator Protocol
protocol CheckpointValidator {
    func check() async throws -> Bool
}

// MARK: - Checkpoint Error
enum CheckpointError: Error {
    case failed
    case unavailable
}
