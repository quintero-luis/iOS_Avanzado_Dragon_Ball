//
//  HeroesViewModelTests.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 1/4/25.
//

import XCTest
@testable import GokuAndFriends_B19

class MockHeroesUseCase: HeroesUseCaseProtocol {
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>) -> Void) {
        do {
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTest.self).url(forResource: "Heroes", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            let response = try JSONDecoder().decode([ApiHero].self, from: data)
            completion(.success(response.map({$0.mapToHero()})))
        } catch {
            completion(.failure(.errorPArsingData))
        }
    }
}

class MockHeroesUseCaseError: HeroesUseCaseProtocol {
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>) -> Void) {
        completion(.failure(.noDataReceived))
    }
}

final class HeroesViewModelTests: XCTestCase {
    
    var sut: HeroesViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoadData() {
        // Given
        var expectedHeroes: [Hero] = []
        sut = HeroesViewModel(useCase: MockHeroesUseCase(), storedData: .sharedTesting)
        
        // When
        // Usamod una expectation para esperar a que nos informe de los cambios de estado el viewModel
        let expectation = expectation(description: "ViewModel load heroes and inform")
        sut.stateChanged = { [weak self] state in
            switch state {
            case .dataUpdated:
                expectedHeroes = self?.sut.fetchHeroes() ?? []
                expectation.fulfill()
            case .errorLoadingHeroes(error: _):
                XCTFail("Waiting for success")
            }
        }
        sut.loadData()
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(expectedHeroes.count, 15)
    }

}

// EXtensio de ApiHero para mapearlo al modelo del Domain Hero
extension ApiHero {
    func mapToHero() -> Hero {
        Hero.init(id: self.id,
                  name: self.name,
                  description: self.description,
                  photo: self.photo)
    }
}
