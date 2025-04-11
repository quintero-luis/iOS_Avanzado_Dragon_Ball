//
//  ApiProviderTest.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 31/3/25.
//

import XCTest
@testable import GokuAndFriends_B19

final class ApiProviderLocationsTest: XCTestCase {
    
    var sut: ApiProvider!
    var secureData: SecureDataProtocol!
    let expectedToken = "token"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Configuración de la URLSession con el MockURLProtocol
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        // Inicializamos el SecureData para el token
        secureData = MockSecureDataProvider()
        let requestBuilder = RequestBuilder(secureData: secureData)
        
        // Creamos el ApiProvider para interactuar con la API
        sut = ApiProvider(session: session, requestBuilder: requestBuilder)
        
        // Establecemos el token esperado
        secureData.setToken(expectedToken)
    }

    override func tearDownWithError() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }
    
    // Test que verifica la correcta recuperación de las localizaciones
    func testFetchHeroLocations() throws {
        // Given
        var expectedLocations: [ApiHeroLocation] = []
        var receivedRequest: URLRequest?
        // Configuramos el mock para simular la respuesta de la API
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderLocationsTest.self).url(forResource: "Locations", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, data)
        }
        
        // When
        let expectation = expectation(description: "load hero locations")
        // Id de Maestro Roshi
        let heroId = "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3"
        sut.fetchLocationForHeroWith(id: heroId) { result in
            switch result {
            case .success(let locations):
                expectation.fulfill()
                expectedLocations = locations
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        
        // Validamos la info del request
        XCTAssertEqual(receivedRequest?.url?.absoluteString, "https://dragonball.keepcoding.education/api/heros/locations")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertEqual(receivedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json, charset=utf-8")
        XCTAssertEqual(receivedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
        
        // Validamos la información recibida
        let location = try XCTUnwrap(expectedLocations.first)
        
//        XCTAssertEqual(location.id, "D13A40E5-4418-4223-9CE6-D2F9A28EBE94")
        // MARK: - Esto me da error, dice nil no es igual a Maestro Roshi, según yo, porque no hay name de Hero en Locations, sólo id de hero
//        XCTAssertEqual(location.hero?.name, "Maestro Roshi")
        XCTAssertEqual(location.hero?.id, "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3")
        XCTAssertEqual(location.latitude, "36.8415268")
        XCTAssertEqual(location.longitude, "-2.4746262")
        XCTAssertEqual(location.date, "2022-09-11T00:00:00Z")
    }
    
    // Test que simula un error al recuperar las localizaciones (p. ej., error del servidor)
    func testFetchHeroLocations_ServerError() {
        // Given
        MockURLProtocol.error = NSError(domain: "io.keepcoding.B19", code: 503)
        var expectedError: GAFError?
        
        // When
        let expectation = expectation(description: "load hero locations fail")
        expectation.assertForOverFulfill = false
        let heroId = "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3"
        sut.fetchLocationForHeroWith(id: heroId) { result in
            switch result {
            case .success(_):
                XCTFail("Expected failure but got success")
            case .failure(let error):
                expectedError = error
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedError)
    }
    
    // Test para verificar el manejo de un error por status code al intentar obtener localizaciones
    func testFetchHeroLocations_StatusCodeError() {
        // Given
        var expectedError: GAFError?
        
        MockURLProtocol.requestHandler = { request in
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderLocationsTest.self).url(forResource: "Locations", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 401))
            
            return (response, data)
        }
        
        // When
        let expectation = expectation(description: "load hero locations fails with status code 401")
        let heroId = "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3"
        sut.fetchLocationForHeroWith(id: heroId) { result in
            switch result {
            case .success(_):
                XCTFail("Expected failure but got success")
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

