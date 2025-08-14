//
//  MailClient.swift
//  MagicSecurity
//
//  Created by User on 30.05.25.
//

import Foundation
import MessageUI
import UIKit
import ComposableArchitecture

@DependencyClient
public struct MailClient: Sendable {
    public var canSendMail: @Sendable () async -> Bool = { true }
    public var presentMailComposer: @Sendable (String, String, String) async -> Void
}
