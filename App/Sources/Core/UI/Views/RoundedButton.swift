//
//  RoundedButton.swift
//  MagicSecurity
//
//  Created by User on 17.04.25.
//

import SwiftUI

public struct RoundedButton: View {
    
    public let buttonText: String
    public let action: () -> Void
    
    public init(buttonText: String, action: @escaping () -> Void) {
        self.buttonText = buttonText
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            action()
        }) {
            Text(buttonText)
                .fontSystem(iPhoneSize: 17, iPadSize: 24, weight: .bold, weightForiPad: .regular)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 62)
                .background(.designSystem(.primary))
                .cornerRadius(14)
        }
        .padding(.horizontal, 24)
    }
}
