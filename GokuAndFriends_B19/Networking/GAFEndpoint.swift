//
//  HTTPMethods.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 27/3/25.
//

import Foundation

enum HTTPMethods: String {
    case POST, GET, PUT, DELETE
}

// Endpoints para servicios no da:
// - El path
// - El httpmethod
// - Params si son necesarios 
enum GAFEndpoint {
    case heroes(name: String)
    case locations(id: String)
    
    
    // VAriable para indiocar si el endpoint debe llevar cavecera de autenticación con el token
    var isAuthoritationREquired: Bool {
        switch self {
        case .heroes, .locations:
            return true
        }
    }
    
    func path() -> String {
        switch self {
        case .heroes:
            return "/api/heros/all"
        case .locations:
            return "/api/heros/locations"
        }
    }
    
    func httpMethod() -> String {
        switch self {
        case .heroes, .locations:
            return HTTPMethods.POST.rawValue
        }
    }
    
    func params() -> Data? {
        switch self {
        case .heroes(name: let name):
            let attributes = ["name": name]
            // Creamos Data a partir de un dicionario
            let data = try? JSONSerialization.data(withJSONObject: attributes)
            return data
            
        case .locations(id: let id):
            let attributes = ["id": id]
            // Creamos Data a partir de un dicionario
            let data = try? JSONSerialization.data(withJSONObject: attributes)
            return data
        }
    }
}
