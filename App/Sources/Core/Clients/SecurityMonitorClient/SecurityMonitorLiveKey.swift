import Foundation
import Dependencies
import CoreMotion
import AVFoundation

extension SecurityMonitorClient: DependencyKey {
    private static let monitor = SecurityMonitor()
    
    public static let liveValue = Self(
        monitorConfig: {
            return .init(
                movement: UserDefaults.standard.bool(forKey: "security.movement"),
                power: UserDefaults.standard.bool(forKey: "security.power"),
                headphones: UserDefaults.standard.bool(forKey: "security.headphones")
            )
        },
        updateMonitorConfig: { newConfig in
            if newConfig.movement != UserDefaults.standard.bool(forKey: "security.movement") {
                UserDefaults.standard.set(newConfig.movement, forKey: "security.movement")
                if newConfig.movement {
                    await monitor.startMovementMonitoring()
                } else {
                    await monitor.stopMovementMonitoring()
                }
            }
            
            if newConfig.power != UserDefaults.standard.bool(forKey: "security.power") {
                UserDefaults.standard.set(newConfig.power, forKey: "security.power")
                if newConfig.power {
                    await monitor.startPowerMonitoring()
                } else {
                    await monitor.stopPowerMonitoring()
                }
            }
            
            if newConfig.headphones != UserDefaults.standard.bool(forKey: "security.headphones") {
                UserDefaults.standard.set(newConfig.headphones, forKey: "security.headphones")
                if newConfig.headphones {
                    await monitor.startHeadphonesMonitoring()
                } else {
                    await monitor.stopHeadphonesMonitoring()
                }
            }
        }
    )
}
