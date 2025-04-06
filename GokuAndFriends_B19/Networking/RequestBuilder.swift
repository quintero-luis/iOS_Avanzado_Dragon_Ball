//
//  RequestBuilder.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 27/3/25.
//

import Foundation

/// ¿Qué hace este archivo?
/*
 Crea la URL completa para cada endpoint.
 Construye la petición HTTP (URLRequest) con método, headers y body.
 Maneja errores si la URL es inválida. */
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
        // Cabeceras: Authorization, Content-Type
        if endpoint.isAuthoritationREquired {
            guard let token = secureData.getToken() else {
                throw .sessionTokenMissed
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
        }
        
        request .setValue("application/json, charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = endpoint.params()
        debugPrint(request)
        debugPrint(endpoint.path())
        debugPrint("----------")
        debugPrint(endpoint.params())
        return request
        
        /*
         Conclusión
         Facilita la construcción de URLRequest a partir de GAFEndpoint.
         Añade autenticación (Bearer Token) y formato JSON.
         Maneja errores cuando la URL es inválida.
         */
    }
}

