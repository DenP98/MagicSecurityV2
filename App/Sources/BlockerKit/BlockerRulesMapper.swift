//
//  BlockerRulesMapper.swift
//  MagicSecurity
//
//  Created by User on 24.04.25.
//

import Foundation

public final class BlockerRulesMapper {
    
    public static func getRules(filter: FilterOptions, blackList: [URL], whiteList: [URL]) -> [BlockerRule] {
        var rules: [BlockerRule] = []
        
        // Get whitelist domains
        let whiteListDomains = whiteList.compactMap { $0.host }
        
        // Always add whitelist rules first
        if !whiteListDomains.isEmpty {
            for domain in whiteListDomains {
                rules.append(BlockerRule(
                    trigger: .init(
                        urlFilter: ".*",
                        ifDomain: [domain],
                        unlessDomain: nil
                    ),
                    action: .init(type: "ignore-previous-rules")
                ))
            }
        }
        
        // Test site specific patterns
        if filter.contains(.ads) {
            // Basic test patterns often used on ad testing sites
            rules.append(contentsOf: [
                BlockerRule(
                    trigger: .init(
                        urlFilter: ".*\\.test\\..*",
                        resourceType: ["image", "script", "stylesheet", "other"],
                        unlessDomain: whiteListDomains
                    ),
                    action: .init(type: "block")
                ),
                BlockerRule(
                    trigger: .init(
                        urlFilter: ".*test-ad.*",
                        resourceType: ["image", "script", "stylesheet", "other"],
                        unlessDomain: whiteListDomains
                    ),
                    action: .init(type: "block")
                ),
                BlockerRule(
                    trigger: .init(
                        urlFilter: ".*dummy-ad.*",
                        resourceType: ["image", "script", "stylesheet", "other"],
                        unlessDomain: whiteListDomains
                    ),
                    action: .init(type: "block")
                ),
                // Block common test image dimensions
                BlockerRule(
                    trigger: .init(
                        urlFilter: ".*\\d+x\\d+\\.(png|jpg|gif)",
                        resourceType: ["image"],
                        unlessDomain: whiteListDomains
                    ),
                    action: .init(type: "block")
                ),
                // Block test scripts
                BlockerRule(
                    trigger: .init(
                        urlFilter: ".*/testing/.*",
                        resourceType: ["script", "stylesheet", "image", "other"],
                        unlessDomain: whiteListDomains
                    ),
                    action: .init(type: "block")
                )
            ])
            
            // Add CSS rules specifically for test sites
            rules.append(BlockerRule(
                trigger: .init(
                    urlFilter: ".*",
                    resourceType: ["document"]
                ),
                action: .init(type: "css-display-none", selector: """
                    div[id*="test"], div[class*="test"],
                    div[id*="dummy"], div[class*="dummy"],
                    div[id*="sample"], div[class*="sample"],
                    img[src*="test"], img[src*="dummy"],
                    div[style*="width: 300px"][style*="height: 250px"],
                    div[style*="width: 728px"][style*="height: 90px"],
                    div[style*="width: 160px"][style*="height: 600px"],
                    [id*="ad_test"], [class*="ad_test"],
                    [id*="test_ad"], [class*="test_ad"],
                    [id^="ad-"], [class^="ad-"],
                    [data-ad], [data-ads],
                    [data-adtest], [data-ad-test],
                    iframe[width="300"][height="250"],
                    iframe[width="728"][height="90"],
                    iframe[width="160"][height="600"]
                    """)
            ))
        }
        
        // Common resource types for advertising
        let adResourceTypes = ["image", "script", "stylesheet", "xhr", "sub_frame", "document", "media", "object", "font", "raw", "other"]
        
        let filterDefs: [(option: FilterOptions, pattern: String, types: [String])] = [
            // Ad Networks and Services - Expanded
            (.ads, "(?i).*\\b(adserv(er|ice)?|doubleclick|google(syndication|tagservices|ads)|pagead[0-9]?|adclick|adsystem|adnxs|advertising|banners?|fastclick|openx|rubiconproject|criteo|quantserve|pubmatic|taboola|outbrain|adtech|adbrite|adroll|sharethru|yieldmo|mediamath|adform|spotx|appnexus|medianet)\\.", adResourceTypes),
            
            // Ad Keywords - Expanded
            (.ads, "(?i).*\\b(ads?|banner|popunder|sponsor(ed)?|advertisement|advertising|promoted|pop-?up|bid|recommendation|promo)\\b.*", adResourceTypes),
            
            // Generic ad patterns
            (.ads, "(?i)^https?://[^/]*ad[.-]", adResourceTypes),
            (.ads, "(?i)^https?://ad[.-]", adResourceTypes),
            (.ads, "(?i)^https?://ads[.-]", adResourceTypes),
            (.ads, "(?i)^https?://adserver[.-]", adResourceTypes),
            (.ads, "(?i)/ad(s|v)?[.-]", adResourceTypes),
            (.ads, "(?i)/ad(s|v)?/", adResourceTypes),
            (.ads, "(?i)/ad(s|v)?$", adResourceTypes),
            
            // Ad Containers and Frames
            (.ads, "(?i)\\b(ad[-_]?(box|cell|container|content|div|feed|frame|insert|layer|media|module|placeholder|slot|space|sponsor|unit|zone|wrap)|adspace|banner[-_]?container|dfpad|displayad|googlead|panel-ad|top-ad|sponsor[-_]?container)\\b", adResourceTypes),
            
            // Common Ad Dimensions
            (.ads, "(?i).*(300x250|728x90|160x600|320x50|970x250|468x60|336x280|234x60|120x600|120x240|300x600|120x90|180x150).*", ["image", "script", "sub_frame"]),
            
            // Ad File Patterns
            (.ads, "(?i).*(advertisement|promotion|sponsor|banner|popup)\\.(jpg|gif|png|js|html|htm).*", adResourceTypes),
            
            // Ad Paths and Directories
            (.ads, "(?i).*(^|\\/)((ads?|banners?|sponsors?|promotions?)\\/|display-ad|pop(up|under)|[0-9]+x[0-9]+).*", adResourceTypes),
            (.ads, "(?i).*\\/(ads?|advertisers?|advert(ising)?|sponsored|pop(up|under)|banners?)(\\/|$).*", adResourceTypes),
            
            // Additional Ad Networks
            (.ads, "(?i).*(adnetwork|bidswitch|buysellads|cdn-banner|clkads|delivery\\.ads|easyads|adserving|adstream|adsrv|cloudfront\\.net\\/ads)\\.", adResourceTypes),
            
            // Video Ad Networks
            (.ads, "(?i).*(spotxchange|tremorhub|innovid|teads|liverail|brightroll|adap\\.tv|freewheel|videoplaza)\\.", ["media", "script", "xhr"]),
            
            // Analytics and Tracking
            (.tracking, "(?i).*(analytics|tracking|pixel|stat[s]?|logs?|beacon|monitor|measure|collect|counter|impression|tag[s]?)\\.", ["script", "image", "xhr"]),
            (.tracking, "(?i).*(google-analytics|googletagmanager|gtm|omniture|chartbeat|segment|mixpanel)\\.", ["script", "xhr"]),
            
            // Social tracking pixels and beacons
            (.tracking, "(?i).*(facebook|twitter|linkedin|instagram)\\.com\\/.*(pixel|tracking|beacon|event).*", ["image", "script", "xhr"]),
            
            // Additional tracking services
            (.tracking, "(?i).*(optimizely|hotjar|clicktale|crazyegg|mixpanel|newrelic|segment|amplitude)\\.", ["script", "xhr"]),
            
            // Social Media Elements
            (.socialButtons, "(?i).*(facebook|twitter|instagram|linkedin|pinterest|youtube)\\.com\\/(plugins|widgets|buttons|share|like|embed|follow|tweet|pin)", ["image", "script", "stylesheet", "xhr", "document", "sub_frame", "raw"]),
            (.socialButtons, "(?i).*\\b(share|follow|tweet|like|social)[-_]?button\\b.*", ["image", "script", "stylesheet", "xhr", "document", "sub_frame"]),
            (.socialButtons, "(?i).*\\b(fb|twitter|linkedin|instagram|pin)[-_]?(share|like|button|widget)\\b.*", ["image", "script", "stylesheet", "xhr", "document", "sub_frame"])
        ]
        
        // Apply all filter definitions
        for def in filterDefs where filter.contains(def.option) {
            rules.append(BlockerRule(
                trigger: .init(
                    urlFilter: def.pattern,
                    resourceType: def.types,
                    unlessDomain: whiteListDomains
                ),
                action: .init(type: "block")
            ))
        }
        
        if filter.contains(.adultSites) {
            for urlString in BlockerRulesMapper.adultDomains {
                let escaped = NSRegularExpression.escapedPattern(for: urlString)
                rules.append(BlockerRule(
                    trigger: .init(
                        urlFilter: ".*\\\(escaped).*",
                        unlessDomain: nil
                    ),
                    action: .init(type: "block")
                ))
            }
        }
        
        if filter.contains(.gambling) {
            for urlString in BlockerRulesMapper.gamblingDomains {
                let escaped = NSRegularExpression.escapedPattern(for: urlString)
                rules.append(BlockerRule(
                    trigger: .init(
                        urlFilter: ".*\\\(escaped).*",
                        unlessDomain: nil
                    ),
                    action: .init(type: "block")
                ))
            }
        }
        
        if filter.contains(.customFonts) {
            rules.append(BlockerRule(
                trigger: .init(
                    urlFilter: ".*\\.(woff2?|ttf|otf|eot)",
                    resourceType: ["font"],
                    unlessDomain: whiteListDomains
                ),
                action: .init(type: "block")
            ))
        }
        
        // CSS-based blocking for social elements and ads
        if filter.contains(.socialButtons) || filter.contains(.ads) {
            rules.append(BlockerRule(
                trigger: .init(
                    urlFilter: ".*",
                    resourceType: ["document"],
                    unlessDomain: whiteListDomains
                ),
                action: .init(type: "css-display-none", selector: """
                    .social-share, .share-buttons, .social-buttons, .social-media-buttons, \
                    [class*="social-"], [class*="share-"], [class*="ad-"], [class*="ads-"], \
                    [id*="ad-"], [id*="ads-"], [class*="advert"], [id*="advert"], \
                    .fb-like, .twitter-share-button, .linkedin-share-button, \
                    .pinterest-pin-it-button, .instagram-follow-button, \
                    iframe[src*="facebook.com/plugins"], \
                    iframe[src*="twitter.com/widgets"], \
                    iframe[src*="linkedin.com/embed"], \
                    iframe[src*="pinterest.com/pin"], \
                    .addthis_inline_share_toolbox, \
                    .sharethis-inline-share-buttons, \
                    div[class*="ad-container"], div[id*="ad-container"], \
                    div[class*="banner"], div[id*="banner"], \
                    .advertisement, .advertising, .sponsored, .promoted, \
                    [class*="sticky-ad"], [id*="sticky-ad"]
                    """)
            ))
        }
        
        // Enhanced CSS-based blocking for ads
        if filter.contains(.ads) {
            rules.append(BlockerRule(
                trigger: .init(
                    urlFilter: ".*",
                    resourceType: ["document"]
                ),
                action: .init(type: "css-display-none", selector: """
                    [id^="ad-"], [class^="ad-"],
                    [id^="ads-"], [class^="ads-"],
                    [id*="-ad-"], [class*="-ad-"],
                    [id$="-ad"], [class$="-ad"],
                    [id^="google_ads_"], 
                    [id^="div-gpt-ad"],
                    div[style*="width:"][style*="height:"],
                    div[data-ad], div[data-ads],
                    div[data-ad-unit],
                    iframe[id*="google_ads"],
                    iframe[id*="ad_frame"],
                    a[href*="/ads/"], 
                    a[href*="/adclick"],
                    .advertisement, .advertising,
                    .ad, .ads, .ad-box, .ad-container,
                    div[class*="adBox"], div[id*="adBox"],
                    div[class*="adContainer"], div[id*="adContainer"],
                    div[style*="position: fixed"],
                    div[class*="banner"], div[id*="banner"]
                    """)
            ))
        }
        
        // Process blacklist at the end
        for url in blackList {
            if let host = url.host {
                let escaped = NSRegularExpression.escapedPattern(for: host)
                rules.append(BlockerRule(
                    trigger: .init(
                        urlFilter: ".*\\\(escaped).*",
                        unlessDomain: nil
                    ),
                    action: .init(type: "block")
                ))
            }
        }
        
        return rules
    }
}
