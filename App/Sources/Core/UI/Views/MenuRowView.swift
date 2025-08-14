//
//  MenuRowView.swift
//  MagicSecurity
//
//  Created by User on 28.04.25.
//

import SwiftUI

public struct MenuRowView: View {
    let title: String
    let subtitle: String?
    let image: Image
    let isCompact: Bool
    let action: (() -> Void)?
    
    public init(title: String, subtitle: String? = nil, image: Image, isCompact: Bool = false, action: (() -> Void)?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.isCompact = isCompact
        self.action = action
    }
    
    public var body: some View {
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
                            if let subtitle {
                                Text(subtitle)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.designSystem(.textDescription))
                            }
                        }
                    },
                    icon: {
                        image
                            .frame(width: 40, height: 40)
                    }
                )
                
                Spacer()
                
                Image("gray_chevron")
                    .frame(width: 7, height: 14)
            }
        }
        .padding([.top, .bottom], isCompact ? 8 : 14)
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
