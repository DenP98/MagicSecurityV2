//
//  AlarmsView.swift
//  MagicSecurity
//
//  Created by User on 25.04.25.
//

import SwiftUI
import ComposableArchitecture

public struct AlarmsView: View {
    var store: StoreOf<Alarms>
    
    public init(store: StoreOf<Alarms>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color
                    .designSystem(.background)
                    .ignoresSafeArea()
                
                List {
                    AlarmRowView(
                        icon: "Alarms/movement",
                        title: "movement".localized,
                        subtitle: "activate_the_serenader_movement".localized,
                        isOn: Binding(get: {
                            store.monitorConfig.movement
                        }, set: { value in
                            store.send(.movementChanged(value))
                        })
                    )
                    
                    AlarmRowView(
                        icon: "Alarms/power",
                        title: "power".localized,
                        subtitle: "turn_on_the_serenade_not_charging".localized,
                        isOn: Binding(get: {
                            store.monitorConfig.power
                        }, set: { value in
                            store.send(.powerChanged(value))
                        })
                    )
                    
                    AlarmRowView(
                        icon: "Alarms/headphones",
                        title: "headphones".localized,
                        subtitle: "turn_on_the_siren_earphone_disconnected".localized,
                        isOn: Binding(get: {
                            store.monitorConfig.headphones
                        }, set: { value in
                            store.send(.headphonesChanged(value))
                        })
                    )
                }
                .frame(maxWidth: 500)
            }
            .listStyle(.plain)
            .navigationTitle("alarms".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        AlarmsView(
            store: Store(
                initialState: Alarms.State()
            ) {
                Alarms()
            }
        )
    }
}
