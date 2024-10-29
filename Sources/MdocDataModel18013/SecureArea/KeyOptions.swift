/*
Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation
#if canImport(Security)
import Security
#endif

public struct KeyOptions: Sendable {
    public var curve: CoseEcCurve = .P256 
    public var secureAreaName: String?
#if canImport(Security)
    public var accessProtection: KeyAccessProtection?
    public var accessControl: KeyAccessControl?
#endif
    public var keyPurposes: [KeyPurpose]? = KeyPurpose.allCases
    public var additionalOptions: Data?
}

/// Tasks for which keys can be used.
public enum KeyPurpose: String, CaseIterable, Sendable {
    case signing = "Signing"
    case keyAgreement = "Key Agreement"
}

#if canImport(Security)
/// Key ccess protection options
///
/// You control an app’s access to a keychain item relative to the state of a device by setting the item’s kSecAttrAccessible attribute when you create the item.
public enum KeyAccessProtection: Int, CaseIterable, Sendable {
    case whenUnlocked
    case afterFirstUnlock
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
    case whenPasscodeSetThisDeviceOnly
    
    /// constant to use for the kSecAttrAccessible attribute
    public var constant: CFString {
        switch self {
        case .whenUnlocked: kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock
        case .whenUnlockedThisDeviceOnly: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
/// Key access control settings
///
/// Using these settings you can check for the presence of the authorized user at the very last minute before retrieving login credentials from the keychain. This helps secure the private key even if the user hands the device in an unlocked state to someone else.
public struct KeyAccessControl: OptionSet, Sendable {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public let rawValue: Int
    
    /// Require user presence policy using biometry or Passcode
    public static let requireUserPresence = KeyAccessControl(rawValue: 1 << 0)
    /// Require application provided password for additional data encryption key generation
    public static let requireApplicationPassword = KeyAccessControl(rawValue: 1 << 1)
    
    public var flags: SecAccessControlCreateFlags {
        var result: SecAccessControlCreateFlags = []
        if contains(.requireUserPresence) { result.insert(.userPresence) }
        if contains(.requireApplicationPassword) { result.insert(.applicationPassword) }
        return result
    }
}
#endif
