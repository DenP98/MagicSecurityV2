//
//  MainTab.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//

import ComposableArchitecture

@Reducer
public struct MainMenu {
    
    @ObservableState
    public struct State: Equatable {
        var adBlock: AdBlock.State
        var lockedSecureBrowser: Locked<SecureBrowser>.State
        var other: Other.State
        var settings: Settings.State
        
        public init(
            adBlock: AdBlock.State = AdBlock.State(),
            lockedSecureBrowser: Locked<SecureBrowser>.State = Locked.State(content: SecureBrowser.State()),
            other: Other.State = Other.State(),
            settings: Settings.State = Settings.State()
        ) {
            self.adBlock = adBlock
            self.lockedSecureBrowser = lockedSecureBrowser
            self.other = other
            self.settings = settings
        }
    }
    
    public enum Action {
        case adBlock(AdBlock.Action)
        case lockedSecureBrowser(Locked<SecureBrowser>.Action)
        case other(Other.Action)
        case settings(Settings.Action)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.adBlock, action: \.adBlock) {
            AdBlock()
        }
        Scope(state: \.lockedSecureBrowser, action: \.lockedSecureBrowser) {
            Locked(contentReducer: SecureBrowser())
        }
        Scope(state: \.other, action: \.other) {
            Other()
        }
        Scope(state: \.settings, action: \.settings) {
            Settings()
        }
        Reduce { state, action in
            .none
        }
    }
}
