//
//  UIDevice + Ext.swift
//  MagicSecurity
//
//  Created by Artem Golikov on 15.08.2025.
//

import UIKit

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

extension UIDevice {
    static var isPad: Bool {
        return self.current.userInterfaceIdiom == .pad
    }
    
    static var isSE: Bool {
        return self.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 736.0
    }
    
    static var isProMax: Bool {
        return self.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH >= 910.0
    }
    
    static var is11orXS: Bool {
        return self.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 896.0
    }
}
