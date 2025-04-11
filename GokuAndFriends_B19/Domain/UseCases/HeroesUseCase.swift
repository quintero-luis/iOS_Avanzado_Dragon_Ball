//
//  HeroesUseCaseProtocol.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 31/3/25.
//

import Foundation


protocol HeroesUseCaseProtocol {
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>) -> Void)
}

class HeroesUseCase: HeroesUseCaseProtocol {
    
    private var apiProvider: ApiProvider
    private var storedData: StoreDataProvider
    
    init(apiProvider: ApiProvider = ApiProvider(), storedData: StoreDataProvider = .shared) {
        self.apiProvider = apiProvider
        self.storedData = storedData
    }
    
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>) -> Void) {
        let localHeroes = loadHeroes()
        
        // Comporbamos si tenemos los datos en BBD sis es así los usamos, si no se piden al servicio web
        if loadHeroes().isEmpty {
            apiProvider.fetchHeroes { [weak self] result in
                switch result {
                case .success(let apiHeroes):
                    self?.storedData.context.perform {
                        self?.storedData.insert(heroes: apiHeroes)
                        completion(.success(self?.loadHeroes() ?? []))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(localHeroes))
        }
    }
    
    
    private func loadHeroes() -> [Hero] {
    // Uso de un predicado para filtrar los items en una tabla de la BBDD
//        let filter = NSPredicate(format: "name CONTAINS[cd] %@", "an")
//        let heroes = storedData.fetchHeroes(filter: filter)
        let heroes = storedData.fetchHeroes(filter: nil)
        return heroes.map({$0.mapToHero()})
    }
}
