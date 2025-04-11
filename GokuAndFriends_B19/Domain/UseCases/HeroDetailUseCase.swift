//
//  HeroDetailUseCaseProtocol.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 3/4/25.
//

import Foundation


protocol HeroDetailUseCaseProtocol {
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[HeroLocation], GAFError>) -> Void)
}

class HeroDEtailUseCase: HeroDetailUseCaseProtocol {
    
    private var storedData: StoreDataProvider
    private var apiProvider: ApiProvider
    
    init(storedData: StoreDataProvider = .shared, apiProvider: ApiProvider = .init()) {
        self.storedData = storedData
        self.apiProvider = apiProvider
    }
    
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[HeroLocation], GAFError>) -> Void) {
        
        let locationsHero = storedLocationsForHeroWith(id: id)
        
        if locationsHero.isEmpty {
            
            apiProvider.fetchLocationForHeroWith(id: id) {[weak self] result in
                
                switch result {
                case .success(let locations):
                    
                    self?.storedData.context.perform {
                        self?.storedData.insert(locations: locations)
                        
                        let bdLocations = self?.storedLocationsForHeroWith(id: id) ?? []
                        
                        completion(.success(bdLocations))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(locationsHero))
        }
    }
    
    private func storedLocationsForHeroWith(id: String) -> [HeroLocation] {
        let predicate = NSPredicate(format: "identifier == %@", id)
        
        guard let hero = storedData.fetchHeroes(filter: predicate).first,
              let locations = hero.locations else {
            return []
        }
        return locations.map({$0.mapToHeroLocation()})
    }
}
