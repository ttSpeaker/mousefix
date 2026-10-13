import Foundation

public struct AppConfig: Equatable, Sendable, Codable {
    public var scroll: ScrollConfig
    public var buttons: [Int: ButtonMapping]
    public var holdDuration: TimeInterval

    public init(
        scroll: ScrollConfig = ScrollConfig(),
        buttons: [Int: ButtonMapping] = ButtonMapping.defaults,
        holdDuration: TimeInterval = 0.3
    ) {
        self.scroll = scroll
        self.buttons = buttons
        self.holdDuration = holdDuration
    }

    public static var defaultConfigURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".config/mousefix/config.json")
    }

    public static func load(from url: URL = defaultConfigURL) -> AppConfig {
        guard let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(AppConfig.self, from: data) else {
            return AppConfig()
        }
        return config
    }

    public func save(to url: URL = defaultConfigURL) throws {
        let folder = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        try data.write(to: url, options: .atomic)
    }
}
