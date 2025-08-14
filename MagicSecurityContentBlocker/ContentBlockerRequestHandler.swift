//
//  ContentBlockerRequestHandler.swift
//  MagicSecurityContentBlocker
//
//  Created by User on 16.04.25.
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        guard let sharedDefaults = BlockerConstants.userDefaults else {
            defaultFallback(with: context)
            return
        }
        
        let raw = sharedDefaults.integer(forKey: BlockerConstants.filterOptionsKey)
        let filter = FilterOptions(rawValue: raw)
        
        let blackList = (sharedDefaults.array(forKey: BlockerConstants.blackListOptionsKey) as? [String] ?? [])
            .compactMap { URL(string: $0) }
        let whiteList = (sharedDefaults.array(forKey: BlockerConstants.whiteListOptionsKey) as? [String] ?? [])
            .compactMap { URL(string: $0) }
        
        let rules = BlockerRulesMapper.getRules(filter: filter, blackList: blackList, whiteList: whiteList)
        
        guard let jsonData = try? JSONEncoder().encode(rules),
              let jsonString = String(data: jsonData, encoding: .utf8),
              let tempURL = try? FileManager.default
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("blockerList.json") else {
            defaultFallback(with: context)
            return
        }
        
        try? jsonString.write(to: tempURL, atomically: true, encoding: .utf8)
        let attachment = NSItemProvider(contentsOf: tempURL)!
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
    func defaultFallback(with context: NSExtensionContext) {
        let attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "blockerList", withExtension: "json"))!
        let item = NSExtensionItem()
        item.attachments = [attachment]
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
}
