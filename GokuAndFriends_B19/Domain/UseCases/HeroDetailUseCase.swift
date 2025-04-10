//
//  HeroDetailUseCaseProtocol.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 3/4/25.
//

import Foundation


protocol HeroDetailUseCaseProtocol {
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[HeroLocation], GAFError>) -> Void)
    // Añadido para transformaciones
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[HeroTransformations], GAFError>) -> Void)
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
    
    // De transformaciones añadido
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[HeroTransformations], GAFError>) -> Void) {
        let transformationsHero = storedTransformationsForHeroWith(id: id)
        
        if transformationsHero.isEmpty {
            
            apiProvider.fetchTransformationsForHero(id: id) {[weak self] result in
                switch result {
                case .success(let transformations):
                    self?.storedData.context.perform {
                        self?.storedData.insertTransformations(transformations: transformations)
                        let bdTransformations = self?.storedTransformationsForHeroWith(id: id) ?? []
                        completion(.success(bdTransformations))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(transformationsHero))
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
<<<<<<< HEAD
    // Añadido transformaciones
    private func storedTransformationsForHeroWith(id: String) -> [HeroTransformations] {
        let predicate = NSPredicate(format: "identifier == %@", id)
        
        guard let hero = storedData.fetchHeroes(filter: predicate).first,
              let transformations = hero.transformations else {
            return []
        }
        return transformations.map({$0.mapToHeroTransformations()})
    }
=======
    
    
    
    
    
    
>>>>>>> dev
}
