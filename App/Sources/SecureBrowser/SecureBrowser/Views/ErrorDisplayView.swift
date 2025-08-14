//
//  ErrorDisplayView.swift
//  MagicSecurity
//
//  Created by User on 23.05.25.
//

import SwiftUI

struct ErrorDisplayView: View {
    let errorMessage: String
    
    var body: some View {
        VStack {
            Text("Error Loading Page")
                .font(.headline)
            Text(errorMessage)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.black.opacity(0.75))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}
