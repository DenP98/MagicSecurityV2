//
//  CrownToggleStyle.swift
//  MagicSecurity
//
//  Created by User on 17.04.25.
//

import SwiftUI

public struct CrownToggleStyle: ToggleStyle {
    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? .designSystem(.primary) :
                        .designSystem(.buttonBorder))
                .frame(width: 50, height: 31)
            
            Image("Filters/crown_toggle")
                .foregroundStyle(.white)
                .frame(width: 27, height: 27)
                .background(
                    Circle()
                        .fill(.designSystem(.buttonText))
                        .shadow(
                            color: .black.opacity(0.15),
                            radius: 8,
                            x: 0,
                            y: 3
                        )
                )
                .offset(x: configuration.isOn ? 10 : -10)
                .animation(.spring(duration: 0.2), value: configuration.isOn)
        }
        .onTapGesture {
            withAnimation {
                configuration.isOn.toggle()
            }
        }
    }
}
