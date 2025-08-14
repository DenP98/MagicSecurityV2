//
//  Testkey.swift
//  MagicSecurity
//
//  Created by User on 11.04.25.
//

import Dependencies
import Foundation

extension UserDefaultsClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension UserDefaultsClient {
    public static let noop = Self(
        boolForKey: { _ in false },
        dataForKey: { _ in nil },
        doubleForKey: { _ in 0 },
        integerForKey: { _ in 0 },
        stringForKey: { _ in nil },
        remove: { _ in },
        setBool: { _, _ in },
        setData: { _, _ in },
        setDouble: { _, _ in },
        setInteger: { _, _ in },
        setString: { _, _ in }
    )
    
    public mutating func override(bool: Bool, forKey key: String) {
        self.boolForKey = { [self] in $0.rawValue == key ? bool : self.boolForKey($0) }
    }
    
    public mutating func override(data: Data, forKey key: String) {
        self.dataForKey = { [self] in $0.rawValue == key ? data : self.dataForKey($0) }
    }
    
    public mutating func override(double: Double, forKey key: String) {
        self.doubleForKey = { [self] in $0.rawValue == key ? double : self.doubleForKey($0) }
    }
    
    public mutating func override(integer: Int, forKey key: String) {
        self.integerForKey = { [self] in $0.rawValue == key ? integer : self.integerForKey($0) }
    }
    
    public mutating func override(string: String, forKey key: String) {
        self.stringForKey = { [self] in $0.rawValue == key ? string : self.stringForKey($0) }
    }
}
