//
//  ApiHeroTransformation.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 07/04/25.
//

import Foundation
struct ApiHeroTransformation: Codable {
    let id: String
    let name: String?
    let description: String?
    let photo: String?
    let hero: ApiHero?
}
