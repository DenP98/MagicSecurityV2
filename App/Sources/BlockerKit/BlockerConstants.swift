//
//  BlockerConstants.swift
//  MagicSecurity
//
//  Created by User on 24.04.25.
//

import Foundation

public enum BlockerConstants {
    #warning("Make sure to update the app group identifier to match your app's group identifier.")
    public static let appGroupIdentifier = ""
    public static let blockerExtensionIdentifier = ""
    public static let filterOptionsKey = "enabledFilters"
    public static let blackListOptionsKey = "blackListDomains"
    public static let whiteListOptionsKey = "whiteListDomains"
    
    public static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: Self.appGroupIdentifier)
    }
}
