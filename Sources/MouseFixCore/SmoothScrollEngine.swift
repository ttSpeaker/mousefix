import CoreGraphics
import Foundation

public final class SmoothScrollEngine {
    public var config: ScrollConfig
    private var physics: SmoothScrollPhysics
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "mousefix.scroll", qos: .userInteractive)
    private var isAnimating = false
    private var phase: UInt32 = 1

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

            self.physics.addImpulse(deltaY: dy, deltaX: dx)
            if !self.isAnimating {
                self.startAnimationLoop()
            }
        }
    }

    private func startAnimationLoop() {
        isAnimating = true
        phase = 1 // Began

        let timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        let frameDuration = 1.0 / 120.0 // 120 Hz
        timer.schedule(deadline: .now(), repeating: frameDuration)

        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            let (dy, dx, isFinished) = self.physics.step(deltaTime: frameDuration)

            if isFinished {
                ScrollEventPoster.post(deltaY: 0, deltaX: 0, phase: 4, momentumPhase: 0) // Ended
                self.stopAnimationLoop()
                return
            }

            if dy != 0 || dx != 0 {
                ScrollEventPoster.post(deltaY: dy, deltaX: dx, phase: self.phase, momentumPhase: 0)
                if self.phase == 1 { self.phase = 2 } // Transition to Changed
            }
        }

        self.timer = timer
        timer.resume()
    }

    private func stopAnimationLoop() {
        timer?.cancel()
        timer = nil
        isAnimating = false
        phase = 1
    }
}
