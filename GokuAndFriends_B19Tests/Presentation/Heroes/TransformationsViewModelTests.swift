//
//  HeroesViewModelTests.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 1/4/25.
//


import XCTest
@testable import GokuAndFriends_B19

class MockTransformationsUseCase: TransformationsUseCaseProtocol {
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[HeroTransformations], GAFError>) -> Void) {
        do {
            let urlData = try XCTUnwrap(Bundle(for: TransformationsApiProviderTest.self).url(forResource: "Transformations", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            let response = try JSONDecoder().decode([ApiTransformations].self, from: data)
            completion(.success(response.map({ $0.mapToTransformation() })))
        } catch {
            completion(.failure(.errorPArsingData))
        }
    }
}

class MockTransformationsUseCaseError: TransformationsUseCaseProtocol {
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[HeroTransformations], GAFError>) -> Void) {
        completion(.failure(.noDataReceived))
    }
}

final class TransformationsViewModelTests: XCTestCase {
    
    var sut: TransformationsViewModel!
    var hero: Hero!

    override func setUpWithError() throws {
        try super.setUpWithError()
        hero = Hero(id: "", name: "Goku", description: "", photo: "")
    }

    override func tearDownWithError() throws {
        sut = nil
        hero = nil
        try super.tearDownWithError()
    }
    
    func testLoadData_Success() {
        // Given
        var expectedTransformations: [HeroTransformations] = []
        sut = TransformationsViewModel(hero: hero, useCase: MockTransformationsUseCase())
        
        // When
        // Usamos una expectation para esperar a que nos informe de los cambios de estado el viewModel
        let expectation = expectation(description: "ViewModel loads transformations and informs state change")
        sut.stateTransformationChanged = { [weak self] state in
            switch state {
            case .transformation_Data_Updated:
                expectedTransformations = self?.sut.getTransformations() ?? []
                expectation.fulfill()
            case .errorLoadingTransformations(error: _):
                XCTFail("Waiting for success")
            }
        }
        sut.loadTransformationsData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(expectedTransformations.count, 14)
    }
    
    func testLoadData_Error() {
        // Given
        sut = TransformationsViewModel(hero: hero, useCase: MockTransformationsUseCaseError())
        
        // When
        let expectation = expectation(description: "ViewModel fails to load transformations and informs state change")
        sut.stateTransformationChanged = { state in
            switch state {
            case .transformation_Data_Updated:
                XCTFail("Waiting for failure")
            case .errorLoadingTransformations(let error):
                print(error)
                expectation.fulfill()
            }
        }
        sut.loadTransformationsData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}
// EXtensio de ApiTransformations para mapearlo al modelo del Domain Transforations
extension ApiTransformations {
    func mapToTransformation() -> HeroTransformations {
        HeroTransformations(
            id: self.id,
            name: self.name,
            description: self.description,
            photo: self.photo,
            hero: self.hero
        )
    }
}
