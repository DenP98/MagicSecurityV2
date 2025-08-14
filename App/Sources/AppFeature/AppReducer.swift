import SwiftUI
import ComposableArchitecture

@Reducer
public struct AppReducer: Sendable {
    @Reducer(state: .equatable)
    public enum Destination {
        case splash(Splash)
        case onboarding(Onboarding)
        case paywall(Paywall)
        case mainMenu(MainMenu)
    }
    
    @ObservableState
    public struct State: Equatable {
        public var appDelegate: AppDelegateReducer.State
        @Presents public var destination: Destination.State?
        var isFirstLaunch: Bool = false
        
        public init(
            appDelegate: AppDelegateReducer.State = AppDelegateReducer.State(),
            destination: Destination.State? = .splash(Splash.State())
        ) {
            self.appDelegate = appDelegate
            self.destination = destination
        }
    }
    
    public enum Action {
        case appDelegate(AppDelegateReducer.Action)
        case didChangeScenePhase(ScenePhase)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.storeKitClient) var storeKitClient
    @Dependency(\.blockerRulesService) var blockerRulesService
    
    public init() {
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegateReducer()
        }
        Reduce { state, action in
            switch action {
            case let .didChangeScenePhase(scenePhase):
                switch scenePhase {
                case .active:
                    return .run { [userDefaults, storeKitClient] send in
                        let subscriptionIsActive = await storeKitClient.validateSubscription()
                        await userDefaults.setHasActiveSubscription(subscriptionIsActive)
                        let emptyFilters = FilterOptions()
                        await blockerRulesService.updateRules(emptyFilters)
                        await send(.destination(.presented(.mainMenu(.adBlock(.refreshFilters)))))
                    }
                case .background:
                    guard !userDefaults.hasScheduledFirstCloseNotification &&
                            !self.userDefaults.hasActiveSubscription else {
                        return .none
                    }
                    return .run { _ in
                        try await notificationClient.scheduleDelayedNotification(
                            "Don't forget about us!",
                            "Open MagicSecurity to continue",
                            3.0
                        )
                        await userDefaults.setHasScheduledFirstCloseNotification()
                    }
                default:
                    return .none
                }
                
            case .destination(.presented(.splash(.delegate(.finished)))):
                if !self.userDefaults.hasShownFirstLaunchPaywall {
                    return .send(.appDelegate(.requestNotificationPermission))
                } else {
                    if self.userDefaults.hasActiveSubscription {
                        state.destination = .mainMenu(MainMenu.State())
                    } else {
                        state.destination = .paywall(Paywall.State())
                    }
                    return .none
                }
                
            case .appDelegate(.notificationPermissionResponse(true)):
                state.destination = .onboarding(Onboarding.State())
                return .run { _ in
                    guard !self.userDefaults.hasActiveSubscription else {
                        return
                    }
                    #warning("setup exact time")
                    try await self.notificationClient.scheduleDailyNotification(
                        "Your security matters!",
                        "Open MagicSecurity to stay protected online",
                        20,
                        11
                    )
                }
                
            case .appDelegate(.notificationPermissionResponse(false)):
                state.destination = .onboarding(Onboarding.State())
                return .none
                
            case .destination(.presented(.onboarding(.delegate(.finished)))):
                if self.userDefaults.hasActiveSubscription {
                    state.destination = .mainMenu(MainMenu.State())
                } else if !self.userDefaults.hasShownFirstLaunchPaywall {
                    state.destination = .paywall(Paywall.State(isFirstPaywallAfterOnboarding: true))
                    state.isFirstLaunch = true
                    return .run { [userDefaults] _ in
                        await userDefaults.setHasShownFirstLaunchPaywall()
                    }
                } else {
                    state.destination = .paywall(Paywall.State())
                }
                return .none
                
            case .destination(.presented(.paywall(.delegate(.skipSelected)))),
                    .destination(.presented(.paywall(.delegate(.purchaseCompleted)))):
                state.destination = .mainMenu(MainMenu.State())
                
                guard state.isFirstLaunch else { return .none }
                
                return .run { [storeKitClient] _ in
                    await storeKitClient.requestReview()
                }
                
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
