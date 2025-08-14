//
//  Other.swift
//  MagicSecurity
//
//  Created by User on 28.04.25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct Other: Reducer {
    @Reducer(state: .equatable)
    public enum Destination {
        case paywall(Paywall)
        case blackList(URLList)
        case whiteList(URLList)
        case secretNotes(SecretNotes)
        case alarms(Alarms)
        
        case activatePassword(ActivatePassword)
        case setEnterPassword(SetEnterPassword)
    }

    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared var blackListItems: [URLItem]
        @Shared var whiteListItems: [URLItem]
        @Shared(.fileStorage(.secretNotesURL)) var secretNotes: [Note] = []
        @Shared var alarmsConfig: SecurityMonitorConfig
        var isPremium = false
        
        var alarmsCount: Int {
            (alarmsConfig.movement ? 1 : 0)
            + (alarmsConfig.power ? 1 : 0)
            + (alarmsConfig.headphones ? 1 : 0)
        }

        public init(
            destination: Destination.State? = nil,
            blackListItems: Shared<[URLItem]> = .init(value: []),
            whiteListItems: Shared<[URLItem]> = .init(value: []),
            alarmsConfig: Shared<SecurityMonitorConfig> = .init(value: SecurityMonitorConfig(movement: true, power: true, headphones: true))
        ) {
            self.destination = destination
            self._blackListItems = blackListItems
            self._whiteListItems = whiteListItems
            self._alarmsConfig = alarmsConfig
        }
    }

    public enum Action {
        case onAppear
        case blackListUpdated([URLItem])
        case whiteListUpdated([URLItem])
        case monitorConfigUpdated(SecurityMonitorConfig)
        case premiumButtonTapped
        case blackListTapped
        case whiteListTapped
        case secretNotesTapped
        case alarmsTapped

        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.blockerRulesService) var blockerRulesService
    @Dependency(\.securityMonitor) var securityMonitorClient
    @Dependency(\.userDefaults) var userDefaults

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let blackListURLs = blockerRulesService
                    .loadBlackList()
                    .map { URLItem(value: $0) }
                let whiteListURLs = blockerRulesService
                    .loadWhiteList()
                    .map { URLItem(value: $0) }
                state.isPremium = userDefaults.hasActiveSubscription
                
                return .merge(
                    .send(.blackListUpdated(blackListURLs)),
                    .send(.whiteListUpdated(whiteListURLs)),
                    .run(operation: { [securityMonitorClient] send in
                        let config = await securityMonitorClient.monitorConfig()
                        await send(.monitorConfigUpdated(config))
                    })
                )
                
            case let .blackListUpdated(urls):
                state.$blackListItems.withLock { urlItems in
                    urlItems = urls
                }
                return .none
                
            case let .whiteListUpdated(urls):
                state.$whiteListItems.withLock { urlItems in
                    urlItems = urls
                }
                return .none
                
            case let .monitorConfigUpdated(updatedConfig):
                state.$alarmsConfig.withLock { config in
                    config = updatedConfig
                }
                return .none
                
            case .premiumButtonTapped:
                state.destination = .paywall(Paywall.State())
                return .none

            case .blackListTapped:
                state.destination = .blackList(URLList.State(type: .black, urls: state.$blackListItems))
                return .none

            case .whiteListTapped:
                state.destination = .whiteList(URLList.State(type: .white, urls: state.$whiteListItems))
                return .none

            case .secretNotesTapped:
                if userDefaults.passwordHash != nil {
                    state.destination = .setEnterPassword(SetEnterPassword.State(screenType: .enter))
                } else {
                    state.destination = .activatePassword(ActivatePassword.State())
                }
                return .none
                
            case .destination(.presented(.activatePassword(.delegate(.activatePassword)))):
                state.destination = .setEnterPassword(SetEnterPassword.State(screenType: .setNew))
                return .none
                
            case .destination(.presented(.activatePassword(.delegate(.skipPassword)))),
                    .destination(.presented(.setEnterPassword(.delegate(.passwordVerified)))),
                    .destination(.presented(.setEnterPassword(.delegate(.passwordSkipped)))):
                state.destination = .secretNotes(SecretNotes.State(notes: state.$secretNotes))
                return .none

            case .alarmsTapped:
                state.destination = .alarms(Alarms.State(monitorConfig: state.$alarmsConfig))
                return .none

            case let .destination(.presented(.blackList(.delegate(.blackListUpdated(items))))):
                return .run { [blockerRulesService] send in
                    await blockerRulesService.updateBlackList(items.map(\.value))
                    await send(.blackListUpdated(items))
                }
            
            case let .destination(.presented(.whiteList(.delegate(.whiteListUpdated(items))))):
                return .run { [blockerRulesService] send in
                    await blockerRulesService.updateWhiteList(items.map(\.value))
                    await send(.whiteListUpdated(items))
                }
            
            case let .destination(.presented(.secretNotes(.delegate(.notesUpdated(updatedItems))))):
                state.$secretNotes.withLock { notes in
                    notes = updatedItems
                }
                return .none
                
            case let .destination(.presented(.alarms(.delegate(.monitorConfigUpdated(updatedConfig))))):
                return .run { [securityMonitorClient] send in
                    await securityMonitorClient.updateMonitorConfig(updatedConfig)
                    await send(.monitorConfigUpdated(updatedConfig))
                }
                
            case .destination(.presented(.paywall(.delegate(.purchaseCompleted)))):
                state.isPremium = userDefaults.hasActiveSubscription
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
