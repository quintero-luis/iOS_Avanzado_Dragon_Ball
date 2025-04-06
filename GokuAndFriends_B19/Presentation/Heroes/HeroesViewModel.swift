//
//  HeroesState.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 31/3/25.
//

import Foundation

enum HeroesState {
    case dataUpdated
    case errorLoadingHeroes(error: GAFError)
}

class HeroesViewModel {
    private var heroes: [Hero] = []
    private var useCase: HeroesUseCaseProtocol
    private var storedData: StoreDataProvider
    private var secureData: SecureDataProtocol
    
    var stateChanged: ((HeroesState) -> Void)?
    
    init(useCase: HeroesUseCaseProtocol = HeroesUseCase(),
         storedData: StoreDataProvider = .shared,
         secureData: SecureDataProtocol = SecureDataProvider()) {
        self.useCase = useCase
        self.storedData = storedData
        self.secureData = secureData
    }
    
    func loadData() {
        useCase.loadHeroes { [weak self] result in
            switch result {
            case .success(let heroes):
                self?.heroes = heroes
                self?.stateChanged?(.dataUpdated)
            case .failure(let error):
                self?.stateChanged?(.errorLoadingHeroes(error: error))
            }
        }
    }
    
    func fetchHeroes() -> [Hero] {
       return  heroes
    }
    
    
    // al hacer logout limpiamos el token de keychain y la base de datos
    func performLogout() {
        secureData.clearToken()
        storedData.clearBBDD()
    }
    
    func heroWith(index: Int) -> Hero? {
        guard index < heroes.count else {
            return nil
        }
        return heroes[index]
    }
}
