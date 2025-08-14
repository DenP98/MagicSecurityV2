//
//  LiveKey.swift
//  MagicSecurity
//
//  Created by User on 11.04.25.
//

import Dependencies
import Foundation

extension UserDefaultsClient: DependencyKey {
    #warning("Consider using a more specific suite name for production use.")
    public static let liveValue: Self = {
        let defaults: @Sendable () -> UserDefaults = { UserDefaults(suiteName: "")! }
        return Self(
            boolForKey: { defaults().bool(forKey: $0.rawValue) },
            dataForKey: { defaults().data(forKey: $0.rawValue) },
            doubleForKey: { defaults().double(forKey: $0.rawValue) },
            integerForKey: { defaults().integer(forKey: $0.rawValue) },
            stringForKey: { defaults().string(forKey: $0.rawValue) },
            remove: { defaults().removeObject(forKey: $0.rawValue) },
            setBool: { defaults().set($0, forKey: $1.rawValue) },
            setData: { defaults().set($0, forKey: $1.rawValue) },
            setDouble: { defaults().set($0, forKey: $1.rawValue) },
            setInteger: { defaults().set($0, forKey: $1.rawValue) },
            setString: { defaults().set($0, forKey: $1.rawValue) }
        )
    }()
}
