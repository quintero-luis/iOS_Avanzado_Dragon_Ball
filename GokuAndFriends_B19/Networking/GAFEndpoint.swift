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
    /// Define dos endpoints con sus respectivos parámetros:
    case heroes(name: String) // Para buscar héroes.
    case locations(id: String) // Para obtener la ubicación de un héroe.
    
    
    /// Variable para indiocar si el endpoint debe llevar cabecera de autenticación con el token
    var isAuthoritationREquired: Bool {
        switch self {
        case .heroes, .locations:
            return true
        }
    }
    
    /// dragonball.keepcoding.education es el dominio del servidor, y para cosas específicas se usa endpoints
    /// Aquí, "/api/heroes/all" es el endpoint que devuelve la lista de héroes.
    /// Devuelve la ruta específica de cada endpoint.
    func path() -> String {
        switch self {
        case .heroes:
            return "/api/heros/all"
        case .locations:
            return "/api/heros/locations"
        }
    }
    
    /// Devuelve el método HTTP Ambos endpoints usan POST.
    /// Retorna el método como String ("POST").
    func httpMethod() -> String {
        switch self {
        case .heroes, .locations:
            return HTTPMethods.POST.rawValue
        }
    }
    
    /// Devuelve los parámetros en formato JSON (Data)
    /// Convierte los parámetros (name, id) a JSON (Data) para enviarlos en el cuerpo de la solicitud.
    /// Usa JSONSerialization.data(withJSONObject:) para hacer la conversión.
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
