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
    
    func url(endPoint: GAFEndpoint) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.host
        components.path = endPoint.path()
        return components.url
    }
    
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
        
        return request
    }
}

