import CoreGraphics
import Foundation

public final class SmoothScrollEngine {
    public var config: ScrollConfig
    private var physics: SmoothScrollPhysics
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "mousefix.scroll", qos: .userInteractive)
    private var isAnimating = false

    public init(config: ScrollConfig = ScrollConfig()) {
        self.config = config
        self.physics = SmoothScrollPhysics()
    }

    public func handleScrollTick(rawDeltaY: Int64, rawDeltaX: Int64, shiftPressed: Bool = false) {
        queue.async { [weak self] in
            guard let self = self else { return }
            var dy = Double(rawDeltaY) * self.config.stepSize
            var dx = Double(rawDeltaX) * self.config.stepSize

            if self.config.invertDirection {
                dy = -dy
                dx = -dx
            }

            if shiftPressed && self.config.swapAxesOnShift {
                swap(&dy, &dx)
            }

            // If user reverses scroll direction, reset opposing velocity immediately
            if (dy > 0 && self.physics.velocityY < -self.physics.stopThreshold) ||
               (dy < 0 && self.physics.velocityY > self.physics.stopThreshold) ||
               (dx > 0 && self.physics.velocityX < -self.physics.stopThreshold) ||
               (dx < 0 && self.physics.velocityX > self.physics.stopThreshold) {
                self.physics.reset()
            }

            self.physics.addImpulse(deltaY: dy, deltaX: dx)
            if !self.isAnimating {
                self.startAnimationLoop()
            }
        }
    }

    private func startAnimationLoop() {
        isAnimating = true

        let timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        let frameDuration = 1.0 / 120.0 // 120 Hz
        timer.schedule(deadline: .now(), repeating: frameDuration)

        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            let (dy, dx, isFinished) = self.physics.step(deltaTime: frameDuration)

            if isFinished {
                self.stopAnimationLoop()
                return
            }

            if dy != 0 || dx != 0 {
                ScrollEventPoster.post(
                    deltaY: dy,
                    deltaX: dx,
                    phase: 0,
                    momentumPhase: 0,
                    isInverted: self.config.invertDirection
                )
            }
        }

        self.timer = timer
        timer.resume()
    }

    private func stopAnimationLoop() {
        timer?.cancel()
        timer = nil
        isAnimating = false
    }
}
