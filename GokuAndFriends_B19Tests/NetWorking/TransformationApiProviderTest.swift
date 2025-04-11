//
//  ApiProviderTest.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 31/3/25.
//

import XCTest
@testable import GokuAndFriends_B19

final class TransformationsApiProviderTest: XCTestCase {
    
    var sut: ApiProvider!
    var secureData: SecureDataProtocol!
    let expectedToken = "token"

    override func setUpWithError() throws {
        try super.setUpWithError()
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        secureData = MockSecureDataProvider()
        let requestBuilder = RequestBuilder(secureData: secureData)
        sut = ApiProvider(session: session, requestBuilder: requestBuilder)
        secureData.setToken(expectedToken)
    }

    override func tearDownWithError() throws {
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.error = nil
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }

    // Test que comprueba el correcto funcionamiento de la llamada a transformations de la API
    func testFetchTransformations() throws {
        // Given
        var expectedTransformations: [ApiTransformations] = []
        
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            // Usamos el archivo JSON de Transformations para simular la respuesta
            let urlData = try XCTUnwrap(Bundle(for: TransformationsApiProviderTest.self).url(forResource: "Transformations", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            // Creamos el response que la app recibiría en el dataTask
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, data)
        }
        
        // When
        let expectation = expectation(description: "load transformations")
        let heroId = "D13A40E5-4418-4223-9CE6-D2F9A28EBE94"
        sut.fetchTransformations(id: heroId) { result in
            switch result {
            case .success(let transformations):
                expectation.fulfill()
                expectedTransformations = transformations
            case .failure(let error):
                XCTFail("Waiting for success")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        
        // Validamos la info del request
        XCTAssertEqual(receivedRequest?.url?.absoluteString, "https://dragonball.keepcoding.education/api/heros/tranformations")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertEqual(receivedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json, charset=utf-8")
        XCTAssertEqual(receivedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
        
        // Validamos la información recibida de la función
        XCTAssertEqual(expectedTransformations.count, 14)
        let transformation = try XCTUnwrap(expectedTransformations.first)
        
        XCTAssertEqual(transformation.name, "1. Oozaru – Gran Mono")
        XCTAssertEqual(transformation.id, "17824501-1106-4815-BC7A-BFDCCEE43CC9")
    }

    // Test de la función fetchTransformations cuando recibe un error del servidor
    func testFetchTransformations_ServerError() {
        // Given
        MockURLProtocol.error = NSError(domain: "io.keepcoding.B19", code: 503)
        var expectedError: GAFError?
        
        // When
        let expectation = expectation(description: "load transformations fail")
        expectation.assertForOverFulfill = false
        let heroId = "D13A40E5-4418-4223-9CE6-D2F9A28EBE94"
        sut.fetchTransformations(id: heroId) { result in
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

    // Test de la función fetchTransformations cuando recibe un error de status Code
    func testFetchTransformations_StatusCodeError() {
        // Given
        var expectedError: GAFError?
        
        MockURLProtocol.requestHandler = { request in
            let urlData = try XCTUnwrap(Bundle(for: TransformationsApiProviderTest.self).url(forResource: "Transformations", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 401))
            
            return (response, data)
        }
        
        // When
        let expectation = expectation(description:" Load transformations fails with status Code 401")
        let heroId = "D13A40E5-4418-4223-9CE6-D2F9A28EBE94"
        sut.fetchTransformations(id: heroId) { result in
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

