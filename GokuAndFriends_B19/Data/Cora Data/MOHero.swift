//
//  MOHero+CoreDataClass.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 07/04/25.
//
//

import Foundation
import CoreData

@objc(MOHero)
public class MOHero: NSManagedObject {

}

extension MOHero {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOHero> {
        return NSFetchRequest<MOHero>(entityName: "Hero")
    }

    @NSManaged public var favorite: Bool
    @NSManaged public var identifier: String?
    @NSManaged public var info: String?
    @NSManaged public var name: String?
    @NSManaged public var photo: String?
    @NSManaged public var locations: Set<MOHeroLocation>?
    @NSManaged public var transformations: Set<MOHeroTransformations>?

}

// MARK: Generated accessors for locations
extension MOHero {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: MOHeroLocation)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: MOHeroLocation)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: Set<MOHeroLocation>)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: Set<MOHeroLocation>)

}

// MARK: Generated accessors for transformations
extension MOHero {

    @objc(addTransformationsObject:)
    @NSManaged public func addToTransformations(_ value: MOHeroTransformations)

    @objc(removeTransformationsObject:)
    @NSManaged public func removeFromTransformations(_ value: MOHeroTransformations)

    @objc(addTransformations:)
    @NSManaged public func addToTransformations(_ values: Set<MOHeroTransformations>?)

    @objc(removeTransformations:)
    @NSManaged public func removeFromTransformations(_ values: Set<MOHeroTransformations>?)

}

extension MOHero : Identifiable {

}

extension MOHero {
    // Mapper para crear un objeto Hero de Domain a partir de MOhero
    func mapToHero() -> Hero {
        Hero(id: self.identifier ?? "",
             favorite: self.favorite,
             name: self.name,
             description: self.info,
             photo: self.photo)
    }
}
