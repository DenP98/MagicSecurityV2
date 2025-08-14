//
//  AlarmRowView.swift
//  MagicSecurity
//
//  Created by User on 29.04.25.
//

import SwiftUI

struct AlarmRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    let isOn: Binding<Bool>
    
    var body: some View {
        HStack {
            Image(icon)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.designSystem(.textSecondary))
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.designSystem(.textDescription))
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.designSystem(.primary))
        }
        .padding([.top, .bottom], 12)
        .padding([.leading, .trailing], 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
        .cornerRadius(12)
    }
}
