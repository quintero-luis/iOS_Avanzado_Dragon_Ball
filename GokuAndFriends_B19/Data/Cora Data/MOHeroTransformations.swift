//
//  MOHeroTransformations+CoreDataClass.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 07/04/25.
//
//

import Foundation
import CoreData

@objc(MOHeroTransformations)
public class MOHeroTransformations: NSManagedObject {

}

extension MOHeroTransformations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOHeroTransformations> {
        return NSFetchRequest<MOHeroTransformations>(entityName: "HeroTransformations")
    }

    @NSManaged public var name: String?
    @NSManaged public var photo: String?
    @NSManaged public var id: String?
    @NSManaged public var info: String?
    @NSManaged public var hero: MOHero?

}
// MARK: - Añadido
extension MOHeroTransformations {
    func mapToHeroTransformations() -> HeroTransformations {
        HeroTransformations(id: self.id ?? "",
                            name: self.name,
                            description: self.description,
                            photo: self.photo,
                            hero: self.hero?.mapToHero())
    }
}
