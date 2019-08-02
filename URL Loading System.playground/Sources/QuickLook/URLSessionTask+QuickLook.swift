import Foundation

extension URLSessionTask: PropertyPlaygroundQuickLookable {
    public var propertyDescriptions: [String] {
        var properties = [String]()
        properties.append("Original Request", with: originalRequest?.propertyDescriptions)
        properties.append("Current Request", with: currentRequest?.propertyDescriptions)
        properties.append("Response", with: response?.propertyDescriptions)
        properties.append("Task Identifier", with: taskIdentifier.description)
        properties.append("Task Description", with: taskDescription)
        properties.append("State", with: state.description)
        properties.append("Error", with: error.debugDescription)
        properties.append("Priority", with: priorityDescription)
        return properties
    }
}

extension URLSessionTask {
    public var priorityDescription: String {
        switch priority {
        case URLSessionTask.highPriority:
            return "high \(priority)"
        case URLSessionTask.defaultPriority:
            return "default \(priority)"
        case URLSessionTask.lowPriority:
            return "low \(priority)"
        default:
            return priority.description
        }
    }
}

extension URLSessionTask.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .running:
            return "running"
        case .suspended:
            return "suspended"
        case .canceling:
            return "canceling"
        case .completed:
            return "completed"
        }
    }
}
