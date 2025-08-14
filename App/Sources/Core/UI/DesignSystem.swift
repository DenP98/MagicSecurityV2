//
//  Untitled.swift
//  MagicSecurity
//
//  Created by User on 13.04.25.
//

import SwiftUI

public struct DesignSystem {
    public enum Colors {
        case background
        
        case primary
        case backgroundPrimary
        case textPrimary
        case textSecondary
        case textDescription
        case buttonText
        case greenPrimary
        case greenSecondary
        case attentionPrimary
        case attentionSecondary
        case buttonBackground
        case buttonBorder
        case labelBackground
        case buttonGradientLeft
        case buttonGradientRight
        case chevron
        case selectedRowBackground
        
        var color: Color {
            switch self {
            case .background:
                Color(red: 243 / 255, green: 244 / 255, blue: 246 / 255)
            case .primary:
                Color(red: 9 / 255, green: 144 / 255, blue: 212 / 255)
            case .backgroundPrimary:
                Color(red: 9 / 255, green: 144 / 255, blue: 212 / 255, opacity: 0.1)
            case .textPrimary:
                Color(red: 6 / 255, green: 10 / 255, blue: 26 / 255)
            case .textSecondary:
                Color(red: 10 / 255, green: 16 / 255, blue: 40 / 255)
            case .textDescription:
                Color(red: 127 / 255, green: 128 / 255, blue: 136 / 255)
            case .buttonText:
                Color.white
            case .greenPrimary:
                Color(red: 17 / 255, green: 184 / 255, blue: 64 / 255)
            case .greenSecondary:
                Color(red: 17 / 255, green: 184 / 255, blue: 64 / 255, opacity: 0.12)
            case .attentionPrimary:
                Color(red: 222 / 255, green: 56 / 255, blue: 106 / 255)
            case .attentionSecondary:
                Color(red: 222 / 255, green: 56 / 255, blue: 106 / 255, opacity: 0.12)
            case .buttonBackground:
                Color(red: 228 / 255, green: 231 / 255, blue: 239 / 255)
            case .buttonBorder:
                Color(red: 193 / 255, green: 201 / 255, blue: 212 / 255)
            case .labelBackground:
                Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255)
            case .buttonGradientLeft:
                Color(red: 222 / 255, green: 8 / 255, blue: 255 / 255)
            case .buttonGradientRight:
                Color(red: 38 / 255, green: 138 / 255, blue: 255 / 255)
            case .chevron:
                Color(red: 198 / 255, green: 198 / 255, blue: 222 / 255)
            case .selectedRowBackground:
                Color(red: 231 / 255, green: 244 / 255, blue: 251 / 255)
            }
        }
    }
}

public extension ShapeStyle where Self == Color {
    static func designSystem(_ color: DesignSystem.Colors) -> Color {
        color.color
    }
}
