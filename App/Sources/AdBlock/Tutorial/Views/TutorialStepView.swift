//
//  TutorialStepView.swift
//  MagicSecurity
//
//  Created by User on 17.04.25.
//

import SwiftUI

struct TutorialStepView: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 2) {
            if isSelected {
                Text(text)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.designSystem(.primary))
            } else {
                Text(text)
                    .font(.system(size: 15, weight: .regular))
            }
            
            if !isSelected {
                Image("Tutorial/chevron")
                    .frame(width: 17, height: 20)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? .designSystem(.backgroundPrimary) : .designSystem(.labelBackground))
        )
    }
}
