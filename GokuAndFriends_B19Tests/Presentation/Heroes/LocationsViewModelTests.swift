//
//  HeroesViewModelTests.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 1/4/25.
//


import XCTest
@testable import GokuAndFriends_B19
import MapKit

class MockLocationsUseCase: HeroDetailUseCaseProtocol {
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[HeroLocation], GAFError>) -> Void) {
        do {
            let urlData = try XCTUnwrap(Bundle(for: LocationsViewModelTests.self).url(forResource: "Locations", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            let response = try JSONDecoder().decode([ApiHeroLocation].self, from: data)
            completion(.success(response.map { $0.mapToHeroLocation() }))
        } catch {
            completion(.failure(.errorPArsingData))
        }
    }
}

class MockLocationsUseCaseError: HeroDetailUseCaseProtocol {
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[HeroLocation], GAFError>) -> Void) {
        completion(.failure(.noDataReceived))
    }
}

final class LocationsViewModelTests: XCTestCase {
    
    var sut: HeroDetailViewModel!
    var hero: Hero!

    override func setUpWithError() throws {
        try super.setUpWithError()
        hero = Hero(id: "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3", name: "Maestro Roshi", description: "", photo: "")
    }

    override func tearDownWithError() throws {
        sut = nil
        hero = nil
        try super.tearDownWithError()
    }
    
    func testLoadData_Success() {
        // Given
        var expectedLocations: [HeroAnnotation] = []
        sut = HeroDetailViewModel(hero: hero, useCase: MockLocationsUseCase())
        
        // When
        let expectation = expectation(description: "ViewModel loads locations and informs state change")
        sut.stateChanged = { [weak self] state in
            switch state {
            case .locationsUpdated:
                expectedLocations = self?.sut.getHeroLocations() ?? []
                expectation.fulfill()
            case .errorLoadingLocation(error: _):
                XCTFail("Waiting for success")
            }
        }
        sut.loadData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        //  Cada héroe tiene mínimo 1 localizacion, en este caso Mstro Roshi tiene 1
        XCTAssertGreaterThan(expectedLocations.count, 0)
    }
    
    func testLoadData_Error() {
        // Given
        sut = HeroDetailViewModel(hero: hero, useCase: MockLocationsUseCaseError())
        
        // When
        let expectation = expectation(description: "ViewModel fails to load locations and informs state change")
        sut.stateChanged = { state in
            switch state {
            case .locationsUpdated:
                XCTFail("Waiting for failure")
            case .errorLoadingLocation(let error):
                print(error)
                expectation.fulfill()
            }
        }
        sut.loadData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}

// Extension for mapping ApiHeroLocation to HeroLocation
extension ApiHeroLocation {
    func mapToHeroLocation() -> HeroLocation {
        HeroLocation(id: self.id,
                     longitude: self.longitude,
                     latitude: self.latitude,
                     date: self.date,
                     hero: self.hero)
    }
}


