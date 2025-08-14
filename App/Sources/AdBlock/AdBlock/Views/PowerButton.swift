//
//  PowerButton.swift
//  MagicSecurity
//
//  Created by User on 16.04.25.
//

import ComposableArchitecture
import SwiftUI

public struct PowerButton: View {
    var protectionEnabled: Bool
    var action: () -> Void
    
    public var body: some View {
        ZStack {
            Capsule()
                .fill(.designSystem(.buttonBackground))
                .frame(width: 176, height: 94)
                .overlay {
                    Capsule()
                        .stroke(.designSystem(.buttonBorder), lineWidth: 2)
                }
            
            Image("AdBlock/chevrons")
                .offset(x: 40)
                .rotationEffect(.degrees(protectionEnabled ? -180 : 0))
            
            Circle()
                .fill(protectionEnabled ? .designSystem(.greenPrimary) :
                        .designSystem(.buttonText))
                .frame(width: 84, height: 84)
                .overlay {
                    Image(systemName: "power")
                        .font(.system(size: 35, weight: .medium))
                        .foregroundColor(protectionEnabled ? .designSystem(.buttonText) :
                                .designSystem(.attentionPrimary))
                }
                .offset(x: protectionEnabled ? 40 : -40)
                .animation(.spring(duration: 0.3), value: protectionEnabled)
        }
        .onTapGesture {
            action()
        }
    }
}
