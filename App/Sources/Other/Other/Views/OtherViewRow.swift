//
//  OtherViewRow.swift
//  MagicSecurity
//
//  Created by User on 28.04.25.
//

import SwiftUI

struct OtherViewRow: View {
    let title: String
    let subtitle: String
    let image: Image
    let action: (() -> Void)?
    
    var body: some View {
        Button {
            action?()
        } label: {
            HStack {
                Label(
                    title: {
                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.designSystem(.textSecondary))
                            Text(subtitle)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.designSystem(.textDescription))
                        }
                    },
                    icon: {
                        image
                            .frame(width: 40, height: 40)
                    }
                )
                
                Spacer()
                
                Image("Other/gray_chevron")
                    .frame(width: 7, height: 14)
            }
        }
        .padding([.top, .bottom], 14)
        .padding([.leading, .trailing], 20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
    }
}
