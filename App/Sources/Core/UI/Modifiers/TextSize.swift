//
//  TextSize.swift
//  MagicSecurity
//
//  Created by User on 4.06.25.
//

import SwiftUI

public extension View {
    @MainActor
    func fontSystem(
        iPhoneSize: CGFloat,
        iPadSize: CGFloat,
        weight: Font.Weight = .regular,
        weightForiPad: Font.Weight? = nil
    ) -> some View {
        self.font(.system(
            size: UIDevice.current.userInterfaceIdiom == .pad ? iPadSize : iPhoneSize,
            weight: UIDevice.current.userInterfaceIdiom == .pad ? weightForiPad ?? weight : weight
        ))
    }
}
