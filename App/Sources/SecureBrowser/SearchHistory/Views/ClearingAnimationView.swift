//
//  ClearingAnimationView.swift
//  MagicSecurity
//
//  Created by User on 24.05.25.
//

import SwiftUI

struct ClearingAnimationView: View {
    let progress: Double
    let homeButtonTapped: () -> Void
    
    var isCompleted: Bool {
        progress >= 100
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if isCompleted {
                Spacer(minLength: 270)
                
                Image("SearchHistory/clearing_finished")
                
                HStack(alignment: .lastTextBaseline) {
                    Image("SearchHistory/checkmark")
                    
                    Text("search_history_cleared".localized)
                        .font(.system(size: 17, weight: .bold))
                        .padding(.top, 10)
                }
                
                Spacer()
                
                RoundedButton(buttonText: "home".localized) {
                    homeButtonTapped()
                }
                .padding(.bottom, 140)
                .frame(maxWidth: 400)
                
            } else {
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(.designSystem(.buttonBackground), lineWidth: 15)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress / 100)
                        .stroke(.designSystem(.primary),
                                style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                    
                    Image("SearchHistory/clearing")
                }
                .padding(.bottom, 40)
                
                VStack(spacing: 4) {
                    Text("\(Int(progress))%")
                        .foregroundStyle(.designSystem(.primary))
                        .font(.system(size: 34, weight: .bold))
                    
                    Text("delete_search_history".localized)
                        .font(.system(size: 17, weight: .bold))
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(.designSystem(.background))
    }
}
