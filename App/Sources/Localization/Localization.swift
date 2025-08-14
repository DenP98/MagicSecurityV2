//
//  Localization.swift
//  MagicSecurity
//
//  Created by User on 16.04.25.
//

import Foundation

public extension String {
    var localized: String {
        NSLocalizedString(self, tableName: nil, bundle: .main, comment: "")
    }
    
    var attributedString: AttributedString {
        AttributedString(localized: LocalizationValue(self),
                         bundle: .main)
    }
}
