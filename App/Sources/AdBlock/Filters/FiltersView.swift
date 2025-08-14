//
//  FiltersView.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//
import ComposableArchitecture
import SwiftUI


public struct FiltersView: View {
    @Perception.Bindable var store: StoreOf<Filters>
    
    public init(store: StoreOf<Filters>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            List {
                HStack {
                    Spacer(minLength: 60)
                    Image("Filters/stop_sign")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 350)
                    Spacer(minLength: 60)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                HStack {
                    Spacer()
                    VStack {
                        ForEach(store.filters) { filter in
                            HStack(spacing: 16) {
                                Image(filter.iconName)
                                    .foregroundStyle(.blue)
                                    .frame(width: 30, height: 30)
                                
                                Text(filter.title.localized)
                                    .fontSystem(iPhoneSize: 17, iPadSize: 20)
                                    .foregroundStyle(.designSystem(.textSecondary))
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { filter.isEnabled },
                                    set: { _ in store.send(.toggleFilter(filter.id)) }
                                ))
                                .toggleStyle(CrownToggleStyle())
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.designSystem(.buttonText))
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24))
                            .frame(maxWidth: 450)
                        }
                    }
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .background(.designSystem(.background))
            .navigationTitle("filters".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(
            item: $store.scope(state: \.destination?.paywall,
                               action: \.destination.paywall)
        ) { store in
            PaywallView(store: store)
        }
    }
}

#Preview {
    NavigationView {
        FiltersView(
            store: Store(
                initialState: Filters.State()
            ) {
                Filters()
            }
        )
    }
}
