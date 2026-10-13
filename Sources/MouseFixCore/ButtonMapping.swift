import Foundation

public struct ButtonMapping: Equatable, Sendable, Codable {
    public var button: Int
    public var clickAction: ButtonAction?
    public var holdAction: ButtonAction?

    public init(button: Int, clickAction: ButtonAction? = nil, holdAction: ButtonAction? = nil) {
        self.button = button
        self.clickAction = clickAction
        self.holdAction = holdAction
    }

    public static var defaults: [Int: ButtonMapping] {
        [
            2: ButtonMapping(button: 2, clickAction: nil, holdAction: .missionControl), // Middle click
            3: ButtonMapping(button: 3, clickAction: .swipeBack, holdAction: .missionControl), // Back button
            4: ButtonMapping(button: 4, clickAction: .swipeForward, holdAction: .smartZoom) // Forward button
        ]
    }
}
