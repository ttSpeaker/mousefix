import Foundation

public struct SmoothScrollPhysics: Sendable {
    public var friction: Double // Deceleration factor per second (e.g. 0.90)
    public var stopThreshold: Double
    public private(set) var velocityY: Double = 0.0
    public private(set) var velocityX: Double = 0.0
    private var subpixelY: Double = 0.0
    private var subpixelX: Double = 0.0

    public init(friction: Double = 0.92, stopThreshold: Double = 0.1) {
        self.friction = friction
        self.stopThreshold = stopThreshold
    }

    public mutating func addImpulse(deltaY: Double, deltaX: Double) {
        // Accelerate with incoming wheel tick
        velocityY += deltaY
        velocityX += deltaX
    }

    public mutating func step(deltaTime: Double) -> (dy: Double, dx: Double, isFinished: Bool) {
        // Apply friction
        velocityY *= friction
        velocityX *= friction

        if abs(velocityY) < stopThreshold && abs(velocityX) < stopThreshold {
            velocityY = 0.0
            velocityX = 0.0
            subpixelY = 0.0
            subpixelX = 0.0
            return (0.0, 0.0, true)
        }

        // Subpixel accumulation
        let rawY = velocityY * (deltaTime * 60.0) + subpixelY
        let rawX = velocityX * (deltaTime * 60.0) + subpixelX
        let intY = round(rawY)
        let intX = round(rawX)
        subpixelY = rawY - intY
        subpixelX = rawX - intX

        return (intY, intX, false)
    }

    public mutating func reset() {
        velocityY = 0.0
        velocityX = 0.0
        subpixelY = 0.0
        subpixelX = 0.0
    }
}
