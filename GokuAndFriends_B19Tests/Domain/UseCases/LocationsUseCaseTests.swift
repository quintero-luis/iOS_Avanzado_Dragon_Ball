//
//  HeroesUseCaseTests.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 1/4/25.
//

import XCTest
@testable import GokuAndFriends_B19

final class LocationsUseCaseTests: XCTestCase {
    var sut: HeroDEtailUseCase!
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
        sut = HeroDEtailUseCase(storedData: storedData, apiProvider: apiProvider)
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
    

    func testFetchLocationsForHeroWith_shouldReturnCorrectLocations() throws {
        // Given
//        var expectedLocations: [HeroLocation] = []
        var expectedLocations: [HeroLocation] = []
        
        // I del Maestro Roshi
        let heroId = "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3"
        let apiHero = ApiHero(id: heroId, name: "Name", description: "", photo: "")
        storedData.insert(heroes: [apiHero])
        MockURLProtocol.requestHandler = { request in
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTest.self).url(forResource: "Locations", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            print("xxxxxxxx")
            print(String(data: data, encoding: .utf8) ?? "no se pudo convertir data a string")
            print()
            print("XXXXXXXXXXX")

            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, data)
        }
        
        let initialCount = storedData.numLocations(forHeroId: heroId)

        // When
        let expectation = expectation(description: "Use case returns locations for hero")
        sut.fetchLocationsForHeroWith(id: heroId) { result in
            switch result {
            case .success(let locations):
                expectedLocations = locations
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success response\(error)")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 2.6)

        let finalCount = storedData.numLocations(forHeroId: "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3")

        XCTAssertEqual(initialCount, 0)
        print("XXXXX \(initialCount)")
        XCTAssertEqual(expectedLocations.count, finalCount)
        print("XXXXX \(finalCount)")
        print("XXXXX \(expectedLocations.count)")
        if let s = expectedLocations.first {
            print("XXXXX \(s)")
        } else {
            print("No se encontró ninguna ubicación en expectedLocations")
        }
        
        
//        XCTAssertEqual(expectedLocations.count, 1) // Cambia si tu JSON tiene otro número
//
        let location = try XCTUnwrap(expectedLocations.first)
        print("XXXXX \(location.hero.id)")
        XCTAssertEqual(location.hero.id, "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3")
        XCTAssertEqual(location.latitude, "36.8415268")
        XCTAssertEqual(location.longitude, "-2.4746262")
        XCTAssertEqual(location.date, "2022-09-11T00:00:00Z")
    }
    
}



