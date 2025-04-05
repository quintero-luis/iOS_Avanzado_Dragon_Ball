//
//  MockSecureDataProvider.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 1/4/25.
//

import Foundation
@testable import GokuAndFriends_B19

// Struct que implementa el protocol SecureDataProtocol
// Hace uso de Userdefaults para no modificar la información de la app guardada en el KeyChain
struct MockSecureDataProvider: SecureDataProtocol {
    let keyToken = "keytoken"
    let userDefaults = UserDefaults.standard
    
    func getToken() -> String? {
        userDefaults.value(forKey: keyToken) as? String
    }
    
    func setToken(_ token: String) {
        userDefaults.setValue(token, forKey: keyToken)
    }
    
    func clearToken() {
        userDefaults.removeObject(forKey: keyToken)
    }
}
