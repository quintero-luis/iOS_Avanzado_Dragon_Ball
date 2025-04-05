//
//  StoreDataProviderTests.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 31/3/25.
//

import XCTest
@testable import GokuAndFriends_B19

final class StoreDataProviderTests: XCTestCase {
    
    private var sut: StoreDataProvider!

    // el setup se ejecuta antes de cada test
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = .sharedTesting
    }

    // Se ejecuta al finalizar cada tests
    override func tearDownWithError() throws {
        sut.clearBBDD()
        sut = nil
        try super.tearDownWithError()
    }
    
    // Unit test del insert de heroes
    func testInsertHeroes() throws {
        // Given
        let expectedHero = createHero()
        let initialCount = sut.fetchHeroes(filter: nil).count
        
        // When
        sut.insert(heroes: [expectedHero])
        
        // Then
        let finalCount = sut.fetchHeroes(filter: nil).count
        XCTAssertEqual(initialCount, 0)
        XCTAssertEqual(finalCount, 1)
        
        let hero = try XCTUnwrap(sut.fetchHeroes(filter: nil).first)
        
        XCTAssertEqual(hero.name, expectedHero.name)
        XCTAssertEqual(hero.info, expectedHero.description)
        XCTAssertEqual(hero.photo, expectedHero.photo)
        XCTAssertTrue(hero.favorite)
        XCTAssertNotNil(hero.identifier)
        
        
    }
    
    // Unit test para validar que el fetch Heroes devuelve la información ordenada de forma correcta
    func testFetchHeroes_shouldREturnHeroesOrderedAscending() throws {
        //Given
        let hero1 = createHero(with: "Oscar")
        let hero2 = createHero(with: "Jose Luis")
        sut.insert(heroes: [hero1, hero2])

        // When
        let heroes = sut.fetchHeroes(filter: nil, sortAscending: true)
        
        // Then
        let firstHero = try XCTUnwrap(heroes.first)
        XCTAssertEqual(firstHero.name, hero2.name)
    }
    
    
    // Unit test para validar que el fetch Heroes filtra correctamente la información
    // para un predicado dado
    func testFetchHeroesShouldFilterItems() throws {
        // Given
        let hero1 = createHero(with: "Oscar")
        let hero2 = createHero(with: "Jose Luis")
        sut.insert(heroes: [hero1, hero2])
        let filter = NSPredicate(format: "name CONTAINS[cd] %@", "Jose")
        
        // When
        let heroes = sut.fetchHeroes(filter: filter)
        
        // Then
        XCTAssertEqual(heroes.count, 1)
        let hero = try XCTUnwrap(heroes.first)
        XCTAssertEqual(hero.name, hero2.name)
    }
    
    // Helper function para crear heroes
    private func createHero(with name: String = "Name") -> ApiHero {
        ApiHero(id: UUID().uuidString,
                favorite: true,
                name: name,
                description: "description",
                photo: "photo")
    }

}
