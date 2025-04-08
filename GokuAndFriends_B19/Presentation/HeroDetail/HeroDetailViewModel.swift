//
//  HeroDetailState.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 3/4/25.
//

import Foundation

enum HeroDetailState {
    case locationsUpdated
    case errorLoadingLocation(error: GAFError)
    //Caso para transformacion
    case errorLoadingTransformations(error: GAFError)
}

class HeroDetailViewModel {
    
    private var useCase: HeroDetailUseCaseProtocol
    private var locations: [HeroLocation] = []
    private var hero: Hero
    // Transformaciones añadido
    private var transformations: [HeroTransformations] = [] // Almacenara las transformaciones
    var stateChanged: ((HeroDetailState) -> Void)?
    
    
    init(hero: Hero, useCase: HeroDetailUseCaseProtocol = HeroDEtailUseCase()) {
        self.hero = hero
        self.useCase = useCase
    }
    
    // MARK: - Variables para mostrar nobmre y descripcion de héroe
    
    var heroName: String {
        return hero.name ?? ""
    }
    
    var heroDescription: String {
        return hero.description ?? ""
    }
    
    
    // Para cargar ubicaciones
    func loadData() {
        useCase.fetchLocationsForHeroWith(id: hero.id) { [weak self]  result in
            switch result {
            case .success(let locations):
                self?.locations = locations
                self?.stateChanged?(.locationsUpdated)
            case .failure(let error):
                self?.stateChanged?(.errorLoadingLocation(error: error))
            }
        }
        
        // Cargar las transformaciones
        useCase.fetchTransformationsForHero(id: <#T##String#>, completion: <#T##(Result<[ApiHeroTransformation], GAFError>) -> Void#>)(id: hero.id) { [weak self] result in
                    switch result {
                    case .success(let transformations):
                        self?.transformations = transformations
                    case .failure(let error):
                        self?.stateChanged?(.errorLoadingTransformations(error: <#T##GAFError#>))
                    }
    }
    
    // Para cargar transformaciones
    
    
    func getHeroLocations() -> [HeroAnnotation] {
        var annotations: [HeroAnnotation] = []
        for location in locations {
            if let coordinate = location.coordinate {
                annotations.append(HeroAnnotation(coordinate: coordinate, title: hero.name))
            }
        }
        return annotations
    }
}
