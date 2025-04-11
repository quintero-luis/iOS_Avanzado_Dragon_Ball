//
//  ApiTransformations.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 08/04/25.
//

import Foundation

struct ApiTransformations: Codable {
    let id: String
    let name: String?
    let description: String?
    let photo: String?
//    let hero: ApiHero?
    let hero: Hero?
}
