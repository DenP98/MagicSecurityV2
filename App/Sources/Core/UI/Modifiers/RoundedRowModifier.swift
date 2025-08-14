//
//  RoundedRowModifier.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//

import SwiftUI

public struct RoundedRowModifier: ViewModifier {
    let isSelected: Bool
    
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .designSystem(.selectedRowBackground) : .white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .designSystem(.primary) : .clear, lineWidth: isSelected ? 2 : 1)
            )
    }
}

public extension View {
    func roundedSelectable(isSelected: Bool = false) -> some View {
        self.modifier(RoundedRowModifier(isSelected: isSelected))
    }
}
