//
//  UserDefaultsHelper.swift
//  Notes
//
//  Created by SC on 2022/09/05.
//

import Foundation

final class UserDefaultsHelper {
    private init() { }
    
    static let standard = UserDefaultsHelper()
    
    let userDefaults = UserDefaults.standard
    
    enum Key: String {
        case isExistingUser
    }
    
    var isExistingUser: Bool {
        get {
            return userDefaults.bool(forKey: Key.isExistingUser.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.isExistingUser.rawValue)
        }
    }
}
