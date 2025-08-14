//
//  CustomizationBlockView.swift
//  MagicSecurity
//
//  Created by User on 16.04.25.
//

import SwiftUI

struct CustomizationBlockView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 14) {
                Image("AdBlock/filters")
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Customization")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.designSystem(.textSecondary))
                    
                    Text("Customize Adblock filters to suit your needs")
                        .font(.system(size: 15))
                        .foregroundStyle(.designSystem(.textDescription))
                }
                
                Spacer()
                
                Image("AdBlock/big_chevron")
                    .frame(width: 24, height: 24)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.designSystem(.buttonText))
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 25)
    }
}
