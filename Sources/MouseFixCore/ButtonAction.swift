import CoreGraphics
import Foundation

public enum ButtonAction: Equatable, Sendable, Codable {
    case swipeBack
    case swipeForward
    case smartZoom
    case missionControl
    case appExpose
    case showDesktop
    case customKey(keyCode: CGKeyCode, flags: UInt64)

    private enum CodingKeys: String, CodingKey {
        case type, keyCode, flags
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "swipeBack": self = .swipeBack
        case "swipeForward": self = .swipeForward
        case "smartZoom": self = .smartZoom
        case "missionControl": self = .missionControl
        case "appExpose": self = .appExpose
        case "showDesktop": self = .showDesktop
        case "customKey":
            let code = try container.decode(CGKeyCode.self, forKey: .keyCode)
            let flags = try container.decode(UInt64.self, forKey: .flags)
            self = .customKey(keyCode: code, flags: flags)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown action: \(type)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .swipeBack: try container.encode("swipeBack", forKey: .type)
        case .swipeForward: try container.encode("swipeForward", forKey: .type)
        case .smartZoom: try container.encode("smartZoom", forKey: .type)
        case .missionControl: try container.encode("missionControl", forKey: .type)
        case .appExpose: try container.encode("appExpose", forKey: .type)
        case .showDesktop: try container.encode("showDesktop", forKey: .type)
        case .customKey(let code, let flags):
            try container.encode("customKey", forKey: .type)
            try container.encode(code, forKey: .keyCode)
            try container.encode(flags, forKey: .flags)
        }
    }
}
