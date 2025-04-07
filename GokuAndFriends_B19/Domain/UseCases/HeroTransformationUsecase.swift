//
//  HeroTransformationUsecase.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 07/04/25.
//

import Foundation

// Protocolo para el caso de uso de transformaciones
protocol HeroTransformationsUseCaseProtocol {
    func loadTransformationsForHero(id: String, completion: @escaping (Result<[HeroTransformations], GAFError>) -> Void)
}

class HeroTransformationsUseCase: HeroTransformationsUseCaseProtocol {
    
    private var storedData: StoreDataProvider
    private var apiProvider: ApiProvider
    
    init(storedData: StoreDataProvider = .shared, apiProvider: ApiProvider = .init()) {
        self.storedData = storedData
        self.apiProvider = apiProvider
    }
    
    // Implementación del método para cargar las transformaciones de un héroe
    func loadTransformationsForHero(id: String, completion: @escaping (Result<[HeroTransformations], GAFError>) -> Void) {
        
        let storedTransformations = storedTransformationsForHero(id: id)
        
        // Si no están disponibles en la base de datos, obtenemos los datos de la API
        if storedTransformations.isEmpty {
            apiProvider.fetchTransformationsForHero(id: id) { [weak self] result in
                switch result {
                case .success(let transformations):
                    self?.storedData.context.perform {
                        // Guardamos las transformaciones en la base de datos
                        self?.storedData.insertTransformations(transformations: transformations)
                        let bdTransformations = self?.storedTransformationsForHero(id: id) ?? []
                        completion(.success(bdTransformations))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(storedTransformations))
        }
    }
    
    // Función que obtiene las transformaciones de la base de datos
    private func storedTransformationsForHero(id: String) -> [HeroTransformation] {
        let predicate = NSPredicate(format: "identifier == %@", id)
        
        guard let hero = storedData.fetchHeroes(filter: predicate).first,
              let transformations = hero.transformations else {
            return []
        }
        
        // Mapear los objetos de Core Data a los objetos de dominio
        return transformations.map({ $0.mapToHeroTransformation() })
    }
}
