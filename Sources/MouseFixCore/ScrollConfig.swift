import Foundation

public struct ScrollConfig: Equatable, Sendable, Codable {
    public var invertDirection: Bool
    public var swapAxesOnShift: Bool
    public var stepSize: Double

    public init(
        invertDirection: Bool = true,
        swapAxesOnShift: Bool = true,
        stepSize: Double = 35.0
    ) {
        self.invertDirection = invertDirection
        self.swapAxesOnShift = swapAxesOnShift
        self.stepSize = stepSize
    }
}
