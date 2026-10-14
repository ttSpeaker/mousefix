import CoreGraphics
import Foundation

public enum ButtonAction: String, Equatable, Sendable, Codable, CaseIterable {
    case moveLeftSpace = "moveLeftSpace"
    case moveRightSpace = "moveRightSpace"
    case missionControl = "missionControl"
    case appExpose = "appExpose"
    case showDesktop = "showDesktop"
    case swipeBack = "swipeBack"
    case swipeForward = "swipeForward"
    case smartZoom = "smartZoom"

    public var displayName: String {
        switch self {
        case .moveLeftSpace: return "Move Left a Space"
        case .moveRightSpace: return "Move Right a Space"
        case .missionControl: return "Mission Control"
        case .appExpose: return "Application Windows"
        case .showDesktop: return "Show Desktop"
        case .swipeBack: return "Navigate Back"
        case .swipeForward: return "Navigate Forward"
        case .smartZoom: return "Smart Zoom"
        }
    }
}
