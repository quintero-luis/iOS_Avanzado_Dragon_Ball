//
//  SecureDataProvider.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 1/4/25.
//

import Foundation
import KeychainSwift

protocol SecureDataProtocol {
    func getToken() -> String?
    func setToken(_ token: String)
    func clearToken()
}

// Struct que implementa el protocol SecureDataProtocol
// Hace uso de KEychain para guardar la información del token en el llavero del dispositivo
struct SecureDataProvider: SecureDataProtocol {
    
    // Constante para hacer referencia al valor del token de session
    private let keyToken = "keyToken"
    private let keyChain = KeychainSwift()

    func getToken() -> String? {
        keyChain.get(keyToken)
    }
    
    func setToken(_ token: String) {
        keyChain.set(token, forKey: keyToken)
    }
    
    func clearToken() {
        keyChain.delete(keyToken)
    }
}
