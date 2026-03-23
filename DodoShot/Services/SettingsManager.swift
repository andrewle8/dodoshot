import Foundation
import Combine
import AppKit

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var settings: AppSettings {
        didSet {
            save()
            applyAppearance()
        }
    }

    private let userDefaults = UserDefaults.standard
    private let settingsKey = "LucidaSettings"

    private init() {
        // Migrate from old key if needed (DodoShotSettings -> ShutterSettings -> LucidaSettings)
        if let oldData = userDefaults.data(forKey: "DodoShotSettings") {
            if userDefaults.data(forKey: "ShutterSettings") == nil {
                userDefaults.set(oldData, forKey: "ShutterSettings")
            }
            userDefaults.removeObject(forKey: "DodoShotSettings")
        }
        if let oldData = userDefaults.data(forKey: "ShutterSettings") {
            if userDefaults.data(forKey: settingsKey) == nil {
                userDefaults.set(oldData, forKey: settingsKey)
            }
            userDefaults.removeObject(forKey: "ShutterSettings")
        }

        if let data = userDefaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .default
        }
        // Apply appearance on init
        applyAppearance()
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }

    func reset() {
        settings = .default
        save()
    }

    func applyAppearance() {
        DispatchQueue.main.async {
            switch self.settings.appearanceMode {
            case .system:
                NSApp.appearance = nil
            case .light:
                NSApp.appearance = NSAppearance(named: .aqua)
            case .dark:
                NSApp.appearance = NSAppearance(named: .darkAqua)
            }
        }
    }
}
