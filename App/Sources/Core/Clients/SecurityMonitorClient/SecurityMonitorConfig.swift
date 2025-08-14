//
//  SecurityMonitorConfig.swift
//  MagicSecurity
//
//  Created by User on 29.04.25.
//

public struct SecurityMonitorConfig: Equatable, Sendable {
    public var movement: Bool
    public var power: Bool
    public var headphones: Bool
    
    public init(
        movement: Bool = false,
        power: Bool = false,
        headphones: Bool = false
    ) {
        self.movement = movement
        self.power = power
        self.headphones = headphones
    }
}
