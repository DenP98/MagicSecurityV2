//
//  MailTestKey.swift
//  MagicSecurity
//
//  Created by User on 30.05.25.
//

import Dependencies

extension DependencyValues {
    public var mailClient: MailClient {
        get { self[MailClient.self] }
        set { self[MailClient.self] = newValue }
    }
}

extension MailClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension MailClient {
    public static let noop = Self(
        canSendMail: { await MainActor.run { true } },
        presentMailComposer: { _, _, _ in }
    )
}
        
