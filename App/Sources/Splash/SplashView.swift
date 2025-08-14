//
//  SplashView.swift
//  MagicSecurity
//
//  Created by User on 7.04.25.
//

import SwiftUI
import ComposableArchitecture

public struct SplashView: View {
    let store: StoreOf<Splash>
    
    public init(store: StoreOf<Splash>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 30) {
                Spacer(minLength: 100)
                
                Image("app_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300)
                    .padding(.horizontal, 90)
                Text("app_name".localized)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.designSystem(.primary))
                
                Spacer(minLength: 100)
                
                VStack(spacing: 8) {
                    Text("\(Int(store.progress))%")
                        .font(.subheadline)
                        .bold()
                    ProgressView(value: store.progress, total: 100)
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(.designSystem(.primary))
                        .padding(.horizontal, 88)
                }
                .frame(maxWidth: 450)
                
                Spacer()
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

#Preview {
    SplashView(
        store: Store(
            initialState: Splash.State()
        ) {
            Splash()
        }
    )
}
