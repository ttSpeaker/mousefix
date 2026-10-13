import CoreGraphics
import Foundation

public struct ScrollEventPoster {
    public static func createEvent(
        deltaY: Double,
        deltaX: Double,
        phase: UInt32 = 2,
        momentumPhase: UInt32 = 0
    ) -> CGEvent? {
        guard let event = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 2,
            wheel1: Int32(round(deltaY)),
            wheel2: Int32(round(deltaX)),
            wheel3: 0
        ) else {
            return nil
        }

        event.setIntegerValueField(.eventSourceUserData, value: EventTapFilter.magicUserData)
        event.setIntegerValueField(.scrollWheelEventIsContinuous, value: 1)
        event.setIntegerValueField(.scrollWheelEventPointDeltaAxis1, value: Int64(round(deltaY)))
        event.setIntegerValueField(.scrollWheelEventFixedPtDeltaAxis1, value: Int64(deltaY * 65536.0))
        event.setIntegerValueField(.scrollWheelEventPointDeltaAxis2, value: Int64(round(deltaX)))
        event.setIntegerValueField(.scrollWheelEventFixedPtDeltaAxis2, value: Int64(deltaX * 65536.0))
        event.setIntegerValueField(.scrollWheelEventScrollPhase, value: Int64(phase))
        event.setIntegerValueField(.scrollWheelEventMomentumPhase, value: Int64(momentumPhase))
        return event
    }

    public static func post(
        deltaY: Double,
        deltaX: Double,
        phase: UInt32 = 2,
        momentumPhase: UInt32 = 0
    ) {
        guard let event = createEvent(deltaY: deltaY, deltaX: deltaX, phase: phase, momentumPhase: momentumPhase) else {
            return
        }
        event.post(tap: .cghidEventTap)
    }
}
