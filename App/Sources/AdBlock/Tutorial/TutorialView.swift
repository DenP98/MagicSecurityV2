//
//  TutorialView.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//

import SwiftUI
import ComposableArchitecture

/*
 TODO:
 Add gif
 */

public struct TutorialView: View {
    let store: StoreOf<Tutorial>
    
    public init(store: StoreOf<Tutorial>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 42) {
            VStack(alignment: .leading) {
                HStack {
                    TutorialStepView(
                        text: "open_settings_app".localized,
                        isSelected: false
                    )
                    
                    TutorialStepView(
                        text: "tap_safari".localized,
                        isSelected: false
                    )
                }
                
                HStack {
                    TutorialStepView(
                        text: "select_extensions".localized,
                        isSelected: false,
                    )
                    
                    TutorialStepView(
                        text: "app_name".localized,
                        isSelected: true,
                    )
                }
            }
            .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                
                // Here we'll add GIF later
                Image(systemName: "play.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 30))
            }
            .padding(.horizontal, 24)
            
            RoundedButton(buttonText: "open_settings".localized) {
                store.send(.openSettingsTapped)
            }
            
            Spacer()
        }
        .padding(.top)
        .navigationTitle("tutorial".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("skip".localized.localizedUppercase) {
                    store.send(.skipTapped)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TutorialView(
            store: Store(
                initialState: Tutorial.State()
            ) {
                Tutorial()
            }
        )
    }
}
