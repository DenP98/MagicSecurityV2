//
//  AdBlock.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct AdBlock: Sendable {
    @Reducer(state: .equatable)
    public enum Destination {
        case filters(Filters)
        case tutorial(Tutorial)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Shared var filterOptions: FilterOptions
        var protectionEnabled: Bool {
            !filterOptions.isEmpty
        }
        @Presents public var destination: Destination.State?
        
        public init(
            filterOptions: FilterOptions = [],
            protectionEnabled: Bool = false,
            destination: Destination.State? = nil
        ) {
            self._filterOptions = .init(wrappedValue: filterOptions, .inMemory("filterOptions"))
            self.destination = destination
        }
    }
    
    public enum Action {
        case onAppear
        case refreshFilters
        case toggleProtection
        case customizationTapped
        case helpTapped
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.blockerRulesService) var blockerRulesService
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.refreshFilters)
                
            case .refreshFilters:
                let newFilters = blockerRulesService.getCurrentFilters()
                state.$filterOptions.withLock { filters in
                    filters = newFilters
                }
                return .none
                
            case .toggleProtection:
                if state.protectionEnabled {
                    return .run { [blockerRulesService] send in
                        let emptyFilters = FilterOptions()
                        await blockerRulesService.updateRules(emptyFilters)
                        await send(.refreshFilters)
                    }
                } else {
                    state.destination = .filters(Filters.State(filterOptions: state.$filterOptions))
                    return .none
                }
                
            case .customizationTapped:
                state.destination = .filters(Filters.State(filterOptions: state.$filterOptions))
                return .none
                
            case .helpTapped:
                state.destination = .tutorial(Tutorial.State())
                return .none
                
            case .destination(.presented(.tutorial(.delegate(.dismiss)))):
                state.destination = nil
                return .none
                
            case let .destination(.presented(.filters(.delegate(.filtersUpdated(newFilters))))):
                return .run { send in
                    await blockerRulesService.updateRules(newFilters)
                    await send(.refreshFilters)
                    
                    let blackList = (BlockerConstants.userDefaults!.array(forKey: BlockerConstants.blackListOptionsKey) as? [String] ?? [])
                        .compactMap { URL(string: $0) }
                    let whiteList = (BlockerConstants.userDefaults!.array(forKey: BlockerConstants.whiteListOptionsKey) as? [String] ?? [])
                        .compactMap { URL(string: $0) }
                    let rules = BlockerRulesMapper.getRules(filter: newFilters, blackList: blackList, whiteList: whiteList)
                    guard let jsonData = try? JSONEncoder().encode(rules),
                          let jsonString = String(data: jsonData, encoding: .utf8) else {
                        return
                    }
                    print(jsonString)
                }
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
