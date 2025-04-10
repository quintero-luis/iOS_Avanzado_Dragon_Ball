//
//  RequestBuilder.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 27/3/25.
//

import Foundation

// Builder para construir la request para un servicio a partir de un endpoint
struct RequestBuilder {
    let host = "dragonball.keepcoding.education"
    
    private var secureData: SecureDataProtocol
    
    init(secureData: SecureDataProtocol = SecureDataProvider()) {
        self.secureData = secureData
    }
    
    /// Construye la URL con esquema (https), host y path.
    /// Usa URLComponents para generar una URL válida.
    func url(endPoint: GAFEndpoint) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.host
        components.path = endPoint.path()
        return components.url
        /// Ejemplo
        /// let builder = RequestBuilder()
        /// let url = builder.url(endPoint: .heroes(name: ""))
        /// print(url)
        /// "https://dragonball.keepcoding.education/api/heros/all"
    }
    
    // Construcción de URLRequest
    /*
     1. Verifica si la URL es válida, si no, lanza GAFError.badUrl.
     2. Crea un URLRequest con la URL generada.
     3. Asigna el método HTTP (POST, etc.).
     4. Configura las cabeceras (Authorization, Content-Type).
     5. Asigna el httpBody con los parámetros JSON.
     */
    func build(endpoint: GAFEndpoint) throws(GAFError) -> URLRequest {
        guard let url = url(endPoint: endpoint) else {
            throw .badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod()
        
        // MARK: - Modificación para el login usar Basic Authentication y para lo demás Bearrer
        // Si es login, usa Basic Auth
        if case .login(let email, let password) = endpoint {
            let loginString = String(format: "%@:%@", email, password)
            
            // Codifica el loginString en Base64
            guard let loginData = loginString.data(using: .utf8) else {
                throw .errorPArsingData
            }
            
            let base64LoginData = loginData.base64EncodedString()
            
            // Agrega el encabezado Authorization con Basic Auth
            request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        } else {
            // Si no es login, agrega el Bearer Token si es necesario
            if endpoint.isAuthoritationREquired {
                guard let token = secureData.getToken() else {
                    throw .sessionTokenMissed
                }
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        // Establece el Content-Type para JSON
        request.setValue("application/json, charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Configura el cuerpo de la solicitud
        request.httpBody = endpoint.params()

        return request
    }
}

