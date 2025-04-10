//
//  ApiProvider.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 27/3/25.
//

import Foundation

struct ApiProvider {
    /// En conjunto, session ejecuta la solicitud y requestBuilder la crea correctamente.
    /// Se usa para manejar las solicitudes de red.
    var session: URLSession
    /// Se usa para construir los URLRequest que se envían a la API.
    /// RequestBuilder genera las solicitudes HTTP con la URL, los parámetros, el método (GET, POST, etc.) y las cabeceras necesarias, como el token de autenticación.
    var requestBuilder: RequestBuilder
    
    /* init()
     Proporciona valores predeterminados:
     session usa .shared, que es la sesión compartida de URLSession.
     requestBuilder usa .init(), lo que crea una nueva instancia de RequestBuilder.
     Permite personalización: Se pueden inyectar dependencias diferentes al crear una instancia
     (útil para pruebas o configuraciones especiales).
     */
    /// .shared permite usar una sesión única y compartida para todas las solicitudes HTTP.
    init(session: URLSession = .shared, requestBuilder: RequestBuilder = .init()) {
        self.session = session
        self.requestBuilder = requestBuilder
    }
    
    /// Crea una solicitud HTTP para obtener los héroes usando requestBuilder
    /// llama a manageResponse() para manejar la respuesta
    func fetchHeroes(name: String = "", completion: @escaping (Result<[ApiHero], GAFError>) -> Void) {
        
        do {
            let request = try requestBuilder.build(endpoint: .heroes(name: name))
            manageResponse(request: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    // Transformations
    func fetchTransformations(id: String, completion: @escaping (Result<[ApiTransformations], GAFError>) -> Void) {
        do {
            let request = try requestBuilder.build(endpoint: .transformations(id: id))
            manageResponse(request: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Crea solicitud HTTP para obtener la localización de los héroes usando manageResponse
    func fetchLocationForHeroWith(id: String, completion: @escaping (Result<[ApiHeroLocation], GAFError>) -> Void) {
        do {
            let request = try requestBuilder.build(endpoint: .locations(id: id))
            manageResponse(request: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Crea solicitud HTTP para obtener las transformaciones de los héroes usando manageResponse
    func fetchTransformationsForHero(id: String, completion: @escaping (Result<[ApiHeroTransformation], GAFError>) -> Void) {
        do {
            let request = try requestBuilder.build(endpoint: .transformations(id: id))
            manageResponse(request: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
        
    }
    
    // MARK: - Método de Login
    
    func authenticateUser(username: String, password: String, completion: @escaping (Result<String, GAFError>) -> Void) {
        do {
            let request = try requestBuilder.build(endpoint: .login(username: username, password: password))
            manageResponse(request: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Función que usa genéricos (T) de tipo Codable  para reutilizar en llamadas a servicios
    /// El tipo es inferido del completion que pasamos com parámetro
    func manageResponse<T: Codable>(request: URLRequest, completion: @escaping (Result<T, GAFError>) -> Void) {
        
        session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(.serverErrot(error: error)))
            }
            /// Intenta obtener el código de estado HTTP de la respuesta.
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            print("Código de estado recibido: \(statusCode ?? -1)")
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
                
                // Si el código de estado no es exitoso, manejamos el error.
                if let data = data {
                    // Aquí intentamos parsear el cuerpo de la respuesta de error
                    if let errorMessage = String(data: data, encoding: .utf8) {
                        print("Mensaje de error desde el servidor: \(errorMessage)")
                    }
                }
                completion(.failure(.responseError(code: statusCode)))
                return
            }
            
            /// Verifica que se haya recibido algún dato en la respuesta.
            guard let data else {
                debugPrint(data ?? "")
                completion(.failure(.noDataReceived))
                return
            }
            
            // Si el endpoint es login, manejar la respuesta como un token (String)
            if request.url?.path == GAFEndpoint.login(username: "", password: "").path() {
                if let token = String(data: data, encoding: .utf8) {
                    // Regresar el token como resultado
                    completion(.success(token as! T))  // Forzamos la conversión a T (String)
                } else {
                    completion(.failure(.noDataReceived))
                }
            } else {
                // Para otros endpoints, decodificamos como antes
                do {
                    let response = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(.noDataReceived))
                }
            }
        }.resume()
    }
}
