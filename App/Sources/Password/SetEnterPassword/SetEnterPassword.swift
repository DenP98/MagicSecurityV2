//
//  SetEnterPassword.swift
//  MagicSecurity
//
//  Created by User on 11.04.25.
//

import ComposableArchitecture
import CryptoKit
import Foundation

@Reducer
public struct SetEnterPassword: Sendable {
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public enum PasswordScreenType: Equatable, Sendable {
            case enter
            case setNew
            case confirmNew
        }
        
        var currentScreen: PasswordScreenType = .enter
        var enteredPassword: String = ""
        var newPassword: String = ""
        var errorMessage: String?
        
        var currentPassword: String {
            switch currentScreen {
            case .enter, .confirmNew:
                String(repeating: "*", count: enteredPassword.count)
            case .setNew:
                String(repeating: "*", count: newPassword.count)
            }
        }
        
        var currentScreenTitle: String {
            switch currentScreen {
            case .enter:
                "enter_password".localized
            case .setNew:
                "set_new_password".localized
            case .confirmNew:
                "confirm_new_password".localized
            }
        }
        
        public init(screenType: PasswordScreenType = .enter) {
            self.currentScreen = screenType
        }
    }
    
    public enum Action {
        case numberTapped(Int)
        case deleteTapped
        case continueTapped
        case skipPasswordTapped
        case setCurrentScreen(SetEnterPassword.State.PasswordScreenType)
        case setEnteredPassword(String)
        case setNewPassword(String)
        case setErrorMessage(String?)
        case delegate(Delegate)
        
        public enum Delegate {
            case passwordVerified
            case passwordSkipped
        }
    }
    
    @Dependency(\.userDefaults) var userDefaults
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .skipPasswordTapped:
                return .send(.delegate(.passwordSkipped))
                
            case let .numberTapped(number):
                state.errorMessage = nil
                switch state.currentScreen {
                case .enter:
                    state.enteredPassword += "\(number)"
                    let hashedInput = hashPassword(state.enteredPassword)
                    if hashedInput == userDefaults.passwordHash {
                        return .send(.delegate(.passwordVerified))
                    }
                case .setNew:
                    state.newPassword += "\(number)"
                case .confirmNew:
                    state.enteredPassword += "\(number)"
                }
                return .none
                
            case .deleteTapped:
                state.errorMessage = nil
                switch state.currentScreen {
                case .enter, .confirmNew:
                    if !state.enteredPassword.isEmpty {
                        state.enteredPassword.removeLast()
                    }
                case .setNew:
                    if !state.newPassword.isEmpty {
                        state.newPassword.removeLast()
                    }
                }
                return .none
                
            case .continueTapped:
                return .run { [state] send in
                    switch state.currentScreen {
                    case .setNew:
                        guard state.newPassword.count >= 1 else {
                            await send(.setErrorMessage("Password couldn't be empty"))
                            return
                        }
                        await send(.setCurrentScreen(.confirmNew))
                        await send(.setEnteredPassword(""))
                        
                    case .confirmNew:
                        if state.newPassword == state.enteredPassword {
                            let hashedPassword = hashPassword(state.newPassword)
                            await userDefaults.setPasswordHash(hashedPassword)
                            await send(.delegate(.passwordVerified))
                        } else {
                            await send(.setCurrentScreen(.setNew))
                            await send(.setNewPassword(""))
                            await send(.setEnteredPassword(""))
                            await send(.setErrorMessage("passwords_dont_match".localized))
                        }
                        
                    default: break
                    }
                }
                
            case let .setCurrentScreen(screen):
                state.currentScreen = screen
                return .none
                
            case let .setEnteredPassword(password):
                state.enteredPassword = password
                return .none
                
            case let .setNewPassword(password):
                state.newPassword = password
                return .none
                
            case let .setErrorMessage(message):
                state.errorMessage = message
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
