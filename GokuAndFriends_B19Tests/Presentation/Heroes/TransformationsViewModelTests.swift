//
//  HeroesViewModelTests.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 1/4/25.
//


import XCTest
@testable import GokuAndFriends_B19

// Mock implementation of the TransformationsUseCaseProtocol
class MockTransformationsUseCaseSuccess: TransformationsUseCaseProtocol {
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[HeroTransformations], GAFError>) -> Void) {
        let mockTransformations = [
            HeroTransformations(id: "17824501-1106-4815-BC7A-BFDCCEE43CC9", name: "1. Oozaru – Gran Mono",
                                description: "Description for Oozaru",
                                photo: "https://example.com/oozaru.jpg",
                                hero: Hero(id: id, name: "Goku", description: "", photo: "")),
            HeroTransformations(id: "9D6012A0-B6A9-4BAB-854D-67904E90CE01", name: "2. Super Saiyan",
                                description: "Description for Super Saiyan",
                                photo: "https://example.com/supersaiyan.jpg",
                                hero: Hero(id: id, name: "Goku", description: "", photo: ""))
        ]
        completion(.success(mockTransformations))
    }
}

class MockTransformationsUseCaseFailure: TransformationsUseCaseProtocol {
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[HeroTransformations], GAFError>) -> Void) {
        completion(.failure(.noDataReceived))
    }
}

final class TransformationsViewModelTests: XCTestCase {
    
    var sut: TransformationsViewModel!
    var hero: Hero!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        hero = Hero(id: "123", name: "Goku", description: "Hero Description", photo: "https://example.com/goku.jpg")
    }
    
    override func tearDownWithError() throws {
        sut = nil
        hero = nil
        try super.tearDownWithError()
    }
    
    func testLoadTransformationsData_Success() {
        // Given
        sut = TransformationsViewModel(hero: hero, useCase: MockTransformationsUseCaseSuccess())
        
        let expectation = expectation(description: "State should change to transformation_Data_Updated")
        
        sut.stateTransformationChanged = { state in
            switch state {
            case .transformation_Data_Updated:
                expectation.fulfill()
            case .errorLoadingTransformations:
                XCTFail("Expected success, but got error state")
            }
        }
        
        // When
        sut.loadTransformationsData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.numberOfRows(), 2)
        XCTAssertEqual(sut.getTransformations().first?.name, "1. Oozaru – Gran Mono")
    }
    
    func testLoadTransformationsData_Failure() {
        // Given
        sut = TransformationsViewModel(hero: hero, useCase: MockTransformationsUseCaseFailure())
        
        let expectation = expectation(description: "State should change to errorLoadingTransformations")
        
        sut.stateTransformationChanged = { state in
            switch state {
            case .transformation_Data_Updated:
                XCTFail("Expected error, but got success state")
            case .errorLoadingTransformations(let error):
                print(error)
                expectation.fulfill()
            }
        }
        
        // When
        sut.loadTransformationsData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNumberOfRows() {
        // Given
        sut = TransformationsViewModel(hero: hero, useCase: MockTransformationsUseCaseSuccess())
        
        let expectation = expectation(description: "State should change to transformation_Data_Updated")
        
        sut.stateTransformationChanged = { state in
            if case .transformation_Data_Updated = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.loadTransformationsData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.numberOfRows(), 2)
    }
    
    func testGetTransformations() {
        // Given
        sut = TransformationsViewModel(hero: hero, useCase: MockTransformationsUseCaseSuccess())
        
        let expectation = expectation(description: "State should change to transformation_Data_Updated")
        
        sut.stateTransformationChanged = { state in
            if case .transformation_Data_Updated = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.loadTransformationsData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        let transformations = sut.getTransformations()
        XCTAssertEqual(transformations.count, 2)
        XCTAssertEqual(transformations.first?.name, "1. Oozaru – Gran Mono")
    }
}
