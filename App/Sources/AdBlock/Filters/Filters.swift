//
//  Filters.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//

import ComposableArchitecture

@Reducer
public struct Filters {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case paywall(Paywall)
    }
    
    public struct Filter: Sendable, Equatable, Identifiable {
        public let id: Int
        let title: String
        let iconName: String
        let isEnabled: Bool
    }
    
    @ObservableState
    public struct State: Equatable {
        @Shared var filterOptions: FilterOptions
        @Presents public var destination: Destination.State?
        var filters: [Filter] {
            filtersFromFilterOptions(filterOptions)
        }
        
        public init(filterOptions: Shared<FilterOptions> = .init(value: .all)) {
            self._filterOptions = filterOptions
        }
    }
    
    public enum Action {
        case toggleFilter(Filter.ID)
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        
        public enum Delegate {
            case filtersUpdated(FilterOptions)
        }
    }
    
    @Dependency(\.userDefaults) var userDefaults
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .toggleFilter(id):
                
                if userDefaults.hasActiveSubscription {
                    var filters = state.filterOptions
                    filters.formSymmetricDifference(.init(rawValue: id))
                    return .send(.delegate(.filtersUpdated(filters)))
                } else {
                    state.destination = .paywall(Paywall.State())
                    return .none
                }
                
            case .delegate, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Filters.State {
    func filtersFromFilterOptions(_ filterOptions: FilterOptions) -> [Filters.Filter] {
        [
            .init(id: FilterOptions.ads.rawValue, title: "block_ads", iconName: "Filters/ads_filter", isEnabled: filterOptions.contains(.ads)),
            .init(id: FilterOptions.tracking.rawValue, title: "block_tracking", iconName: "Filters/tracking_filter", isEnabled: filterOptions.contains(.tracking)),
            .init(id: FilterOptions.scripts.rawValue, title: "block_scripts", iconName: "Filters/scripts_filter", isEnabled: filterOptions.contains(.scripts)),
            .init(id: FilterOptions.adultSites.rawValue, title: "block_adult_sites", iconName: "Filters/adult_sites_filter", isEnabled: filterOptions.contains(.adultSites)),
            .init(id: FilterOptions.gambling.rawValue, title: "block_gambling_sites", iconName: "Filters/gambling_sites_filter", isEnabled: filterOptions.contains(.gambling)),
            .init(id: FilterOptions.customFonts.rawValue, title: "block_custom_fonts", iconName: "Filters/custom_fonts_filter", isEnabled: filterOptions.contains(.customFonts)),
            .init(id: FilterOptions.socialButtons.rawValue, title: "block_social_buttons", iconName: "Filters/social_button_filter", isEnabled: filterOptions.contains(.socialButtons)),
        ]
    }
}
