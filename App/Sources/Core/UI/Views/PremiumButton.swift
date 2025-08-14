//
//  PremiumButton.swift
//  MagicSecurity
//
//  Created by User on 30.04.25.
//

import SwiftUI
import ComposableArchitecture

public struct PremiumButton: View {
    let isCompact: Bool
    let action: () -> Void
    
    public init(isCompact: Bool = false, action: @escaping () -> Void) {
        self.isCompact = isCompact
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                if isCompact {
                    Image("crown_premium")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .padding(.leading, 1)
                } else {
                    Image("crown_premium")
                        .frame(width: 44, height: 44)
                }

                Text(isCompact ? "premium".localized : "premium".localizedUppercase.localized)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.designSystem(.buttonText))
                
                Spacer()
                
                Image("chevron")
                    .foregroundColor(.gray)
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 20)
        .padding([.top, .bottom], isCompact ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(colors: [.designSystem(.buttonGradientLeft), .designSystem(.buttonGradientRight)], startPoint: .leading, endPoint: .trailing))
        )
        .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
