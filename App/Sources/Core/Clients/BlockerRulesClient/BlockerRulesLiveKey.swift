//
//  BlockerRulesLiveKey.swift
//  MagicSecurity
//
//  Created by User on 22.04.25.
//

import Foundation
import Dependencies
import SafariServices

extension BlockerRulesClient: DependencyKey {
    
    public static let liveValue = Self(
        updateRules: { filters in
            guard let sharedDefaults = UserDefaults(suiteName: BlockerConstants.appGroupIdentifier) else {
                return
            }
            sharedDefaults.set(filters.rawValue, forKey: BlockerConstants.filterOptionsKey)
            try? await SFContentBlockerManager.reloadContentBlocker(withIdentifier: BlockerConstants.blockerExtensionIdentifier)
        },
        getCurrentFilters: {
            guard let sharedDefaults = UserDefaults(suiteName: BlockerConstants.appGroupIdentifier) else {
                return []
            }
            let raw = sharedDefaults.integer(forKey: BlockerConstants.filterOptionsKey)
            let options = FilterOptions(rawValue: raw)
            return options
        },
        loadBlackList: {
            guard let sharedDefaults = UserDefaults(suiteName: BlockerConstants.appGroupIdentifier) else {
                return []
            }
            let urlStrings = sharedDefaults.array(forKey: BlockerConstants.blackListOptionsKey) as? [String] ?? []
            return urlStrings.compactMap { URL(string: $0) }
        },
        updateBlackList: { urls in
            guard let sharedDefaults = UserDefaults(suiteName: BlockerConstants.appGroupIdentifier) else {
                return
            }
            let urlStrings = urls.map { $0.absoluteString }
            sharedDefaults.set(urlStrings, forKey: BlockerConstants.blackListOptionsKey)
            try? await SFContentBlockerManager.reloadContentBlocker(withIdentifier: BlockerConstants.blockerExtensionIdentifier)
        },
        loadWhiteList: {
            guard let sharedDefaults = UserDefaults(suiteName: BlockerConstants.appGroupIdentifier) else {
                return []
            }
            let urlStrings = sharedDefaults.array(forKey: BlockerConstants.whiteListOptionsKey) as? [String] ?? []
            return urlStrings.compactMap { URL(string: $0) }
        },
        updateWhiteList: { urls in
            guard let sharedDefaults = UserDefaults(suiteName: BlockerConstants.appGroupIdentifier) else {
                return
            }
            let urlStrings = urls.map { $0.absoluteString }
            sharedDefaults.set(urlStrings, forKey: BlockerConstants.whiteListOptionsKey)
            try? await SFContentBlockerManager.reloadContentBlocker(withIdentifier: BlockerConstants.blockerExtensionIdentifier)
        }
    )
}
