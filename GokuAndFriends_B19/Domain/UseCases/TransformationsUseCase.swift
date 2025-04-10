//
//  TransformationsUseCase.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 08/04/25.
//
import Foundation

protocol TransformationsUseCaseProtocol {
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[HeroTransformations], GAFError>) -> Void)
}

class TransformationsUseCase: TransformationsUseCaseProtocol {
    
    private var apiProvider: ApiProvider
    private var storedData: StoreDataProvider
    
    init(apiProvider: ApiProvider = .init(), storedData: StoreDataProvider = .shared) {
        self.apiProvider = apiProvider
        self.storedData = storedData
    }
    
    
    
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[HeroTransformations], GAFError>) -> Void) {
        let transformationHero = storedTransformationsForHeroWith(id: id)
            
        if transformationHero.isEmpty {
            apiProvider.fetchTransformations(id: id) { [weak self] result in
                    
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
                completion(.success(transformationHero))
            }
        }
        
    // No la he usado
        private func loadTransformations() -> [HeroTransformations] {
            let transformations = storedData.fetchTransformations(filter: nil)
            return transformations.map({ $0.mapToHeroTransformations() })
        }
    
    private func storedTransformationsForHeroWith(id: String) -> [HeroTransformations] {
        let predicate = NSPredicate(format: "identifier == %@", id)
        
        guard let hero = storedData.fetchHeroes(filter: predicate).first,
              let transformations = hero.transformations else {
            return []
        }
        return transformations.map({$0.mapToHeroTransformations()})
    }
    
}
