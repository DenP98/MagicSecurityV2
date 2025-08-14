//
//  BlockerRule.swift
//  MagicSecurity
//
//  Created by User on 22.04.25.
//

public struct BlockerRule: Codable, Sendable {
    public let trigger: Trigger
    public let action: Action
    
    public struct Trigger: Codable, Sendable {
        let urlFilter: String
        let ifDomain: [String]?
        let resourceType: [String]?
        let unlessDomain: [String]?
        
        enum CodingKeys: String, CodingKey {
            case urlFilter = "url-filter"
            case ifDomain = "if-domain"
            case resourceType = "resource-type"
            case unlessDomain = "unless-domain"
        }
        
        init(urlFilter: String, ifDomain: [String]? = nil, resourceType: [String]? = nil, unlessDomain: [String]? = nil) {
            self.urlFilter = urlFilter
            self.ifDomain = ifDomain
            self.resourceType = resourceType
            self.unlessDomain = unlessDomain
        }
    }
    
    public struct Action: Codable, Sendable {
        let type: String
        let selector: String?
        
        init(type: String, selector: String? = nil) {
            self.type = type
            self.selector = selector
        }
    }
}
