//
//  HeroesUseCaseTests.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 1/4/25.
//

import XCTest
@testable import GokuAndFriends_B19

// PAra los tests del caso de uso hacemos uso de MockURProtocol y el singleton de  Store DAta provider
// que persiste la BBD en memoria
final class TransformationsUseCaseTests: XCTestCase {
    var hero: Hero!
    var sut: TransformationsUseCase!
    var storedData: StoreDataProvider!
    var secureData: SecureDataProtocol!
    let expectedToken = "token"

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        storedData = .sharedTesting
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        secureData = MockSecureDataProvider()
        let requestBuilder = RequestBuilder(secureData: secureData)
        let apiProvider = ApiProvider(session: session, requestBuilder: requestBuilder)
        sut = TransformationsUseCase(apiProvider: apiProvider, storedData: storedData)
        secureData.setToken(expectedToken)
    }

    override func tearDownWithError() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        storedData.clearBBDD()
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }
    
    // Test de la función loadTransformations
    // SE hace test de todas las funciones que no son privadas.
    func testLoadTransformations_forHeroWithTransformations() throws {
        
        // Given
        var expectedTransformations: [HeroTransformations] = []
        // Id de Goku
        let heroId = "D13A40E5-4418-4223-9CE6-D2F9A28EBE94"
        MockURLProtocol.requestHandler = { request in
                let urlData = try XCTUnwrap(Bundle(for: ApiProviderTest.self).url(forResource: "Transformations", withExtension: "json"))
                let data = try Data(contentsOf: urlData)
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, data)
        }
        // Aqui se pasa el id de Goku para usar sus transfromaciones
//        let initialCountTransformationsInBDD = storedData.fetchTransformations()
        let initialCountTransformationsInBDD = storedData.numTransformations(forHeroId: heroId)
//        print(initialCountTransformationsInBDD.count)
//        let counter = initialCountTransformationsInBDD.count
        print()
        print("XXXXXX XXXXX XXXXXX")
        print("initialCountTransformationsInBDD \(initialCountTransformationsInBDD)")
        print()
        
        // When
        let expectation = expectation(description: "Use case return transformations")
        // Aqui se pasa de nuevo el id de Goku
        sut.fetchTransformationsForHeroWith(id: heroId) { result in
            switch result {
            case .success(let transformation):
                expectation.fulfill()
                expectedTransformations = transformation
                print()
                print()
                print("XXXXX \(expectedTransformations.count)")
                print("XXXXX")
                
            case .failure(_):
                XCTFail("Waititng for ssuccess")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        
        // Se pasa de nuevo id de Goku
        let finalCountTransformationsInBBDD = storedData.numTransformations(forHeroId: heroId)
        
//        XCTAssertEqual(counter, counter)
//        XCTAssertEqual(finalCountTransformationsInBBDD, 0)
//        XCTAssertEqual(expectedTransformations.count, 0)
        
        //let transformation = try XCTUnwrap(expectedTransformations.first)
        
        // Validamos la información recibida de la función
        //XCTAssertEqual(expectedTransformations.count, 14)
        
//        XCTAssertEqual(hero.id, "17824501-1106-4815-BC7A-BFDCCEE43CC9")
        
        //XCTAssertEqual("17824501-1106-4815-BC7A-BFDCCEE43CC9", "17824501-1106-4815-BC7A-BFDCCEE43CC9")
        
//        let expectedDesc = "Cómo todos los Saiyans con cola, Goku es capaz de convertirse en un mono gigante si mira fijamente a la luna llena. Así es como Goku cuando era un infante liberaba todo su potencial a cambio de perder todo el raciocinio y transformarse en una auténtica bestia. Es por ello que sus amigos optan por cortarle la cola para que no ocurran desgracias, ya que Goku mató a su propio abuelo adoptivo Son Gohan estando en este estado. Después de beber el Agua Ultra Divina, Goku liberó todo su potencial sin necesidad de volver a convertirse en Oozaru"
//        XCTAssertEqual(transformation.name, "1. Oozaru – Gran Mono")
//        XCTAssertEqual(transformation.description, expectedDesc)
//        XCTAssertEqual(transformation.photo, "https://areajugones.sport.es/wp-content/uploads/2021/05/ozarru.jpg.webp")
    }
}
