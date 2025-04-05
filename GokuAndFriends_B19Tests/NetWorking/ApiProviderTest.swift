//
//  ApiProviderTest.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 31/3/25.
//

import XCTest
@testable import GokuAndFriends_B19

final class ApiProviderTest: XCTestCase {
    
    var sut: ApiProvider!
    var secureData: SecureDataProtocol!
    let expectedToken = "token"

    // LAs funciones setup y teardoen se ekecutan con da tests
    // setup antes de ejecutarse y tearDoen al finalizar, idelaes para configurar y limpiar respectivamente el objeto
    // sobre el que hacemos el test
    override func setUpWithError() throws {
       // Creamos la URLSession usando nuestro Mock de URLProtocol en la configuración
        try super.setUpWithError()
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        // Creamos ApiProvider con usando nuestra session en el constructor
        // usamos nuestro Mock de secureData para crear el api provider y poder guardar y borrar el token sin afectar a la app
        secureData = MockSecureDataProvider()
        let requestBuilder = RequestBuilder(secureData: secureData)
        sut = ApiProvider(session: session, requestBuilder: requestBuilder)
        secureData.setToken(expectedToken)
    }

    // Importante restablecer el estado de sut y MockURLProtocol tras cada test
    override func tearDownWithError() throws {
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.error = nil
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }
    
    // Test que compruba el correcto funcionamiento de la llamada a heroes de la api
    func testfetchHeroes() throws {
        // Given
        var expectedHeroes: [ApiHero] = []
        
        // Inicializamos el MockURLProtocol
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            // Guardamos en una variable la request que no devuelve el mock para validaciones posteriores.
            receivedRequest = request
            
            // Creamos DAta que recibiría la app en el dataTask
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTest.self).url(forResource: "Heroes", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            // Creamos el response que recibiría la app en el dataTask
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, data)
        }
        
        // When
        // procesos asincronos hacemos uso de expectations que nos permite esperar aque se jecuten
        let expectation = expectation(description: "load heroes")
        sut.fetchHeroes { result in
            switch result {
            case .success(let heroes):
                // Con fullfil indicamos que expectation se ha compltado
                expectation.fulfill()
                expectedHeroes = heroes
            case .failure(let error):
                XCTFail("Waiting for success")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        
        // Validamos la info del a request
        XCTAssertEqual(receivedRequest?.url?.absoluteString, "https://dragonball.keepcoding.education/api/heros/all")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertEqual(receivedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json, charset=utf-8")
        XCTAssertEqual(receivedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
        
        // Validamos la información recibida de la función
        XCTAssertEqual(expectedHeroes.count, 15)
        let hero = try XCTUnwrap(expectedHeroes.first)
        
        XCTAssertEqual(hero.name, "Maestro Roshi")
        XCTAssertEqual(hero.id, "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3")
        XCTAssertEqual(hero.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2020/06/Roshi.jpg?width=300")
        XCTAssertFalse(hero.favorite!)
        let expectedDesc = "Es un maestro de artes marciales que tiene una escuela, donde entrenará a Goku y Krilin para los Torneos de Artes Marciales. Aún en los primeros episodios había un toque de tradición y disciplina, muy bien representada por el maestro. Pero Muten Roshi es un anciano extremadamente pervertido con las chicas jóvenes, una actitud que se utilizaba en escenas divertidas en los años 80. En su faceta de experto en artes marciales, fue quien le enseñó a Goku técnicas como el Kame Hame Ha"
        XCTAssertEqual(hero.description, expectedDesc)

    }
    
    // Test de la función de fetchHeroes cuando recibe un error del servidor
    // para ello usamos la varibale error de Mock URLPRotocol
    func testfetchHeroes_ServerError() {
        // Given
        MockURLProtocol.error = NSError(domain: "io.keepcoding.B19", code: 503)
        var expectedError: GAFError?
        
        // When
        let expectation = expectation(description: "load heroes fail")
        // Cuando en un tests se lanza un exception el sistema por defecto da por completada la expectations
        // poniendo a false esta variable podemos evitar ese comportamiento
        expectation.assertForOverFulfill = false
        
        sut.fetchHeroes { result in
            switch result {
            case .success(_):
                XCTFail("Waiting for failure")
            case .failure(let error):
                expectedError = error
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedError)
    }
    
    // Test de la función de fetchHeroes cuando recibe un error de status Code
    // DEcidimos el startusCode al crear el response
    func testFechtHeroes_StatusCodeError() {
        // Given
        var expectedError: GAFError?
        
        MockURLProtocol.requestHandler = { request in
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTest.self).url(forResource: "Heroes", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 401))
            
            return (response, data)
        }
        
        // When
        let expectation = expectation(description:" Load heroes fails with status Code 401")
        sut.fetchHeroes { result in
            switch result {
            case .success(_):
                XCTFail("Waiting for failure")
            case .failure(let error):
                expectedError = error
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedError)
        
    }



}
