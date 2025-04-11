//
//  HeroesViewModelTests.swift
//  GokuAndFriends_B19Tests
//
//  Created by Luis Quintero on 1/4/25.
//

import XCTest
@testable import GokuAndFriends_B19

final class LoginTests: XCTestCase {
    
    func testHeroesEndpoint() {
        // Given
        let endpoint = GAFEndpoint.heroes(name: "Goku")
        
        // When
        let path = endpoint.path()
        let method = endpoint.httpMethod()
        let params = endpoint.params()
        
        // Then
        XCTAssertEqual(path, "/api/heros/all")
        XCTAssertEqual(method, "POST")
        XCTAssertEqual(String(data: params!, encoding: .utf8), "{\"name\":\"Goku\"}")
    }
    
    func testLoginEndpoint() {
        // Given
        let endpoint = GAFEndpoint.login(username: "usuario@ejemplo.com", password: "123")
        
        // When
        let path = endpoint.path()
        let method = endpoint.httpMethod()
        let params = endpoint.params()
        
        // Then
        XCTAssertEqual(path, "/api/auth/login")
        XCTAssertEqual(method, "POST")
        XCTAssertEqual(String(data: params!, encoding: .utf8), "{\"username\":\"usuario@ejemplo.com\",\"password\":\"123\"}")
    }
    
    // Lo unico de esta app que no necesita token es el login, entonces Atuthorizationrequired es false para login, por lo que hacemos uno AssertFalse
    func testAuthorizationRequirement() {
        XCTAssertTrue(GAFEndpoint.heroes(name: "").isAuthoritationREquired)
        XCTAssertFalse(GAFEndpoint.login(username: "", password: "").isAuthoritationREquired)
    }
}
